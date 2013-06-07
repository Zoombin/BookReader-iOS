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

    NSMutableArray *pages;
    NSInteger currentPageIndex;
	NSInteger currentReadIndex;
    Chapter *chapter;
	NSString *currentChapterString;
}

- (void)shareButtonClicked
{
    if([MFMessageComposeViewController canSendText]) {
        messageComposeViewController.messageComposeDelegate = self;
        NSString *message =  [NSString stringWithFormat:@"书名:%@ 作者:%@ 下载地址:http://www.xxsy.net",_book.name,_book.author];
        [messageComposeViewController setBody:[NSString stringWithString:message]];
        [self presentModalViewController:messageComposeViewController animated:YES];
    }
    else {
        [self displayHUDError:nil message:@"您的设备不能用来发短信！"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
		case MessageComposeResultCancelled:
			break;
		case MessageComposeResultSent:
			break;
		case MessageComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([MFMessageComposeViewController canSendText]) {
        messageComposeViewController = [[MFMessageComposeViewController alloc] init];
    }
	NSNumber *colorIdx = [BookReaderDefaultsManager objectForKey:UserDefaultKeyBackground];
	[self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:colorIdx.intValue]];
	
	currentPageIndex = 0;
	
	CGSize size = self.view.bounds.size;
	
	menuRect = CGRectMake(size.width/3, size.height/4, size.width/3, size.height/2);
	nextRect = CGRectMake(size.width/2, 0, size.width/2, size.height);
    
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, size.width, 20)];
    [statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusView];
    
    coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 20, size.width, size.height - 40)];
	coreTextView.font = [BookReaderDefaultsManager objectForKey:UserDefaultKeyFont];
	coreTextView.fontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] floatValue];
	NSString *textColorString = [BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor];
	coreTextView.textColor = [UIColor performSelector:NSSelectorFromString(textColorString)];
    statusView.title.textColor = [UIColor performSelector:NSSelectorFromString(textColorString)];
    statusView.percentage.textColor = [UIColor performSelector:NSSelectorFromString(textColorString)];
    [coreTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:coreTextView];
    
    menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [menuView setDelegate:self];
    [menuView setBackgroundColor:[UIColor clearColor]];
	//TODO:targe
    [self.view addSubview:menuView];
    menuView.hidden = YES;

	//if (YES) {//TOTEST
	if (![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultKeyNotFirstRead]) {
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
	
	_book = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", _book.uid]];
	
	if (_book.lastReadChapterID) {//最近读过
		aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", _book.lastReadChapterID]];
	} else {//没读过，从第0章开始
		aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=0", _book.uid]];
	}
	
	NSLog(@"start to read book: %@,  chapter: %@", _book, aChapter);
	[self gotoChapter:aChapter];
}

- (NSUInteger)goToIndexWithLastReadPosition:(NSInteger)index
{
	__block NSUInteger indexCount = 0;
	__block NSUInteger rtnPageIndex = 0;
	[pages enumerateObjectsUsingBlock:^(NSString *rangeString, NSUInteger idx, BOOL *stop) {
		NSRange range = NSRangeFromString(rangeString);
		indexCount += range.length;
		if (index <= indexCount) {
			rtnPageIndex = idx;
			*stop = YES;
		}
	}];
	if (rtnPageIndex > pages.count - 1) {
		rtnPageIndex = pages.count - 1;
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
	[self paging];
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
    coreTextView.fontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] floatValue];
	NSAssert(currentChapterString != nil, @"currentChapterString == nil when paging....");
	pages = [[currentChapterString pagesWithFont:coreTextView.font inSize:coreTextView.frame.size] mutableCopy];
}

- (void)updateCurrentPageContent
{
	NSAssert(currentChapterString != nil, @"currentChapterString == nil when updateCurrentPageContent...");
	NSRange range = NSRangeFromString(pages[currentPageIndex]);
	statusView.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self readPercentage]];
	NSString *currentPageString = [currentChapterString substringWithRange:range];
	NSAssert(currentPageString != nil, @"currentPageString == nil");
	[coreTextView buildTextWithString:currentPageString];
	[coreTextView setNeedsDisplay];
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Chapter *aChapter = [Chapter findFirstInContext:localContext];
		aChapter.lastReadIndex = @(range.location);
	}];
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
    [BookReaderDefaultsManager setObject:@(index) ForKey:UserDefaultKeyBackground];
    [self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:index]];
}

- (void)changeTextColor:(NSString *)textColor
{
	[BookReaderDefaultsManager setObject:textColor ForKey:UserDefaultKeyTextColor];
	[self updateFontColor];
}

