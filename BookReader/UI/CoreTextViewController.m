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
	
	CGSize size = self.view.bounds.size;
	
	menuRect = CGRectMake(size.width/3, size.height/4, size.width/3, size.height/2);
	nextRect = CGRectMake(size.width/2, 0, size.width/2, size.height);
    
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, size.width, 20)];
    [statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusView];
    
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
	//TODO:targe
    [self.view addSubview:menuView];
    menuView.hidden = YES;

	if (YES) {//TOTEST
	//if (![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultKeyNotFirstRead]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDefaultKeyNotFirstRead];
		[[NSUserDefaults standardUserDefaults] synchronize];
		ReadHelpView *helpView = [[ReadHelpView alloc] initWithFrame:self.view.bounds andMenuFrame:menuRect];
		[self.view addSubview:helpView];
	}
	
	coreTextView.alpha = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyBright] floatValue];
    statusView.alpha = coreTextView.alpha;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	Chapter *aChapter;
	if (_book.lastReadChapterID) {//最近读过
		aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", _book.lastReadChapterID]];
	} else {//没读过，从第0章开始
		aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=0", _book.uid]];
	}
	
	NSLog(@"start to read book: %@,  chapter: %@", _book, chapter);
	if (!aChapter) {//反正数据库没有，章节列表都没有，应该什么地方出错了，退出。所以书城那里应该先去获取章节目录，存到数据库完毕后再推出这个VC
		[self.navigationController popViewControllerAnimated:YES];//TODO: alertView better
	}
	
	if (aChapter.content) {
		[self gotoChapter:aChapter];
	} else {
		;//没内容需要下载
		
//		[ServiceManager bookCatalogue:chapter.uid withBlock:^(NSString *content, NSString *result, NSString *code, NSError *error) {
//			if (content && ![content isEqualToString:@""]) {
//				chapter.content = content;
//				[chapter persistWithBlock:^(void) {
//					_book.lastReadChapterID = chapter.uid;
//					currentChapterString = [[chapter.content XXSYDecoding] mutableCopy];//解码阅读
//					[self paging];
//				}];
//			} else {//没下载到
//				if (error) {
//					;//TODO: alert error
//				} else {
//					;//TODO subscribe
//				}
//			}
//		}];
	}
}

//- (void)loadChapterData
//{
//    NSArray *array = [Chapter chaptersRelatedToBook:_book.uid];
//    if ([array count] > 0) {
//        NSLog(@"章节目录存在!");
//        NSLog(@"%d",[array count]);
//        [chaptersArray removeAllObjects];
//        [chaptersArray addObjectsFromArray:array];
//        NSArray *chapterObjArray = [Chapter findByAttribute:@"uid" withValue:_book.lastReadChapterID];
//        int index = 0;
//        if ([chapterObjArray count] > 0) {
//            Chapter *tmpObj = [chapterObjArray objectAtIndex:0];
//            index = [tmpObj.index intValue];
//            chapter = tmpObj;
//        }
//        [self downloadBookWithIndex:index];
//    }
//    else {
//        [self chapterDataFromService];
//    }
//}

//- (void)chapterDataFromService
//{
//    [ServiceManager bookCatalogueList:_book.uid andNewestCataId:@"0" withBlock:^(NSArray *result, NSError *error) {
//        if (!error) {
//            [chaptersArray removeAllObjects];
//            [Chapter persist:result withBlock:nil];
//            [chaptersArray addObjectsFromArray:result];
//            if([_book.lastReadChapterID length]==0) {
//                [self downloadBookWithIndex:0];
//            } else {
//                NSArray *chapterObjArray = [Chapter findByAttribute:@"uid" withValue:_book.lastReadChapterID];
//                int index = 0;
//                if ([chapterObjArray count]>0) {
//                    Chapter *tmpObj = [chapterObjArray objectAtIndex:0];
//                    index = [tmpObj.index intValue];
//                }
//                [self downloadBookWithIndex:index];
//            }
//        }
//    }];
//}

- (NSUInteger)goToIndexWithLastReadPosition:(NSInteger)index
{
	__block NSUInteger indexCount = 0;
	__block NSUInteger rtnPageIndex = 0;
	[pagesArray enumerateObjectsUsingBlock:^(NSString *rangeString, NSUInteger idx, BOOL *stop) {
		NSRange range = NSRangeFromString(rangeString);
		indexCount += range.length;
		if (index <= indexCount) {
			rtnPageIndex = idx;
			*stop = YES;
		}
	}];
	if (rtnPageIndex > pagesArray.count - 1) {
		rtnPageIndex = pagesArray.count - 1;
	}
	return rtnPageIndex;
}

