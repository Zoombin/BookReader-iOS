//
//  CoreTextViewController.m
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "CoreTextViewController.h"
#import "CoreTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+HUD.h"
#import "BookReader.h"
#import "ReadStatusView.h"
#import "BookReadMenuView.h"
#import "SubscribeViewController.h"
#import "NSString+XXSY.h"
#import "Book.h"
#import "ServiceManager.h"
#import "BookReaderDefaultsManager.h"
#import "ReadHelpView.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"

@implementation CoreTextViewController {
	BOOL bFlipV;
    NSInteger startPointX;
    NSInteger startPointY;

    CoreTextView *coreTextView;
    NSMutableArray *pagesArray;
    NSMutableString *mString;
    NSMutableString *textString;
    UIFont *currentFont;
    CGFloat currentFontSize;
    NSString *currentFontName;
    NSString *currentTextColorStr;
    NSInteger currentBackgroundIndex;
    float currentAlpa;
    int currentPage;
    BOOL bOnline;
    
    NSArray *textColorArray;
    
    ReadStatusView *statusView;
    BookReadMenuView *menuView;
    
    Chapter *chapter;
    Book *book;
    
    NSMutableArray *chaptersArray;
    
    ReadHelpView *helpView;
    
    BOOL shouldLoadChapter;
    BOOL firstEnter;
}

- (id)initWithBook:(Book *)bookObj
           chapter:(Chapter *)chapterObj
     chaptersArray:(NSArray *)array
         andOnline:(BOOL)online;

{
    self = [super init];
    if (self)
    {
        book = bookObj;
        //chapter = chapterObj;
        currentPage = 0;
        bFlipV = NO;
        mString = [@"" mutableCopy];
        textString = [@"" mutableCopy];
        bOnline = online;
        
        chaptersArray = [[NSMutableArray alloc] initWithArray:array];
        
        if (chapterObj != nil && [chaptersArray count] >0) {
            shouldLoadChapter = NO;
            [textString setString:[chapter.content XXSYDecoding]];
        } else {
            shouldLoadChapter = YES;
        }
        currentFontSize = 19;
        currentFontName = UserDefaultFoundFont;
        currentFont = [self setFontWithName:currentFontName];
        currentTextColorStr = @"blackColor";
        currentAlpa = 1;
        currentBackgroundIndex = 13;
        [self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:currentBackgroundIndex]];
        
        [self loadUserDefault];
        pagesArray = [[NSMutableArray alloc] init];
        firstEnter = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 20)];
    [statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusView];
    
    statusView.title.text = chapter.name;
    
    coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 20, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-40)];
    [coreTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:coreTextView];
    
    menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-20)];
    [menuView setDelegate:self];
    [menuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:menuView];
    menuView.hidden = YES;
    
    helpView = [[ReadHelpView alloc] initWithFrame:self.view.bounds];
    [helpView setHidden:YES];
    [self.view addSubview:helpView];
    if (![BookReaderDefaultsManager objectForKey:UserDefaultKeyFirstLaunch]) {
        [helpView setHidden:NO];
        [BookReaderDefaultsManager setObject:[NSNumber numberWithInt:1] ForKey:UserDefaultKeyFirstLaunch];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (book.lastReadChapterID) {//最近读过
		chapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", book.lastReadChapterID]];
	} else {//没读过，从第0章开始
		chapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=0", book.uid]];
	}
	
	NSLog(@"start to read book: %@,  chapter: %@", book, chapter);
	if (!chapter) {//反正数据库没有，章节列表都没有，应该什么地方出错了，退出。所以书城那里应该先去获取章节目录，存到数据库完毕后再推出这个VC
		[self.navigationController popViewControllerAnimated:YES];//TODO: alertView better
	} else if (chapter.content == nil) {//有章节目录，但是没内容，需要去网上取章节内容
		if (chapter.bVip.boolValue) {//如果是收费章节，api不同
			[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:book.authorID andPrice:@"0" withBlock:^(NSString *content, NSString *errorMessage, NSString *result, NSError *error) {
				if (content && ![content isEqualToString:@""]) {
					chapter.content = content;
					[chapter persistWithBlock:^(void) {
						//解码阅读
					}];
				} else {//没订阅到，退出。或者弹出提示
					[self.navigationController popViewControllerAnimated:YES];//TODO: alertView better
				}
			}];
		} else {//普通下载
			[ServiceManager bookCatalogue:chapter.uid withBlock:^(NSString *content, NSString *result, NSString *code, NSError *error) {
				if (content && ![content isEqualToString:@""]) {
					chapter.content = content;
					[chapter persistWithBlock:^(void) {
						book.lastReadChapterID = chapter.uid;
						//解码开始阅读
					}];
				} else {//没下载到
					[self.navigationController popViewControllerAnimated:YES];//TODO: alertView better
				}
			}];
		}
	}
	
//    [self updateContent];
//    if (shouldLoadChapter && [chaptersArray count] == 0) {
//        [self loadChapterData];
//    }
}