- (void)fontChanged:(BOOL)reduce
{
	CGFloat currentFontSize = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontSize] floatValue];
	currentFontSize += reduce ? -1 : 1;
	if (currentFontSize < UserDefaultFontSizeMin.floatValue || currentFontSize > UserDefaultFontSizeMax.floatValue) {
		NSString *errorMessage = [NSString stringWithFormat:@"字体已达到最%@", reduce ? @"小" : @"大"];
		[self displayHUDError:nil message:errorMessage];
		return;
	}
	[BookReaderDefaultsManager setObject:@(currentFontSize) ForKey:UserDefaultKeyFontSize];
	[self updateFontSize];
}

- (void)systemFont
{
	[BookReaderDefaultsManager setObject:UserDefaultSystemFont ForKey:UserDefaultKeyFontName];
    [self updateFont];
}

- (void)foundFont
{
	[BookReaderDefaultsManager setObject:UserDefaultFoundFont ForKey:UserDefaultKeyFontName];
    [self updateFont];
}

#pragma mark -
#pragma mark other methods
- (float)readPercentage
{
	if (pages.count == 0) {
		return 100.0f;
	} else if (currentPageIndex == 0) {
		return 0.0f;
	}
	return ((float)(currentPageIndex + 1) / pages.count) * 100.0f;
}

- (void)previousPage
{
    currentPageIndex--;
    if(currentPageIndex < 0) {
        currentPageIndex = 0;
		NSLog(@"no more previous page!");
		if ([chapter.index intValue] == 0) {
			[self displayHUDError:@"" message:@"此章是第一章"];
		} else {
			[self displayHUDError:@"" message:@"上一章"];
			[self gotoChapter:[chapter previous]];
		}
        return;
    }
	[self updateCurrentPageContent];
	[self performTransition:kCATransitionFromRight andType:@"pageUnCurl"];
}

- (void)nextPage
{
    currentPageIndex++;
    if(currentPageIndex > [pages count] - 1) {
        currentPageIndex = [pages count] - 1;
		NSLog(@"no more next page!");
		[self displayHUDError:@"" message:@"下一章"];
		[self gotoChapter:[chapter next]];
        return;
    }
	[self updateCurrentPageContent];
	[self performTransition:kCATransitionFromRight andType:@"pageCurl"];
}

- (void)pop
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoChapter:(Chapter *)aChapter
{
	chapter = aChapter;
	if (!chapter) {
		[self displayHUDError:@"错误" message:@"获取章节目录失败"];
		[self performSelector:@selector(pop) withObject:nil afterDelay:1.5];
		return;
	}
	if (chapter.content) {
		chapter = aChapter;
		currentChapterString = [chapter.content XXSYDecodingRelatedVIP:chapter.bVip.boolValue];
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			chapter.bRead = @(YES);
			_book.lastReadChapterID = chapter.uid;
		}];
		statusView.title.text = chapter.name;
		currentReadIndex = chapter.lastReadIndex ? [chapter.lastReadIndex integerValue] : 0;
		currentPageIndex = [self goToIndexWithLastReadPosition:currentReadIndex];
		[self paging];
		[self updateCurrentPageContent];
	} else {
		[self displayHUD:@"获取章节内容..."];
		[ServiceManager bookCatalogue:aChapter.uid VIP:NO withBlock:^(NSString *content, BOOL success, NSString *message, NSError *error) {
			if (content && ![content isEqualToString:@""]) {
				[self hideHUD:YES];
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					chapter.content = content;
					[self gotoChapter:chapter];
				}];
			} else {//没下载到，尝试订阅
				[ServiceManager chapterSubscribeWithChapterID:aChapter.uid book:aChapter.bid author:_book.authorID withBlock:^(NSString *content, NSString *message, BOOL success, NSError *error) {
					[self hideHUD:YES];
					if (content && ![content isEqualToString:@""]) {
						[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
							chapter.content = content;
							[self gotoChapter:chapter];
						}];
					} else {
						[self displayHUDError:@"错误" message:@"无法阅读该章节"];//又没下载到又没有订阅到
					}
				}];
			}
		}];
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
    if (!menuView.hidden) {
        menuView.hidden = YES;
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
	[self gotoChapter:[chapter previous]];
}

- (void)nextChapterButtonClick
{
	[self gotoChapter:[chapter next]];
}

- (void)chapterDidSelectAtIndex:(NSInteger)index
{
	NSLog(@"select a chapter frome chaptersList");
    //[self downloadBookWithIndex:index];
}

@end
