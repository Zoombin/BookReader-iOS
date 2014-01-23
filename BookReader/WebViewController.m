//
//  WebViewController.m
//  BookReader
//
//  Created by 颜超 on 13-8-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "WebViewController.h"
#import "BRHeaderView.h"
#import "ServiceManager.h"

//NSString *kFromAddFav = @"kFromAddFav";
NSString *kFromGift = @"kFromGift";
NSString *kFromLogin = @"kFromLogin";
NSString *kFromSubscribe = @"kFromSubscribe";

@interface WebViewController ()

@property (readwrite)UIWebView *webView;

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.backgroundView removeFromSuperview];
	
    self.headerView.titleLabel.text = @"帮助";
    CGSize fullSize = self.view.bounds.size;
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, [BRHeaderView height], fullSize.width, fullSize.height - [BRHeaderView height])];
	_webView.backgroundColor = [UIColor clearColor];
	_webView.scrollView.showsHorizontalScrollIndicator = NO;
	_webView.scrollView.showsVerticalScrollIndicator = NO;
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    [self.view addSubview:_webView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deeplink:) name:DEEP_LINK object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUrlString:(NSString *)urlString
{
	_urlString = urlString;
	NSLog(@"webView urlString: %@", urlString);
}

- (void)backOrClose
{
	if (_popTarget) {
		[self.navigationController popToViewController:_popTarget animated:YES];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deeplink:(NSNotification *)notification
{
	NSLog(@"DEEP_LINK notification: %@", notification);
	NSURL *URL = notification.object;

	NSRange range = [URL.absoluteString rangeOfString:@"login/success/"];
	NSString *userID = nil;
	if (range.location != NSNotFound) {
		userID = [URL.absoluteString substringFromIndex:range.location + range.length];
		NSLog(@"userID: %@", userID);
		if (!userID) {
			return;
		} else {
			[self loginAfterDeepLink:userID];
			[self doAfterDeepLink];
			return;
		}
	}
	
	range = [URL.absoluteString rangeOfString:@"register/success/"];
	if (range.location != NSNotFound) {
		userID = [URL.absoluteString substringFromIndex:range.location + range.length];
		NSLog(@"userID: %@", userID);
		if (!userID) {
			return;
		} else {
			[self loginAfterDeepLink:userID];
			[self doAfterDeepLink];
			return;
		}
	}

	if ([URL.absoluteString hasSuffix:@"success"]) {
		[self.navigationController popViewControllerAnimated:YES];
		[_delegate didSubscribe:_chapter];
	}
}

- (void)loginAfterDeepLink:(NSString *)userID
{
	NSNumber *ID = @([userID longLongValue]);
	if (!ID) {
		return;
	}
	[ServiceManager saveUserID:ID];
	[ServiceManager login];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)doAfterDeepLink
{
	NSNumber *userID = [ServiceManager isSessionValid] ? [ServiceManager userID] : @(0);
	
	if ([_fromWhere isEqualToString:kFromSubscribe]) {
		if (_chapter) {
			NSString *urlString = [NSString stringWithFormat:@"%@?userid=%@&chapterid=%@", kXXSYSubscribeUrlString, userID, _chapter.uid];
			[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
		}
	} else if ([_fromWhere isEqualToString:kFromGift]) {
		if (_book) {
			NSString *urlString = [NSString stringWithFormat:@"%@?userid=%@&bookid=%@", kXXSYGiftsUrlString, userID, _book.uid];
			[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
		}
	} else if ([_fromWhere isEqualToString:kFromLogin]) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}


@end