- (void)loadChapterData
{
    NSArray *array = [Chapter chaptersRelatedToBook:book.uid];
    if ([array count] > 0) {
        NSLog(@"章节目录存在!");
        NSLog(@"%d",[array count]);
        [chaptersArray removeAllObjects];
        [chaptersArray addObjectsFromArray:array];
        NSArray *chapterObjArray = [Chapter findByAttribute:@"uid" withValue:book.lastReadChapterID];
        int index = 0;
        if ([chapterObjArray count] > 0) {
            Chapter *tmpObj = [chapterObjArray objectAtIndex:0];
            index = [tmpObj.index intValue];
            chapter = tmpObj;
        }
        [self downloadBookWithIndex:index];
    }
    else {
        [self chapterDataFromService];
    }
}

- (void)chapterDataFromService
{
    [ServiceManager bookCatalogueList:book.uid andNewestCataId:@"0" withBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            [chaptersArray removeAllObjects];
            [Chapter persist:result withBlock:nil];
            [chaptersArray addObjectsFromArray:result];
            if([book.lastReadChapterID length]==0) {
                [self downloadBookWithIndex:0];
            } else {
                NSArray *chapterObjArray = [Chapter findByAttribute:@"uid" withValue:book.lastReadChapterID];
                int index = 0;
                if ([chapterObjArray count]>0) {
                    Chapter *tmpObj = [chapterObjArray objectAtIndex:0];
                    index = [tmpObj.index intValue];
                }
                [self downloadBookWithIndex:index];
            }
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //保存阅读进度
    if ([pagesArray count]>0) {
        NSRange range = NSRangeFromString([pagesArray objectAtIndex:currentPage]);
        book.lastReadChapterID = chapter.uid;
        chapter.lastReadIndex = @(range.location);
        [chapter persistWithBlock:nil];
        [book persistWithBlock:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self saveUserDefault];
}

- (void)goToIndexWithLastReadPosition:(NSInteger)location
{
    for (int i = 0; i<[pagesArray count]; i++) {
        NSRange rangeCurrent = NSRangeFromString([pagesArray objectAtIndex:i]);
        if (i==[pagesArray count]-1) {
            currentPage = rangeCurrent.location==location ? i : 0;
            break;
        }
        NSRange rangeNext = NSRangeFromString([pagesArray objectAtIndex:i+1]);
        if (location>=rangeCurrent.location && rangeNext.location>location) {
            NSLog(@"在第%d页",i);
            currentPage = i;
            break;
        }
    }
}

- (void)updateContent {
	[pagesArray removeAllObjects];
    currentFont = [self setFontWithName:currentFontName];
    [pagesArray addObjectsFromArray:[self pagesWithString:textString size:CGSizeMake(coreTextView.frame.size.width, coreTextView.frame.size.height) font:currentFont]];
    if (currentPage >= [pagesArray count]) {
        currentPage = [pagesArray count] - 1;
    }
    if (firstEnter && [textString length] > 0) {
        firstEnter = NO;
        [self goToIndexWithLastReadPosition:[chapter.lastReadIndex intValue]];
    }
    [mString setString:[textString substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPage])]];
    [self updateStatusPercentage];
    statusView.title.text = chapter.name;
    coreTextView.fontSize = currentFontSize;
    coreTextView.font =currentFont;
    coreTextView.alpha = currentAlpa;
    statusView.alpha = currentAlpa;
    
    SEL textcolorselector = NSSelectorFromString(currentTextColorStr);
    coreTextView.textColor = [UIColor performSelector:textcolorselector];
    statusView.title.textColor = [UIColor performSelector:textcolorselector];
    statusView.percentage.textColor = [UIColor performSelector:textcolorselector];
	[coreTextView buildTextWithString:mString];
	[coreTextView setNeedsDisplay];
}

