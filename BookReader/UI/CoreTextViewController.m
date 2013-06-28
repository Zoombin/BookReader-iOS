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
#import "NSString+XXSY.h"
#import "Book.h"
#import "ServiceManager.h"
#import "BookReaderDefaultsManager.h"
#import "ReadHelpView.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "Mark.h"

@implementation CoreTextViewController {
    NSInteger startPointX;
    NSInteger startPointY;
    CoreTextView *coreTextView;
	ReadStatusView *statusView;
    BookReadMenuView *menuView;
    UITextField *commitField;
	CGRect menuRect;
	CGRect nextRect;
    
    NSMutableArray *pages;
    NSInteger currentPageIndex;
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
    if (!self.bDetail) {
        Chapter *aChapter;
        
        _book = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", _book.uid]];
        
        if (_book.lastReadChapterID) {//最近读过
            aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", _book.lastReadChapterID]];
        } else {//没读过，从第0章开始
            aChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ AND index=0", _book.uid]];
        }
        
        NSLog(@"start to read book: %@,  chapter: %@", _book, aChapter);
        [self gotoChapter:aChapter withReadIndex:nil];
    }
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
	NSString *textColorString = [BookReaderDefaultsManager objectForKey:UserDefaultKeyTextColor];
    SEL textcolorselector = NSSelectorFromString(textColorString);
	coreTextView.textColor = [UIColor performSelector:textcolorselector];
    statusView.title.textColor = [UIColor performSelector:textcolorselector];
    statusView.percentage.textColor = [UIColor performSelector:textcolorselector];
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
		chapter.lastReadIndex = @(range.location);
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
    [self updateFontColor];
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
			[self gotoChapter:[chapter previous] withReadIndex:nil];
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
		[self gotoChapter:[chapter next] withReadIndex:nil];
        return;
    }
	[self updateCurrentPageContent];
	[self performTransition:kCATransitionFromRight andType:@"pageCurl"];
}

- (void)pop
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)gotoChapter:(Chapter *)aChapter withReadIndex:(NSNumber *)readIndex
{
	if (!aChapter) {
		[self displayHUDError:@"错误" message:@"获取章节目录失败"];
		[self performSelector:@selector(pop) withObject:nil afterDelay:1.5];
		return;
	}
	if (aChapter.content) {
		chapter = aChapter;
		currentChapterString = [chapter.content XXSYDecodingRelatedVIP:chapter.bVip.boolValue];
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			_book.lastReadChapterID = chapter.uid;
			_book.updateDate = [NSDate date];
		}];
		statusView.title.text = [NSString stringWithFormat:@"(%d) %@", chapter.index.intValue + 1, chapter.name];
		[self paging];
		NSNumber *startReadIndex = readIndex ? readIndex : chapter.lastReadIndex;
		currentPageIndex = [self goToIndexWithLastReadPosition:startReadIndex];
		[self updateCurrentPageContent];
	} else {
		[self displayHUD:@"获取章节内容..."];
		[ServiceManager bookCatalogue:aChapter.uid VIP:aChapter.bVip.boolValue withBlock:^(NSString *content, BOOL success, NSString *message, NSError *error) {
			if (content && ![content isEqualToString:@""]) {
				[self hideHUD:YES];
				[self gotoChapter:aChapter withReadIndex:nil];
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					aChapter.content = content;
				}];
			} else {//没下载到，尝试订阅
				[ServiceManager chapterSubscribeWithChapterID:aChapter.uid book:aChapter.bid author:_book.authorID withBlock:^(NSString *content, NSString *message, BOOL success, NSError *error) {
					if (content && ![content isEqualToString:@""]) {
						chapter.content = content;
						[self gotoChapter:aChapter withReadIndex:nil];
						[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
							aChapter.content = content;
						}];
					} else {
                        NSLog(@"%@",message);
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
	reference = [reference stringByReplacingOccurrencesOfString:@"　" withString:@""];//chinese space
	reference = [reference stringByReplacingOccurrencesOfString:@" " withString:@""];
	reference = [reference substringToIndex:40];
	NSLog(@"referenct = %@", reference);
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Mark *mark = [Mark createInContext:localContext];
		mark.chapterID = chapter.uid;
		mark.chapterName = chapter.name;
		mark.reference = reference;
		mark.startWordIndex = @(range.location);
		mark.progress = @([self readPercentage]);
	}];
	
	
}

- (void)chaptersButtonClicked
{
    SubscribeViewController *controller = [[SubscribeViewController alloc] init];
    controller.currentChapterID = chapter.uid;
    controller.delegate = self;
	controller.book = _book;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)previousChapterButtonClick
{
	if (chapter.index.intValue == 0) {
		[self displayHUDError:@"" message:@"此章是第一章"];
		return;
	}
	[self gotoChapter:[chapter previous] withReadIndex:nil];
}

- (void)nextChapterButtonClick
{
	Chapter *aChapter = [chapter next];
	if (!aChapter) {
		[self displayHUDError:@"" message:@"此章是最后一章"];
		return;
	}
	[self gotoChapter:aChapter withReadIndex:nil];
}

#pragma mark -
- (void)didSelect:(id)selected
{
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
    if ([ServiceManager userID]==nil)
    {
        [self displayHUDError:nil message:@"您尚未登录!"];
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入评论内容" message:@"XXXXXXX" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
     commitField = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 35)];
    [commitField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [commitField.layer setCornerRadius:5];
    [commitField setDelegate:self];
    [commitField setReturnKeyType:UIReturnKeyDone];
    [commitField.layer setBorderColor:[UIColor blackColor].CGColor];
    [commitField.layer setBorderWidth:0.5];
    [commitField setBackgroundColor:[UIColor whiteColor]];
    [alertView addSubview:commitField];
    [commitField becomeFirstResponder];
    [alertView show];
}

- (void)commitButtonClicked
{
    [self showCommitAlert];
}

- (void)resetButtonClicked
{
    [BookReaderDefaultsManager reset];
    [self updateFont];
    [self updateFontColor];
    [self updateFontSize];
    coreTextView.alpha = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyBright] floatValue];
    statusView.alpha = coreTextView.alpha;
    NSNumber *colorIdx = [BookReaderDefaultsManager objectForKey:UserDefaultKeyBackground];
	[self.view setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:colorIdx.intValue]];
    [self displayHUDError:nil message:@"已恢复默认!"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self sendCommitButtonClicked];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)sendCommitButtonClicked
{
    [commitField resignFirstResponder];
    [ServiceManager disscussWithBookID:_book.uid andContent:commitField.text withBlock:^(NSString *message, NSError *error)
     {
         if (!error) {
             [self displayHUDError:nil message:message];
         }
     }];
}

- (void)horizontalButtonClicked
{
    
}

@end
