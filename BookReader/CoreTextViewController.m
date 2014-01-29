//
//  CoreTextViewController.m
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "CoreTextViewController.h"
#import "CoreTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+HUD.h"
#import "ReadStatusView.h"
#import "BookReadMenuView.h"
#import "NSString+XXSY.h"
#import "ServiceManager.h"
#import "ReadHelpView.h"
#import "Mark.h"
#import "NSString+ZBUtilites.h"
#import "SignInViewController.h"
#import "AppDelegate.h"
#import "BookDetailsViewController.h"
#import "WebViewController.h"
#import "PopLoginViewController.h"
#import "NSString+XXSY.h"
#import "BRChapterNameView.h"
#import "CommentViewController.h"
#import "NSString+ZBUtilites.h"
#import "SignUpViewController.h"

static NSString *kPageCurl = @"pageCurl";
static NSString *kPageUnCurl = @"pageUnCurl";

@interface CoreTextViewController () <BookReadMenuViewDelegate, ChapterViewDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, PopLoginViewControllerDelegate, UIAlertViewDelegate, SignUpViewControllerDelegate, WebViewControllerDelegate>

@property (readwrite) MFMessageComposeViewController *messageComposeViewController;
@property (readwrite) NSInteger startPointX;
@property (readwrite) NSInteger startPointY;
@property (readwrite) CoreTextView *coreTextView;
@property (readwrite) ReadStatusView *statusView;
@property (readwrite) BookReadMenuView *menuView;
@property (readwrite) CGRect menuRect;
@property (readwrite) CGRect nextRect;
@property (readwrite) NSMutableArray *pages;
@property (readwrite) NSInteger currentPageIndex;
@property (readwrite) NSString *currentChapterString;
@property (readwrite) BOOL isLandscape;
@property (readwrite) BOOL firstAppear;
@property (readwrite) UIView *backgroundView;
@property (readwrite) NSString *pageCurlType;
@property (readwrite) BOOL enterChapterIsVIP;
@property (readwrite) CommentViewController *commentViewController;
@property (readwrite) CGSize fullSize;
@property (readwrite) Chapter *webSubscribeChapter;

@end

@implementation CoreTextViewController