- (void)loadUserDefault
{
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyFontName]) {
        currentFontName = [BookReaderDefaultsManager objectForKey:UserDefaultKeyFontName];
    }
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize]) {
        currentFontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] floatValue];
    }
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor]) {
        currentTextColorStr = [BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor];
    }
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyBright]) {
        currentAlpa = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyBright] floatValue];
    }
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyBackground]) {
        [self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:[[BookReaderDefaultsManager objectForKey:UserDefaultKeyBackground] integerValue]]];
    }
}

- (void)saveUserDefault
{
    //保存字体名字
    [BookReaderDefaultsManager setObject:currentFontName ForKey:UserDefaultKeyFontName];
    //保存字体大小
    [BookReaderDefaultsManager setObject:[NSNumber numberWithFloat:currentFontSize] ForKey:UserDefaultKeyFontSize];
    //保存字体颜色
    [BookReaderDefaultsManager setObject:currentTextColorStr ForKey:UserDefaultKeyTextColor];
    //保存亮度
    [BookReaderDefaultsManager setObject:[NSNumber numberWithFloat:currentAlpa] ForKey:UserDefaultKeyBright];
    //保存背景色
    [BookReaderDefaultsManager setObject:[NSNumber numberWithInteger:currentBackgroundIndex] ForKey:UserDefaultKeyBackground];
}

#pragma mark-
#pragma mark MenuView Delegate
- (UIFont *)setFontWithName:(NSString *)fontName
{
    UIFont *font = [UIFont fontWithName:fontName size:currentFontSize];
    return font;
}

- (void)brightChanged:(id)sender
{
    UISlider *slider = sender;
    currentAlpa = slider.value;
    coreTextView.alpha = slider.value;
    statusView.alpha = slider.value;
}

- (void)backgroundColorChanged:(NSInteger)index
{
    currentBackgroundIndex = index;
    [self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:index]];
}

- (void)changeTextColor:(NSString *)textColor
{
    currentTextColorStr = textColor;
    [self updateContent];
}

- (void)fontReduce
{
    if (currentFontSize==[UserDefaultFontSizeMin floatValue]) {
        [self displayHUDError:nil message:@"字体已达到最小"];
        return;
    } else {
        currentFontSize--;
        [self updateContent];
    }
}

- (void)fontAdd {
    if (currentFontSize==[UserDefaultFontSizeMax floatValue]) {
        [self displayHUDError:nil message:@"字体已达到最大"];
        return;
    } else {
        currentFontSize++;
        [self updateContent];
    }
}

- (void)systemFont
{
    currentFontName = UserDefaultSystemFont;
    [self updateContent];
}

- (void)foundFont
{
    currentFontName = UserDefaultFoundFont;
    [self updateContent];
}

#pragma mark -
#pragma mark other methods

- (void)updateStatusPercentage
{
    if (!statusView)
    {
        return;
    }
    statusView.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self readPercentage]];
    if ([pagesArray count]==1)
    {
        statusView.percentage.text = @"100.00%";
    }
}

- (float)readPercentage
{
    if (![pagesArray count])
    {
        return 0.0;
    }
    float percentage = (float)( (float)(currentPage + 1) / (float)([pagesArray count]) );
    if (currentPage == 0) {
        percentage = 0.0;
    }
    return percentage * 100.0f;
}


