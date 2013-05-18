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
    NSInteger startPointX;
    NSInteger startPointY;
    CoreTextView *coreTextView;
	ReadStatusView *statusView;
    BookReadMenuView *menuView;
	CGRect menuRect;
	CGRect nextRect;

    NSMutableArray *pagesArray;
    NSMutableString *currentChapterString;
    NSMutableString *currentPageString;
    NSString *currentTextColorStr;
    NSInteger currentBackgroundIndex;
    int currentPageIndex;
    Chapter *chapter;
    NSMutableArray *chaptersArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSNumber *colorIdx = [BookReaderDefaultsManager objectForKey:UserDefaultKeyBackground];
	[self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:colorIdx.intValue]];
	
	currentPageIndex = 0;
	pagesArray = [[NSMutableArray alloc] init];
	
	CGSize size = self.view.bounds.size;
	
	menuRect = CGRectMake(size.width/3, size.height/4, size.width/3, size.height/2);
	nextRect = CGRectMake(size.width/2, 0, size.width/2, size.height);
    
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, size.width, 20)];
    [statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusView];
    
    statusView.title.text = chapter.name;
    
    coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 20, size.width, size.height-40)];
	coreTextView.font = [BookReaderDefaultsManager objectForKey:UserDefaultKeyFont];
	coreTextView.fontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] floatValue];
	NSString *textColorString = [BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor];
	coreTextView.textColor = [UIColor performSelector:NSSelectorFromString(textColorString)];
    [coreTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:coreTextView];
    
    menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height-20)];
    [menuView setDelegate:self];
    [menuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:menuView];
    menuView.hidden = YES;

	if (YES) {//TOTEST
	//if (![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultKeyNotFirstRead]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDefaultKeyNotFirstRead];
		[[NSUserDefaults standardUserDefaults] synchronize];
		ReadHelpView *helpView = [[ReadHelpView alloc] initWithFrame:self.view.bounds andMenuFrame:menuRect];
		[self.view addSubview:helpView];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (_book.lastReadChapterID) {//最近读过
		chapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", _book.lastReadChapterID]];
	} else {//没读过，从第0章开始
		chapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=0", _book.uid]];
	}
	
	NSLog(@"start to read book: %@,  chapter: %@", _book, chapter);
	if (!chapter) {//反正数据库没有，章节列表都没有，应该什么地方出错了，退出。所以书城那里应该先去获取章节目录，存到数据库完毕后再推出这个VC
		[self.navigationController popViewControllerAnimated:YES];//TODO: alertView better
	} else if (chapter.content == nil) {//有章节目录，但是没内容，需要去网上取章节内容
		if (chapter.bVip.boolValue) {//如果是收费章节，api不同
			[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:_book.authorID andPrice:@"0" withBlock:^(NSString *content, NSString *errorMessage, NSString *result, NSError *error) {
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
						_book.lastReadChapterID = chapter.uid;
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
    NSArray *array = [Chapter chaptersRelatedToBook:_book.uid];
    if ([array count] > 0) {
        NSLog(@"章节目录存在!");
        NSLog(@"%d",[array count]);
        [chaptersArray removeAllObjects];
        [chaptersArray addObjectsFromArray:array];
        NSArray *chapterObjArray = [Chapter findByAttribute:@"uid" withValue:_book.lastReadChapterID];
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
    [ServiceManager bookCatalogueList:_book.uid andNewestCataId:@"0" withBlock:^(NSArray *result, NSError *error) {
        if (!error) {
            [chaptersArray removeAllObjects];
            [Chapter persist:result withBlock:nil];
            [chaptersArray addObjectsFromArray:result];
            if([_book.lastReadChapterID length]==0) {
                [self downloadBookWithIndex:0];
            } else {
                NSArray *chapterObjArray = [Chapter findByAttribute:@"uid" withValue:_book.lastReadChapterID];
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
        NSRange range = NSRangeFromString([pagesArray objectAtIndex:currentPageIndex]);
        _book.lastReadChapterID = chapter.uid;
        chapter.lastReadIndex = @(range.location);
        [chapter persistWithBlock:nil];
        [_book persistWithBlock:nil];
    }
}

- (void)goToIndexWithLastReadPosition:(NSInteger)location
{
    for (int i = 0; i<[pagesArray count]; i++) {
        NSRange rangeCurrent = NSRangeFromString([pagesArray objectAtIndex:i]);
        if (i==[pagesArray count]-1) {
            currentPageIndex = rangeCurrent.location==location ? i : 0;
            break;
        }
        NSRange rangeNext = NSRangeFromString([pagesArray objectAtIndex:i+1]);
        if (location>=rangeCurrent.location && rangeNext.location>location) {
            NSLog(@"在第%d页",i);
            currentPageIndex = i;
            break;
        }
    }
}

- (void)updateContent {
	[pagesArray removeAllObjects];
	UIFont *font = [BookReaderDefaultsManager objectForKey:UserDefaultKeyFont];
    [pagesArray addObjectsFromArray:[self pagesWithString:currentChapterString size:CGSizeMake(coreTextView.frame.size.width, coreTextView.frame.size.height) font:font]];
    if (currentPageIndex >= [pagesArray count]) {
        currentPageIndex = [pagesArray count] - 1;
    }
	
	if (currentChapterString.length) {
		if (chapter.lastReadIndex) {
			[self goToIndexWithLastReadPosition:[chapter.lastReadIndex intValue]];
		} else {
			[self goToIndexWithLastReadPosition:0];
		}
	}
	
    [currentPageString setString:[currentChapterString substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPageIndex])]];
    [self updateStatusPercentage];
    statusView.title.text = chapter.name;
    coreTextView.fontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] integerValue];
	NSString *fontName =[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontName];
    coreTextView.font = [UIFont fontWithName:fontName size:coreTextView.fontSize];
    coreTextView.alpha = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyBright] floatValue];
    statusView.alpha = coreTextView.alpha;
    
	NSString *textColorString = [BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor];
    SEL textcolorselector = NSSelectorFromString(textColorString);
    coreTextView.textColor = [UIColor performSelector:textcolorselector];
    statusView.title.textColor = [UIColor performSelector:textcolorselector];
    statusView.percentage.textColor = [UIColor performSelector:textcolorselector];
	[coreTextView buildTextWithString:currentPageString];
	[coreTextView setNeedsDisplay];
}

#pragma mark-
#pragma mark MenuView Delegate
- (void)brightChanged:(UISlider *)slider
{
	[BookReaderDefaultsManager setObject:@(slider.value) ForKey:UserDefaultKeyBright];
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
	[BookReaderDefaultsManager setObject:textColor ForKey:UserDefaultKeyTextColor];
    [self updateContent];
}

- (void)fontChanged:(BOOL)reduce
{
	CGFloat currentFontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] floatValue];
	currentFontSize += reduce ? -1 : 1;
	if (currentFontSize < UserDefaultFontSizeMin.floatValue && currentFontSize > UserDefaultFontSizeMax.floatValue) {
		NSString *errorMessage = [NSString stringWithFormat:@"字体已达到最%@", reduce ? @"小" : @"大"];
		[self displayHUDError:nil message:errorMessage];
		return;
	}
	[BookReaderDefaultsManager setObject:@(currentFontSize) ForKey:UserDefaultKeyFontSize];
	[self updateContent];
}