- (void)updateFontSize
{
	[self paging];
}

- (void)updateFontColor
{
	NSString *textColorString = [BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor];
    SEL textcolorselector = NSSelectorFromString(textColorString);
	coreTextView.textColor = [UIColor performSelector:textcolorselector];
    statusView.title.textColor = [UIColor performSelector:textcolorselector];
    statusView.percentage.textColor = [UIColor performSelector:textcolorselector];
	//TODO:need?
	[coreTextView buildTextWithString:currentPageString];
	[coreTextView setNeedsDisplay];
}

- (void)updateFont
{
	[self paging];
}

- (void)updateBackgroundColor
{
	
}

- (void)updateBright
{
	
}


- (void)paging
{
	coreTextView.font = [BookReaderDefaultsManager objectForKey:UserDefaultKeyFont];
	NSAssert(currentChapterString != nil, @"currentChapterString == nil...");
	pagesArray = [[currentChapterString pagesWithFont:coreTextView.font inSize:coreTextView.frame.size] mutableCopy];
	NSRange range = NSRangeFromString(pagesArray[currentPageIndex]);
	currentPageString = [[currentChapterString substringWithRange:range] mutableCopy];
	statusView.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self readPercentage]];
	NSAssert(currentPageString != nil, @"currentPageString == nil");
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
    [self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:index]];
}

- (void)changeTextColor:(NSString *)textColor
{
	[BookReaderDefaultsManager setObject:textColor ForKey:UserDefaultKeyTextColor];
	//TODO
    //[self updateContent];
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
	//TODO
	//[self updateContent];
}

- (void)systemFont
{
	[BookReaderDefaultsManager setObject:UserDefaultSystemFont ForKey:UserDefaultKeyFontName];
	//TODO
    //[self updateContent];
}

- (void)foundFont
{
	[BookReaderDefaultsManager setObject:UserDefaultFoundFont ForKey:UserDefaultKeyFontName];
	//TODO
    //[self updateContent];
}

#pragma mark -
#pragma mark other methods
- (float)readPercentage
{
	if (pagesArray.count == 0) {
		return 100.0f;
	} else if (currentPageIndex == 0) {
		return 0.0f;
	}
	return ((float)(currentPageIndex + 1) / pagesArray.count) * 100.0f;
}

- (void)previousPage
{
    currentPageIndex--;
    if(currentPageIndex < 0) {
        currentPageIndex = 0;
		NSLog(@"no more previous page!");
        [self previousChapter];
        return;
    }
	[self performTransition:kCATransitionFromRight andType:@"pageUnCurl"];
    [self paging];
}

- (void)nextPage
{
    currentPageIndex++;
    if(currentPageIndex > [pagesArray count] - 1) {
        currentPageIndex = [pagesArray count] - 1;
		NSLog(@"no more next page!");
        [self nextChapter];
        return;
    }
	[self performTransition:kCATransitionFromRight andType:@"pageCurl"];
	[self paging];
}

- (void)gotoChapter:(Chapter *)aChapter
{
	chapter = aChapter;
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		_book.lastReadChapterID = chapter.uid;
	}];
	statusView.title.text = chapter.name;
	currentPageIndex = 0;
	currentChapterString = [[chapter.content XXSYDecoding] mutableCopy];//解码阅读
	[self paging];
	if ([chapter.lastReadIndex integerValue]) {
		currentPageIndex = [self goToIndexWithLastReadPosition:[chapter.lastReadIndex intValue]];
	} else {
		currentPageIndex = [self goToIndexWithLastReadPosition:0];
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			chapter.lastReadIndex = 0;
		}];
	}
}

- (void)previousChapter
{
    if ([chapter.index integerValue] == 0) {
        [self displayHUDError:@"" message:@"此章是第一章"];
    }else {
		Chapter *previousChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=%d", _book.uid, chapter.index.intValue - 1]];
		if (!previousChapter) {
			;//TODO, 没有找到，肯定什么地方出错了
		} else {
			if (!previousChapter.content) {
				;//TODO, 没下载到，需要下载
			} else {
				[self gotoChapter:previousChapter];
			}
		}
    }
}