- (void)nextPage
{
    if (!menuView.hidden) {
        menuView.hidden = YES;
        return;
    }
    currentPage++;
    if(currentPage >= [pagesArray count])
    {
        currentPage = [pagesArray count] - 1;
        [self nextChapter];
        NSLog(@"no more next!");
        return;
    }
    
    if (bFlipV) {
        [self performTransition:kCATransitionFromTop andType:@"pageCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageCurl"];
    
    [self updateContent];
}

- (void)nextChapter
{
    if ([chapter.index integerValue] == [chaptersArray count] - 1) {
        [self displayHUDError:@"" message:@"最后一章"];
    } else {
        NSLog(@"%@",chapter.index);
        [self downloadBookWithIndex:[chapter.index integerValue]+1];
    }
}

- (void)menu
{
    startPointX = NSIntegerMax;
    startPointY = NSIntegerMax;
    menuView.hidden = !menuView.hidden;
}

- (void)previousChapter
{
    if ([chapter.index integerValue] == 0) {
        [self displayHUDError:@"" message:@"此章是第一章"];
    }else {
        [self downloadBookWithIndex:[chapter.index integerValue]-1];
    }
}

- (void)previousPage
{
    if (!menuView.hidden) {
        menuView.hidden = YES;
        return;
    }
    currentPage--;
    if(currentPage < 0)
    {
        currentPage = 0;
        [self previousChapter];
        NSLog(@"no more previous!");
        return;
    }
    if (bFlipV) {
        [self performTransition:kCATransitionFromBottom andType:@"pageUnCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageUnCurl"];
    [self updateContent];
}

- (BOOL)pointInMenuTouchX:(float)x andY:(float)y
{
	float pageOffset = 0*coreTextView.bounds.size.width;
    if (x >= pageOffset+MAIN_SCREEN.size.width/3 && x <= pageOffset+MAIN_SCREEN.size.width/3*2 && y >= MAIN_SCREEN.size.height/4 && y <= MAIN_SCREEN.size.height/4*3) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *start = [[event allTouches] anyObject];
    CGPoint startPoint = [start locationInView:self.view];
    
    startPointX = startPoint.x;
    startPointY = startPoint.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *end = [[event allTouches] anyObject];
    CGPoint endPoint = [end locationInView:self.view];
    float endPointX = endPoint.x;
    float endPointY = endPoint.y;
    
    if (!helpView.hidden) {
        helpView.hidden = YES;
    }
    
    if (startPointX == NSIntegerMax || startPointY == NSIntegerMax) {
        return;
    }
    
    if (bFlipV) {
        if (fabs(endPointY - startPointY) >= 9)
        {
            if (endPointY > startPointY) {
                [self previousPage];
            } else {
                [self nextPage];
            }
            return;
        }
        
        if ([self pointInMenuTouchX:endPointX andY:endPointY])
        {
            [self menu];
            return;
        }
        
        if (endPointY >= MAIN_SCREEN.size.height/2)
        {
            [self nextPage];
            return;
        }
        else {
            [self previousPage];
            return;
        }
    } else {
        if (fabsf(endPointX - startPointX) >= 9)
        {
            if (endPointX > startPointX ) {
                [self previousPage];
            }else {
                [self nextPage];
            }
            return;
        }
        
        if ([self pointInMenuTouchX:endPointX andY:endPointY])
        {
            [self menu];
            return;
        }
        
        if(endPointX >= MAIN_SCREEN.size.width/2)
        {
            [self nextPage];
            return;
        }
        else
        {
            [self previousPage];
            return;
        }
    }
}


- (NSArray*) pagesWithString:(NSString*)string size:(CGSize)size font:(UIFont*)font;
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CTFontRef fnt = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize,NULL);
    CFAttributedStringRef str = CFAttributedStringCreate(kCFAllocatorDefault,
                                                         (CFStringRef)string,
                                                         (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fnt,kCTFontAttributeName,nil]);
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString(str);
    CFRange r = {0,0};
    CFRange res = {0,0};
    NSInteger str_len = [string length];
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(fs,r, NULL, size, &res);
        r.location += res.length;
        NSRange range = NSMakeRange(res.location, res.length);
        [result addObject:[NSString stringWithFormat:@"(%d,%d)",range.location,range.length]];
    } while(r.location < str_len);
    
    CFRelease(fs);
    CFRelease(str);
    CFRelease(fnt);
    return result;
}

