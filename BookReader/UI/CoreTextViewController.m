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
#import "NavViewController.h"
#import "Mark.h"
#import "NSString+ZBUtilites.h"
#import "SignInViewController.h"
#import "AppDelegate.h"
#import "BookDetailsViewController.h"
#import "WebViewController.h"
#import "PopLoginViewController.h"
#import "NSString+XXSY.h"
#import "BRChapterNameView.h"
#import "NSString+ZBUtilites.h"

static NSString *kPageCurl = @"pageCurl";
static NSString *kPageUnCurl = @"pageUnCurl";

@interface CoreTextViewController() <BookReadMenuViewDelegate, ChapterViewDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, PopLoginViewControllerDelegate>

@end

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
	NSString *currentChapterString;
    BOOL isLandscape;
    BOOL firstAppear;
    UIView *backgroundView;
	NSString *pageCurlType;
	BOOL enterChapterIsVIP;
    CommentView *commentView;
}

- (void)shareButtonClicked
{
    if([MFMessageComposeViewController canSendText]) {
		Book *book = [Book findFirstByAttribute:@"uid" withValue:_chapter.bid];
		if (book) {
			MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
			messageComposeViewController.messageComposeDelegate = self;			
			NSString *message =  [NSString stringWithFormat:@"《%@》这本书太好看了，作者是\"%@\"，赶紧来阅读吧，潇湘书院iOS版下载地址：%@", book.name, book.author, [NSString appStoreLinkWithAppID:APP_ID]];
			[messageComposeViewController setBody:[NSString stringWithString:message]];
			[self presentViewController:messageComposeViewController animated:YES completion:nil];
		}
    } else {
        [self displayHUDError:nil message:@"您的设备不能用来发短信！"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:backgroundView];
    
    isLandscape = [[NSUserDefaults brObjectForKey:UserDefaultKeyScreen] isEqualToString:UserDefaultScreenLandscape];
    firstAppear = YES;
	NSNumber *colorIdx = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
	[self.view setBackgroundColor:[NSUserDefaults brBackgroundColorWithIndex:colorIdx.intValue]];
	
	currentPageIndex = 0;
	
	CGSize size = self.view.bounds.size;
	
	menuRect = CGRectMake(size.width/3, size.height/4, size.width/3, size.height/2);
	nextRect = CGRectMake(size.width/2, 0, size.width/2, size.height);
    
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, size.width, 20)];
    [statusView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:statusView];
    
    coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 30, size.width, size.height - 30)];
	coreTextView.font = [NSUserDefaults brObjectForKey:UserDefaultKeyFont];
	coreTextView.fontSize = [[NSUserDefaults brObjectForKey:UserDefaultKeyFontSize] floatValue];
	NSNumber *textColorNum = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
	coreTextView.textColor = [NSUserDefaults brTextColorWithIndex:textColorNum.integerValue];
    statusView.title.textColor = coreTextView.textColor;
    statusView.percentage.textColor = coreTextView.textColor;
    [coreTextView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [coreTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:coreTextView];
    
    menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [menuView setDelegate:self];
    [menuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:menuView];
    menuView.hidden = YES;
    
	//if (YES) {//TOTEST
	if (![[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultKeyNotFirstRead]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:UserDefaultKeyNotFirstRead];
		[[NSUserDefaults standardUserDefaults] synchronize];
		ReadHelpView *helpView = [[ReadHelpView alloc] initWithFrame:self.view.bounds andMenuFrame:menuRect];
		[self.view addSubview:helpView];
	}
	backgroundView.alpha = 1.0 - [[NSUserDefaults brObjectForKey:UserDefaultKeyBright] floatValue];
	
	enterChapterIsVIP = _chapter.bVip.boolValue;
	
	[self gotoChapter:_chapter withReadIndex:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	NSLog(@"start to read chapter: %@", _chapter);
	pageCurlType = nil;
	
    if(isLandscape && firstAppear) { //如果系统设置是横屏并且是第一次运行，则进行横屏翻转
        isLandscape = !isLandscape;
        [self orientationButtonClicked];
    }
    firstAppear = NO;
}

- (NSUInteger)goToIndexWithLastReadPosition:(NSNumber *)position
{
	NSInteger index = position ? position.intValue : 0;
	NSUInteger indexCount = 0;
	NSUInteger rtnPageIndex = 0;
	for (int i = 0; i < pages.count; i++) {
		NSRange range = NSRangeFromString(pages[i]);
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
	coreTextView.textColor = textColor;
    statusView.title.textColor = textColor;
    statusView.percentage.textColor = textColor;
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
	coreTextView.font = [NSUserDefaults brObjectForKey:UserDefaultKeyFont];
    coreTextView.fontSize = [[NSUserDefaults brObjectForKey:UserDefaultKeyFontSize] floatValue];
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
	_chapter.lastReadIndex = @(range.location);
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Chapter *chapter = [Chapter findFirstByAttribute:@"uid" withValue:_chapter.uid inContext:localContext];
		if (chapter) {
			chapter.lastReadIndex = @(range.location);
		}
	}];
}