- (void)systemFont
{
	[BookReaderDefaultsManager setObject:UserDefaultSystemFont ForKey:UserDefaultKeyFontName];
    [self updateContent];
}

- (void)foundFont
{
	[BookReaderDefaultsManager setObject:UserDefaultFoundFont ForKey:UserDefaultKeyFontName];
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
    float percentage = (float)( (float)(currentPageIndex + 1) / (float)([pagesArray count]) );
    if (currentPageIndex == 0) {
        percentage = 0.0;
    }
    return percentage * 100.0f;
}


- (void)nextPage
{
    currentPageIndex++;
    if(currentPageIndex >= [pagesArray count])
    {
        currentPageIndex = [pagesArray count] - 1;
        [self nextChapter];
        NSLog(@"no more next!");
        return;
    }
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
    currentPageIndex--;
    if(currentPageIndex < 0)
    {
        currentPageIndex = 0;
        [self previousChapter];
        NSLog(@"no more previous!");
        return;
    }
	[self performTransition:kCATransitionFromRight andType:@"pageUnCurl"];
    [self updateContent];
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
    if (startPointX == NSIntegerMax || startPointY == NSIntegerMax) {
        return;
    }
    //swipe
	if (fabsf(endPoint.x - startPointX) >= 9)
	{
		if (endPoint.x > startPointX ) {
			[self previousPage];
		}else {
			[self nextPage];
		}
		return;
	}
	
	//tap
	if (CGRectContainsPoint(menuRect, endPoint)){
		[self menu];
		return;
	}
	
	if (CGRectContainsPoint(nextRect, endPoint)) {
		[self nextPage];
	} else {
		[self previousPage];
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
    SubscribeViewController *childViewController = [[SubscribeViewController alloc] initWithBookId:_book andOnline:YES];//TODO: yes useless
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
        [currentChapterString setString:[obj.content XXSYDecoding]];
        [self setPageIndexByChapter:chapter];
        chapter = obj;
        chapter.bRead = [NSNumber numberWithBool:YES];
        _book.lastReadChapterID = chapter.uid;
        [chapter persistWithBlock:nil];
        [_book persistWithBlock:nil];
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
                    _book.lastReadChapterID = chapter.uid;
                    [chapter persistWithBlock:nil];
                    [_book persistWithBlock:nil];
                    [currentChapterString setString:[chapter.content XXSYDecoding]];
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
        [ServiceManager chapterSubscribeWithChapterID:obj.uid book:_book.uid author:_book.authorID andPrice:@"0" withBlock:^(NSString *content,NSString *result,NSString *code,NSError *error) {
            if (error) {
                [self hideHUD:YES];
            } else {
                if ([code isEqualToString:SUCCESS_FLAG]) {
                    chapter = obj;
                    chapter.bBuy = [NSNumber numberWithBool:YES];
                    chapter.content = content;
                    chapter.bRead = [NSNumber numberWithBool:YES];
                    _book.lastReadChapterID = chapter.uid;
                    [chapter persistWithBlock:nil];
                    [_book persistWithBlock:nil];
                    [currentChapterString setString:[chapter.content XXSYDecoding]];
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
        currentPageIndex = 0;
    } else {
        [self goToIndexWithLastReadPosition:[obj.lastReadIndex intValue]];
    }
}

- (void)chapterDidSelectAtIndex:(NSInteger)index
{
    [self downloadBookWithIndex:index];
}

@end