//翻页动画
-(void)performTransition:(NSString *)transitionType andType:(NSString *)type
{
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.75;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    transition.subtype = transitionType;
	transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
}

#pragma mark -
#pragma mark BookReadMenuDelegate
- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBookMarkButtonPressed
{
    NSLog(@"添加书签成功");
}

- (void)chapterButtonClick
{
    SubscribeViewController *childViewController = [[SubscribeViewController alloc] initWithBookId:book andOnline:bOnline];
    [childViewController setDelegate:self];
    [self.navigationController pushViewController:childViewController animated:YES];
}

- (void)previousChapterButtonClick
{
    [self previousChapter];
}

- (void)nextChapterButtonClick
{
    [self nextChapter];
}

//订阅和下载
- (void)downloadBookWithIndex:(NSInteger)index
{
    [self displayHUD:@"获取内容中..."];
    Chapter *obj = [chaptersArray objectAtIndex:index];
    if (obj.content!=nil) {
        NSLog(@"已下载");
        [textString setString:[obj.content XXSYDecoding]];
        [self setPageIndexByChapter:chapter];
        chapter = obj;
        chapter.bRead = [NSNumber numberWithBool:YES];
        book.lastReadChapterID = chapter.uid;
        [chapter persistWithBlock:nil];
        [book persistWithBlock:nil];
        [self updateContent];
        [self hideHUD:YES];
    }else {
        [ServiceManager bookCatalogue:obj.uid withBlock:^(NSString *content,NSString *result,NSString *code, NSError *error) {
            if (error) {
                [self displayHUDError:nil message:NETWORK_ERROR];
            } else {
                if (![code isEqualToString:SUCCESS_FLAG]) {
                    [self chapterSubscribeWithObj:obj];
                }
                else {
                    chapter = obj;
                    chapter.content = content;
                    chapter.bRead = [NSNumber numberWithBool:YES];
                    book.lastReadChapterID = chapter.uid;
                    [chapter persistWithBlock:nil];
                    [book persistWithBlock:nil];
                    [textString setString:[chapter.content XXSYDecoding]];
                    [self setPageIndexByChapter:chapter];
                    [self updateContent];
                    [self hideHUD:YES];
                }
            }
        }];
    }
}

- (void)chapterSubscribeWithObj:(Chapter *)obj
{
    if ([ServiceManager userID]!=nil) {
        [ServiceManager chapterSubscribeWithChapterID:obj.uid book:book.uid author:book.authorID andPrice:@"0" withBlock:^(NSString *content,NSString *result,NSString *code,NSError *error) {
            if (error) {
                [self hideHUD:YES];
            } else {
                if ([code isEqualToString:SUCCESS_FLAG]) {
                    chapter = obj;
                    chapter.bBuy = [NSNumber numberWithBool:YES];
                    chapter.content = content;
                    chapter.bRead = [NSNumber numberWithBool:YES];
                    book.lastReadChapterID = chapter.uid;
                    [chapter persistWithBlock:nil];
                    [book persistWithBlock:nil];
                    [textString setString:[chapter.content XXSYDecoding]];
                    [self setPageIndexByChapter:chapter];
                    [self updateContent];
                    [self hideHUD:YES];
                } else {
                    [self displayHUDError:nil message:@"无法下载阅读"];
                }
            }
        }];
    } else {
        
    }
}

- (void)setPageIndexByChapter:(Chapter *)obj
{
    if ([chapter.lastReadIndex intValue]==0) {
        currentPage = 0;
    } else {
        [self goToIndexWithLastReadPosition:[obj.lastReadIndex intValue]];
    }
}

- (void)chapterDidSelectAtIndex:(NSInteger)index
{
    [self downloadBookWithIndex:index];
}

@end