- (void)shareButtonClicked
{
    if([MFMessageComposeViewController canSendText]) {
		Book *book = [Book findFirstByAttribute:@"uid" withValue:_chapter.bid];
		if (book) {
			if (!_messageComposeViewController) _messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			_messageComposeViewController.messageComposeDelegate = self;
			NSString *message =  [NSString stringWithFormat:@"《%@》这本书太好看了，作者是\"%@\"，赶紧来阅读吧，潇湘书院iOS版下载地址：%@", book.name, book.author, [NSString appStoreLinkWithAppID:APP_ID]];
			[_messageComposeViewController setBody:[NSString stringWithString:message]];
			[self presentViewController:_messageComposeViewController animated:YES completion:nil];
		}
    } else {
        [self displayHUDTitle:nil message:@"您的设备不能用来发短信！"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self prefersStatusBarHidden];
    _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_backgroundView];
    
    _isLandscape = [[NSUserDefaults brObjectForKey:UserDefaultKeyScreen] isEqualToString:UserDefaultScreenLandscape];
    _firstAppear = YES;
	NSNumber *colorIdx = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
	[self.view setBackgroundColor:[NSUserDefaults brBackgroundColorWithIndex:colorIdx.intValue]];
	
	_currentPageIndex = 0;
	
	_fullSize = self.view.bounds.size;
	
	_menuRect = CGRectMake(_fullSize.width/3, _fullSize.height/4, _fullSize.width/3, _fullSize.height/2);
	_nextRect = CGRectMake(_fullSize.width/2, 0, _fullSize.width/2, _fullSize.height);
    
    _statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, _fullSize.width, 20)];
    [_statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_statusView];
    
    _coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 30, _fullSize.width, _fullSize.height - 30)];
	_coreTextView.font = [NSUserDefaults brObjectForKey:UserDefaultKeyFont];
	_coreTextView.fontSize = [[NSUserDefaults brObjectForKey:UserDefaultKeyFontSize] floatValue];
	NSNumber *textColorNum = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
	_coreTextView.textColor = [NSUserDefaults brTextColorWithIndex:textColorNum.integerValue];
    _statusView.title.textColor = _coreTextView.textColor;
    _statusView.percentage.textColor = _coreTextView.textColor;
    [_coreTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_coreTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_coreTextView];
    
    _menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, _fullSize.width, _fullSize.height)];
    [_menuView setDelegate:self];
    [_menuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_menuView];
    _menuView.hidden = YES;
    
	if (![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultKeyNotFirstRead]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDefaultKeyNotFirstRead];
		[[NSUserDefaults standardUserDefaults] synchronize];
		ReadHelpView *helpView = [[ReadHelpView alloc] initWithFrame:self.view.bounds andMenuFrame:_menuRect];
		[self.view addSubview:helpView];
	}
	_backgroundView.alpha = 1.0 - [[NSUserDefaults brObjectForKey:UserDefaultKeyBright] floatValue];
	
	_enterChapterIsVIP = _chapter.bVip.boolValue;
	
	if (_chapter && !_chapters) {
		_chapters = [Chapter allChaptersOfBookID:_chapter.bid];
	}
	[self gotoChapter:_chapter withReadIndex:nil extra:NO];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChapters) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)updateChapters
{
	Book *book = [Book findFirstByAttribute:@"uid" withValue:_chapter.bid];
	
	if (_menuView) {
		_menuView.favorited = book.bFav.boolValue;
	}
	
	if ([book needUpdate]) {
		[ServiceManager getDownChapterList:book.uid andUserid:[[ServiceManager userID] stringValue] withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
			if (success) {
				
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					Book *b = [Book findFirstByAttribute:@"uid" withValue:book.uid inContext:localContext];
					if (b) {
						if (forbidden) {
							[b deleteInContext:localContext];
						} else {
							b.nextUpdateTime = nextUpdateTime;
						}
					}
				} completion:^(BOOL success, NSError *error) {
					[Chapter persist:resultArray withBlock:nil];
				}];
			}
		}];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	_pageCurlType = nil;
	
	if (_firstAppear) {
		[self updateChapters];
	}
	
    if(_isLandscape && _firstAppear) { //如果系统设置是横屏并且是第一次运行，则进行横屏翻转
        _isLandscape = !_isLandscape;
        [self orientationButtonClicked];
    }
    _firstAppear = NO;
}

- (NSUInteger)goToIndexWithLastReadPosition:(NSNumber *)position
{
	NSInteger index = position ? position.intValue : 0;
	NSUInteger indexCount = 0;
	NSUInteger rtnPageIndex = 0;
	for (int i = 0; i < _pages.count; i++) {
		NSRange range = NSRangeFromString(_pages[i]);
		indexCount += range.length;
		if (index < indexCount) {
			rtnPageIndex = i;
			break;
		}
	}
	return rtnPageIndex;
}

- (void)updateFontSize
{
	[self paging];
    [self updateCurrentPageContent];
}

- (void)updateFontColor
{
	NSNumber *textColorNum = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
    UIColor *textColor = [NSUserDefaults brTextColorWithIndex:[textColorNum integerValue]];
	_coreTextView.textColor = textColor;
    _statusView.title.textColor = textColor;
    _statusView.percentage.textColor = textColor;
	[self paging];
    [self updateCurrentPageContent];
}

- (void)updateFont
{
	[self paging];
    [self updateCurrentPageContent];
}

- (void)paging
{
	_coreTextView.font = [NSUserDefaults brObjectForKey:UserDefaultKeyFont];
    _coreTextView.fontSize = [[NSUserDefaults brObjectForKey:UserDefaultKeyFontSize] floatValue];
	NSAssert(_currentChapterString != nil, @"currentChapterString == nil when paging....");
	_pages = [[_currentChapterString pagesWithFont:_coreTextView.font inSize:_coreTextView.frame.size] mutableCopy];
}

- (void)updateCurrentPageContent
{
	NSAssert(_currentChapterString != nil, @"currentChapterString == nil when updateCurrentPageContent...");
	NSRange range = NSRangeFromString(_pages[_currentPageIndex]);
	_statusView.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self readPercentage]];
	NSString *currentPageString = [_currentChapterString substringWithRange:range];
	NSAssert(currentPageString != nil, @"currentPageString == nil");
	[_coreTextView buildTextWithString:currentPageString];
	[_coreTextView setNeedsDisplay];
	_chapter.lastReadIndex = @(range.location);
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Chapter *chapter = [Chapter findFirstByAttribute:@"uid" withValue:_chapter.uid inContext:localContext];
		if (chapter) {
			chapter.lastReadIndex = @(range.location);
		}
	}];
}