#pragma mark-
#pragma mark MenuView Delegate
- (void)brightChanged:(UISlider *)slider
{
	[NSUserDefaults brSetObject:@(slider.value) ForKey:UserDefaultKeyBright];
    backgroundView.alpha = 1.0 - slider.value;
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
		[self displayHUDError:nil message:errorMessage];
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
	pageCurlType = kPageUnCurl;
    currentPageIndex--;
    if(currentPageIndex < 0) {
        currentPageIndex = 0;
		NSLog(@"no more previous page!");
		[self gotoPreviousChapter];
        return;
    }
	[self updateCurrentPageContent];
	[self playPageCurlAnimation];
}

- (void)playPageCurlAnimation
{
	if (pageCurlType) [self performTransition:kCATransitionFromRight andType:pageCurlType];
}

- (void)nextPage
{
	pageCurlType = kPageCurl;
    currentPageIndex++;
    if(currentPageIndex > [pages count] - 1) {
        currentPageIndex = [pages count] - 1;
		NSLog(@"no more next page!");
		[self gotoNextChapter];
        return;
    }
	[self updateCurrentPageContent];
	[self playPageCurlAnimation];
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

- (void)gotoChapter:(Chapter *)aChapter withReadIndex:(NSNumber *)readIndex
{
	if (!aChapter) {
		[self displayHUDError:@"错误" message:@"获取章节失败"];
		[self performSelector:@selector(back) withObject:nil afterDelay:1.5];
		return;
	}
	if (aChapter.content) {
		_chapter = aChapter;
		currentChapterString = [_chapter.content XXSYDecoding];

		[self showChapterName:_chapter];
		
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Book *book = [Book findFirstByAttribute:@"uid" withValue:_chapter.bid inContext:localContext];
			if (book) {
				book.lastReadChapterID = _chapter.uid;
				book.localUpdateDate = [NSDate date];
				book.numberOfUnreadChapters = @([Chapter countOfUnreadChaptersOfBook:book]);
			}
		}];
		statusView.title.text = _chapter.name;
		[self paging];
		NSNumber *startReadIndex = readIndex ? readIndex : _chapter.lastReadIndex;
		currentPageIndex = [self goToIndexWithLastReadPosition:startReadIndex];
		[self updateCurrentPageContent];
		[self playPageCurlAnimation];
	} else {
		[self displayHUD:@"获取章节内容..."];
		[ServiceManager bookCatalogue:aChapter.uid VIP:aChapter.bVip.boolValue withBlock:^(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
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
				[self gotoChapter:aChapter withReadIndex:nil];
			} else {//没下载到，尝试订阅
				if (![ServiceManager isSessionValid]) {
					NSLog(@"尚未登录无法阅读");
					PopLoginViewController *popLoginViewController = [[PopLoginViewController alloc] init];
					popLoginViewController.delegate = self;
					if (enterChapterIsVIP) {//如果从其他界面进入时候传进来的章节是vip章节，如取消登录则需要返回之前的界面，如登录则需要订阅该章节
						popLoginViewController.actionAfterCancel = @selector(back);
						popLoginViewController.actionAfterLogin = @selector(didLogin);
					}
					[self addChildViewController:popLoginViewController];
					[self.view addSubview:popLoginViewController.view];
					return;
				}
				Book *book = [Book findFirstByAttribute:@"uid" withValue:aChapter.bid];
				if (!book) return;
				[self displayHUD:@"订阅章节内容..."];
				[ServiceManager chapterSubscribeWithChapterID:aChapter.uid book:aChapter.bid author:book.authorID withBlock:^( BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
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
						[self gotoChapter:aChapter withReadIndex:nil];
					} else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无法阅读该章节" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"详情", nil];
                        [alertView show];
					}
				}];
			}
		}];
	}
}