- (void)nextChapter
{
	Chapter *nextChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=%d", _book.uid, chapter.index.intValue + 1]];
	if (!nextChapter) {
		[self displayHUDError:@"" message:@"最后一章"];
	} else {
		if (nextChapter.content == nil) {
			;//
		} else {
			[self gotoChapter:nextChapter];
		}
	}
}

- (void)menu
{
    startPointX = NSIntegerMax;
    startPointY = NSIntegerMax;
	menuView.hidden = NO;
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
	if (fabsf(endPoint.x - startPointX) >= 9) {
		if (endPoint.x > startPointX ) {
			[self previousPage];
		}else {
			[self nextPage];
		}
		return;
	}
	
	//tap
	if (CGRectContainsPoint(menuRect, endPoint)) {
		[self menu];
		return;
	}
	
	if (CGRectContainsPoint(nextRect, endPoint)) {
		[self nextPage];
	} else {
		[self previousPage];
	}
}

//翻页动画
-(void)performTransition:(NSString *)transitionType andType:(NSString *)type
{
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.5;
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

- (void)chaptersButtonClicked
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
//
////订阅和下载
//- (void)downloadBookWithIndex:(NSInteger)index
//{
//    [self displayHUD:@"获取内容中..."];
//    Chapter *obj = [chaptersArray objectAtIndex:index];
//    if (obj.content!=nil) {
//        NSLog(@"已下载");
//        [currentChapterString setString:[obj.content XXSYDecoding]];
//        [self setPageIndexByChapter:chapter];
//        chapter = obj;
//        chapter.bRead = [NSNumber numberWithBool:YES];
//        _book.lastReadChapterID = chapter.uid;
//        [chapter persistWithBlock:nil];
//        [_book persistWithBlock:nil];
//		//TODO
//        //[self updateContent];
//        [self hideHUD:YES];
//    }else {
//        [ServiceManager bookCatalogue:obj.uid withBlock:^(NSString *content,NSString *result,NSString *code, NSError *error) {
//            if (error) {
//                [self displayHUDError:nil message:NETWORK_ERROR];
//            } else {
//                if (![code isEqualToString:SUCCESS_FLAG]) {
//                    [self chapterSubscribeWithObj:obj];
//                }
//                else {
//                    chapter = obj;
//                    chapter.content = content;
//                    chapter.bRead = [NSNumber numberWithBool:YES];
//                    _book.lastReadChapterID = chapter.uid;
//                    [chapter persistWithBlock:nil];
//                    [_book persistWithBlock:nil];
//                    [currentChapterString setString:[chapter.content XXSYDecoding]];
//                    [self setPageIndexByChapter:chapter];
//					//TODO
//                    //[self updateContent];
//                    [self hideHUD:YES];
//                }
//            }
//        }];
//    }
//}

//- (void)chapterSubscribeWithObj:(Chapter *)obj
//{
//    if ([ServiceManager userID]!=nil) {
//        [ServiceManager chapterSubscribeWithChapterID:obj.uid book:_book.uid author:_book.authorID andPrice:@"0" withBlock:^(NSString *content,NSString *result,NSString *code,NSError *error) {
//            if (error) {
//                [self hideHUD:YES];
//            } else {
//                if ([code isEqualToString:SUCCESS_FLAG]) {
//                    chapter = obj;
//                    chapter.bBuy = [NSNumber numberWithBool:YES];
//                    chapter.content = content;
//                    chapter.bRead = [NSNumber numberWithBool:YES];
//                    _book.lastReadChapterID = chapter.uid;
//                    [chapter persistWithBlock:nil];
//                    [_book persistWithBlock:nil];
//                    [currentChapterString setString:[chapter.content XXSYDecoding]];
//                    [self setPageIndexByChapter:chapter];
//					//TODO
//                    //[self updateContent];
//                    [self hideHUD:YES];
//                } else {
//                    [self displayHUDError:nil message:@"无法下载阅读"];
//                }
//            }
//        }];
//    } else {
//        
//    }
//}

//- (void)setPageIndexByChapter:(Chapter *)obj
//{
//    if ([chapter.lastReadIndex intValue] == 0) {
//        currentPageIndex = 0;
//    } else {
//        currentPageIndex = [self goToIndexWithLastReadPosition:[obj.lastReadIndex intValue]];
//    }
//}

- (void)chapterDidSelectAtIndex:(NSInteger)index
{
	NSLog(@"select a chapter frome chaptersList");
    //[self downloadBookWithIndex:index];
}

@end