#pragma mark - MenuView Delegate

- (void)willAddFav
{
	if (![ServiceManager isSessionValid]) {
		if ([ServiceManager showDialogs]) {
			[self showPopLogin];
		} else {
			[self displayHUDTitle:@"操作失败" message:nil];
		}
		return;
	};

	Book *book = [Book findFirstByAttribute:@"uid" withValue:_chapter.bid];
	if (book) {
		[ServiceManager addFavoriteWithBookID:book.uid On:YES withBlock:^(BOOL success, NSError *error, NSString *message) {
			if (success) {
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					book.bFav = @(YES);
				}];
				_menuView.favorited = YES;
			}
		}];
	}
}

- (void)brightChanged:(UISlider *)slider
{
	[NSUserDefaults brSetObject:@(slider.value) ForKey:UserDefaultKeyBright];
    _backgroundView.alpha = 1.0 - slider.value;
}

- (void)backgroundColorChanged:(NSInteger)index
{
    [NSUserDefaults brSetObject:@(index) ForKey:UserDefaultKeyBackground];
    [self.view setBackgroundColor:[NSUserDefaults brBackgroundColorWithIndex:index]];
    [self updateFontColor];
}

- (void)fontChanged:(BOOL)reduce
{
	CGFloat currentFontSize = [[NSUserDefaults brObjectForKey:UserDefaultKeyFontSize] floatValue];
	currentFontSize += reduce ? -1 : 1;
	if (currentFontSize < UserDefaultFontSizeMin.floatValue || currentFontSize > UserDefaultFontSizeMax.floatValue) {
		NSString *errorMessage = [NSString stringWithFormat:@"字体已达到最%@", reduce ? @"小" : @"大"];
		[self displayHUDTitle:nil message:errorMessage];
		return;
	}
	[NSUserDefaults brSetObject:@(currentFontSize) ForKey:UserDefaultKeyFontSize];
	[self updateFontSize];
}

- (void)systemFont
{
	[NSUserDefaults brSetObject:UserDefaultSystemFont ForKey:UserDefaultKeyFontName];
    [self updateFont];
}

- (void)foundFont
{
	[NSUserDefaults brSetObject:UserDefaultFoundFont ForKey:UserDefaultKeyFontName];
    [self updateFont];
}

- (void)northFont
{
    [NSUserDefaults brSetObject:UserDefaultNorthFont ForKey:UserDefaultKeyFontName];
    [self updateFont];
}

- (void)realPaging
{
    [NSUserDefaults brSetObject:UserDefaultRealPage ForKey:UserDefaultKeyPage];
}

- (void)simplePaging
{
    [NSUserDefaults brSetObject:UserDefaultSimplePage ForKey:UserDefaultKeyPage];
}

#pragma mark -
#pragma mark other methods
- (float)readPercentage
{
	if (_pages.count == 0) {
		return 100.0f;
	} else if (_currentPageIndex == 0) {
		return 0.0f;
	}
	return ((float)(_currentPageIndex + 1) / _pages.count) * 100.0f;
}

- (void)previousPage
{
	_pageCurlType = [[NSUserDefaults brObjectForKey:UserDefaultKeyPage] isEqualToString:UserDefaultRealPage] ? kPageUnCurl : kCATransitionPush;
    _currentPageIndex--;
    if(_currentPageIndex < 0) {
        _currentPageIndex = 0;
		NSLog(@"no more previous page!");
		[self gotoPreviousChapter];
        return;
    }
	[self updateCurrentPageContent];
	[self playPageCurlAnimation:[_pageCurlType isEqualToString:kPageUnCurl] ? YES : NO];
}

- (void)playPageCurlAnimation:(BOOL)bRight
{
	if (_pageCurlType) {
		if (_isLandscape) {
			[self performTransition:bRight ? kCATransitionFromTop : kCATransitionFromBottom andType:_pageCurlType];
		} else {
			[self performTransition:bRight ? kCATransitionFromRight : kCATransitionFromLeft andType:_pageCurlType];
		}
	}
}