- (void)didLogin
{
	[self gotoChapter:_chapter withReadIndex:nil];
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
        [menuView hidenAllMenu];
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
    [self resetScreenToVer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBookMarkButtonPressed
{
    [self displayHUDError:@"" message:@"添加书签成功"];
	NSRange range = NSRangeFromString(pages[currentPageIndex]);
	NSString *reference = [currentChapterString substringFromIndex:range.location];
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
	if (!_chapter.previousID || !_chapter.previousID.intValue) {
		[self displayHUDError:@"" message:@"此章是第一章"];
		return;
	}
	pageCurlType = nil;
	[self gotoChapter:[_chapter previous] withReadIndex:nil];
}

- (void)gotoNextChapter
{
	if (!_chapter.nextID || !_chapter.nextID.intValue) {
		[self displayHUDError:@"" message:@"此章是最后一章"];
		return;
	}
	pageCurlType = nil;
	[self gotoChapter:[_chapter next] withReadIndex:nil];
}

#pragma mark -
- (void)didSelect:(id)selected
{
	pageCurlType = nil;
	if ([selected isKindOfClass:[Chapter class]]) {
		[self gotoChapter:selected withReadIndex:nil];
	} else if ([selected isKindOfClass:[Mark class]]){
		NSLog(@"selected a mark");
		Mark *mark = (Mark *)selected;
		Chapter *aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", mark.chapterID]];
		[self gotoChapter:aChapter withReadIndex:mark.startWordIndex];
	}
}

- (void)showCommitAlert
{
    if (![ServiceManager isSessionValid]) {
        [self showLoginAlert];
        return;
    }
     commentView = [[CommentView alloc] init];
     commentView.delegate = self;
    [commentView show];
}

- (void)sendButtonClicked
{
   [self sendCommitButtonClicked]; 
}

- (void)commitButtonClicked
{
    [self showCommitAlert];
}

- (void)resetButtonClicked
{
    [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookShelf];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
		if (enterChapterIsVIP) {
			[self back];
		}
    } else {
		WebViewController *controller = [[WebViewController alloc] init];
		controller.popTarget = self;
		if (enterChapterIsVIP) {
			controller.popTarget = _previousViewController;
		}
		[self.navigationController pushViewController:controller animated:YES];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)sendCommitButtonClicked
{
    [commentView.textField resignFirstResponder];
    [commentView dismissWithClickedButtonIndex:0 animated:YES];
    if (commentView.textField.text.length <= 5) {
        [self displayHUDError:nil message:@"评论内容太短!"];
        return;
    }
    [ServiceManager disscussWithBookID:_chapter.bid andContent:commentView.textField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
         if (!success) {
             [self displayHUDError:nil message:message];
         }
     }];
}

- (void)resetScreenToVer
{
    [(NavViewController *)self.navigationController changeSupportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        [self changedWithOrientation:UIInterfaceOrientationPortrait];
    }
    if (currentChapterString) {
        [self paging];
        [self updateCurrentPageContent];
    }
    menuRect = CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/4, self.view.frame.size.width/3, self.view.frame.size.height/2);
    nextRect = CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height);
}

- (void)orientationButtonClicked
{
    NSLog(@"----%@----",isLandscape ? @"横屏变竖屏" : @"竖屏变横屏");
	isLandscape = !isLandscape;
	UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskPortrait;
	UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
	NSString *defaultValue = UserDefaultScreenPortrait;
	if (isLandscape) {
		orientationMask = UIInterfaceOrientationMaskLandscapeRight;
		orientation = UIInterfaceOrientationLandscapeRight;
		defaultValue = UserDefaultScreenLandscape;
	}
	
	[(NavViewController *)self.navigationController changeSupportedInterfaceOrientations:orientationMask];
	if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
		[self changedWithOrientation:orientation];
	}
	
	[NSUserDefaults brSetObject:defaultValue ForKey:UserDefaultKeyScreen];

	if (currentChapterString) {
		[self paging];
		[self updateCurrentPageContent];
	}
	
    menuRect = CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/4, self.view.frame.size.width/3, self.view.frame.size.height/2);
    nextRect = CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height);
    NSNumber *colorIdx = [NSUserDefaults brObjectForKey:UserDefaultKeyBackground];
    [self.view setBackgroundColor:[NSUserDefaults brBackgroundColorWithIndex:colorIdx.intValue]];
}

- (void)changedWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = toInterfaceOrientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    return toInterfaceOrientation == UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)showLoginAlert
{
	PopLoginViewController *popLoginViewController = [[PopLoginViewController alloc] init];
	[self addChildViewController:popLoginViewController];
	[self.view addSubview:popLoginViewController.view];
}

- (void)bookDetailButtonClick
{
    [self resetScreenToVer];
    firstAppear = YES;
    BookDetailsViewController *controller = [[BookDetailsViewController alloc] initWithBook:_chapter.bid];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