- (void)nextPage
{
	_pageCurlType = 	_pageCurlType = [[NSUserDefaults brObjectForKey:UserDefaultKeyPage] isEqualToString:UserDefaultRealPage] ? kPageCurl : kCATransitionPush;;
    _currentPageIndex++;
    if(_currentPageIndex > _pages.count - 1) {
        _currentPageIndex = _pages.count - 1;
		NSLog(@"no more next page!");
		[self gotoNextChapter];
        return;
    }
	[self updateCurrentPageContent];
	[self playPageCurlAnimation:YES];
}

- (void)back
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)showChapterName:(Chapter *)chapter
{
	NSArray *subViews = [self.view subviews];
	for (UIView *sView in subViews) {
		if ([sView isKindOfClass:[BRChapterNameView class]]) {
			[sView removeFromSuperview];
		}
	}
	BRChapterNameView *chapterNameView = [[BRChapterNameView alloc] initWithFrame:self.view.bounds];
    [chapterNameView setUserInteractionEnabled:NO];
	chapterNameView.chapter = chapter;
	[self.view addSubview:chapterNameView];
}

- (void)gotoChapter:(Chapter *)aChapter withReadIndex:(NSNumber *)readIndex extra:(BOOL)extra
{
	if (!aChapter) {
		[self displayHUDTitle:@"错误" message:@"获取章节失败"];
		[self performSelector:@selector(back) withObject:nil afterDelay:1.5];
		return;
	}
	if (aChapter.content) {
		_chapter = aChapter;
		_currentChapterString = [_chapter.content XXSYDecoding];

		[self showChapterName:_chapter];
		
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Book *book = [Book findFirstByAttribute:@"uid" withValue:_chapter.bid inContext:localContext];
			if (book) {
				book.lastReadChapterID = _chapter.uid;
                book.lastReadDate = [NSDate date];
				book.localUpdateDate = [NSDate date];
				book.numberOfUnreadChapters = @([Chapter countOfUnreadChaptersOfBook:book]);
			}
		}];
		_statusView.title.text = _chapter.name;
		[self paging];
		NSNumber *startReadIndex = readIndex ? readIndex : _chapter.lastReadIndex;
		_currentPageIndex = [self goToIndexWithLastReadPosition:startReadIndex];
		[self updateCurrentPageContent];
		[self playPageCurlAnimation:YES];
	} else {
		[self displayHUD:@"获取章节内容..."];
		[ServiceManager bookCatalogue:aChapter.uid VIP:aChapter.bVip.boolValue  extra:extra withBlock:^(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
			[self hideHUD:YES];
			if (success) {
				aChapter.content = content;
				aChapter.previousID = previousID;
				aChapter.nextID = nextID;
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					Chapter *tmpChapter = [Chapter findFirstByAttribute:@"uid" withValue:aChapter.uid inContext:localContext];
					if (tmpChapter) {
						tmpChapter.content = content;
						tmpChapter.previousID = previousID;
						tmpChapter.nextID = nextID;
					}
				}];
				[self gotoChapter:aChapter withReadIndex:nil extra:NO];
			} else {//没下载到，尝试订阅
				Book *book = [Book findFirstByAttribute:@"uid" withValue:aChapter.bid];
				if (!book) return;
				_webSubscribeChapter = aChapter;
				
				WebViewController *webViewController = [[WebViewController alloc] init];
				webViewController.delegate = self;
				webViewController.chapter = _webSubscribeChapter;
				webViewController.fromWhere = kFromSubscribe;
				
				NSNumber *userID = [ServiceManager isSessionValid] ? [ServiceManager userID] : @(0);
				webViewController.urlString = [NSString stringWithFormat:@"%@?userid=%@&chapterid=%@&version=%@", kXXSYSubscribeUrlString, userID, _webSubscribeChapter.uid, [NSString appVersion]];
				webViewController.popTarget = self;
				if (_enterChapterIsVIP) {
					webViewController.popTarget = _previousViewController;
				}
				[self.navigationController performSelector:@selector(pushViewController:animated:) withObject:webViewController afterDelay:1];
			}
		}];
	}
}

- (void)menu
{
    _startPointX = NSIntegerMax;
    _startPointY = NSIntegerMax;
	_menuView.hidden = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *start = [[event allTouches] anyObject];
    CGPoint startPoint = [start locationInView:self.view];
    _startPointX = startPoint.x;
    _startPointY = startPoint.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *end = [[event allTouches] anyObject];
    CGPoint endPoint = [end locationInView:self.view];
    if (_startPointX == NSIntegerMax || _startPointY == NSIntegerMax) {
        return;
    }
    if (!_menuView.hidden) {
        _menuView.hidden = YES;
        [_menuView hidenAllMenu];
        return;
    }
    
	//swipe
	if (fabsf(endPoint.x - _startPointX) >= 9) {
		if (endPoint.x > _startPointX ) {
			[self previousPage];
		}else {
			[self nextPage];
		}
		return;
	}
	
	//tap
	if (CGRectContainsPoint(_menuRect, endPoint)) {
		[self menu];
		return;
	}
	
	if (CGRectContainsPoint(_nextRect, endPoint)) {
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
    [self resetScreenToVer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBookMarkButtonPressed
{
    [self displayHUDTitle:@"" message:@"添加书签成功"];
	NSRange range = NSRangeFromString(_pages[_currentPageIndex]);
	NSString *reference = [_currentChapterString substringFromIndex:range.location];
	NSLog(@"before referenct = %@", reference);
	reference = [reference stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	reference = [reference stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	reference = [reference stringByReplacingOccurrencesOfString:[NSString ChineseSpace] withString:@""];
	reference = [reference stringByReplacingOccurrencesOfString:@" " withString:@""];
	reference = [reference substringToIndex:40];
	NSLog(@"referenct = %@", reference);
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Mark *mark = [Mark createInContext:localContext];
		mark.chapterID = _chapter.uid;
		mark.chapterName = _chapter.name;
		mark.reference = reference;
		mark.startWordIndex = @(range.location);
		mark.progress = @([self readPercentage]);
	}];
}

- (void)chaptersButtonClicked
{
    ChaptersViewController *controller = [[ChaptersViewController alloc] init];
	controller.chapter = _chapter;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)gotoPreviousChapter
{
	NSLog(@"_chapter: %@", _chapters);
	if (!_chapter.previousID || !_chapter.previousID.intValue) {
		[self displayHUDTitle:@"" message:@"此章是第一章"];
		return;
	}
	_pageCurlType = nil;
	
	Chapter *preChapter = [_chapter previous];
	if (!preChapter) {
		preChapter = [self findChapterWithID:_chapter.previousID];
	}
	[self gotoChapter:preChapter withReadIndex:nil extra:NO];
}

- (Chapter *)findChapterWithID:(NSString *)chapterID
{
	if (!chapterID) return nil;
	for (Chapter *c in _chapters) {
		if ([chapterID isEqualToString:c.uid]) {
			return c;
		}
	}
	return nil;
}

- (void)gotoNextChapter
{
	if (!_chapter.nextID || !_chapter.nextID.intValue) {
		[self displayHUDTitle:@"" message:@"此章是最后一章"];
		return;
	}
	_pageCurlType = nil;
	
	Chapter *nextChapter = [_chapter next];
	if (!nextChapter) {
		nextChapter = [self findChapterWithID:_chapter.nextID];
	}
	[self gotoChapter:nextChapter withReadIndex:nil extra:NO];
}

#pragma mark -
- (void)didSelect:(id)selected
{
	_pageCurlType = nil;
	if ([selected isKindOfClass:[Chapter class]]) {
		[self gotoChapter:selected withReadIndex:nil extra:NO];
	} else if ([selected isKindOfClass:[Mark class]]){
		NSLog(@"selected a mark");
		Mark *mark = (Mark *)selected;
		Chapter *aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", mark.chapterID]];
		[self gotoChapter:aChapter withReadIndex:mark.startWordIndex extra:NO];
	}
}

- (void)showCommitAlert
{
    if (![ServiceManager isSessionValid]) {
		if ([ServiceManager showDialogs]) {
			[self showPopLogin];
		} else {
			[self displayHUDTitle:@"操作失败" message:nil];
		}
        return;
    }
	_commentViewController = [[CommentViewController alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _commentViewController.bookId = _chapter.bid;
    [self.view addSubview:_commentViewController.view];
}

- (void)commitButtonClicked
{
    [self showCommitAlert];
}

- (void)resetButtonClicked
{
    [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookShelf];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)resetScreenToVer
{
	[self changeToOrientation:UIInterfaceOrientationPortrait];
	
    if (_currentChapterString) {
        [self paging];
        [self updateCurrentPageContent];
    }
    _menuRect = CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/4, self.view.bounds.size.width/3, self.view.bounds.size.height/2);
    _nextRect = CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width/2, self.view.bounds.size.height);
}

- (void)orientationButtonClicked
{
    NSLog(@"----%@----", _isLandscape ? @"横屏变竖屏" : @"竖屏变横屏");
	_isLandscape = !_isLandscape;
	UIInterfaceOrientation orientation = _isLandscape ? UIInterfaceOrientationLandscapeRight :UIInterfaceOrientationPortrait;
	[self changeToOrientation:orientation];
	
	NSString *value = _isLandscape ? UserDefaultScreenLandscape : UserDefaultScreenPortrait;
	[NSUserDefaults brSetObject:value ForKey:UserDefaultKeyScreen];

	if (_currentChapterString) {
		[self paging];
		[self updateCurrentPageContent];
	}
	
    _menuRect = CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/4, self.view.bounds.size.width/3, self.view.bounds.size.height/2);
    _nextRect = CGRectMake(self.view.bounds.size.width/2, 0, self.view.bounds.size.width/2, self.view.bounds.size.height);
    NSNumber *colorIdx = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
    [self.view setBackgroundColor:[NSUserDefaults brBackgroundColorWithIndex:colorIdx.intValue]];
}

- (void)changeToOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	[[UIApplication sharedApplication] setStatusBarOrientation:toInterfaceOrientation];
	NSInteger factor = 1;
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		factor = 0;
	}
	self.view.transform = CGAffineTransformMakeRotation(M_PI/2 * factor);
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		self.view.bounds = CGRectMake(0, 0, _fullSize.width, _fullSize.height);
	} else {
		self.view.bounds = CGRectMake(0, 0, _fullSize.height, _fullSize.width);
	}
}

- (void)showPopLogin
{
	PopLoginViewController *popLoginViewController = [[PopLoginViewController alloc] initWithFrame:self.view.bounds];
	popLoginViewController.delegate = self;
	[self addChildViewController:popLoginViewController];
	[self.view addSubview:popLoginViewController.view];
}

- (void)bookDetailButtonClick
{
    [self resetScreenToVer];
    _firstAppear = YES;
    BookDetailsViewController *controller = [[BookDetailsViewController alloc] initWithBook:_chapter.bid];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - PopLoginViewControllerDelegate

- (void)popLoginDidLogin
{
	//如果从其他界面进入时候传进来的章节是vip章节，如取消登录则需要返回之前的界面，如登录则需要订阅该章节
	if (_enterChapterIsVIP) {
		[self gotoChapter:_chapter withReadIndex:nil extra:NO];
	}
}

- (void)popLoginDidCancel
{
	//如果从其他界面进入时候传进来的章节是vip章节，如取消登录则需要返回之前的界面，如登录则需要订阅该章节
	if (_enterChapterIsVIP) {
		[self back];
	}
}

- (void)popLoginWillSignup
{
	WebViewController *webViewController = [[WebViewController alloc] init];
	webViewController.fromWhere = kFromLogin;
	webViewController.urlString = [NSString stringWithFormat:@"%@?version=%@", kXXSYRegisterUrlString, [NSString appVersion]];
	NSLog(@"urlString: %@", webViewController.urlString);
	[self.navigationController pushViewController:webViewController animated:YES];
//	SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
//	signUpViewController.delegate = self;
//	[self.navigationController pushViewController:signUpViewController animated:YES];
}

#pragma mark - SignUpViewControllerDelegate

- (void)signUpDone:(SignUpViewController *)signUpViewController
{
	[signUpViewController backOrClose];
}

#pragma mark - WebViewControllerDelegate

- (void)didSubscribe:(Chapter *)chapter
{
	Chapter *aChapter = [Chapter findFirstByAttribute:@"uid" withValue:chapter.uid];
	[self gotoChapter:aChapter withReadIndex:nil extra:YES];
}

@end
