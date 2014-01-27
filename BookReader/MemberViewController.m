//
//  ReMyAccountViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//


#import "MemberViewController.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "SignInViewController.h"
#import "PasswordViewController.h"
#import "UIViewController+HUD.h"
#import "UIColor+Hex.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "BRUser.h"
#import "Mark.h"
#import "NSString+ZBUtilites.h"
#import "UMFeedback.h"
#import "BRBottomView.h"
#import "WebViewController.h"

@interface MemberViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, iVersionDelegate>

@property (readwrite) UITableView *memberTableView;
@property (readwrite) UIAlertView *logoutAlert;
@property (readwrite) UIWebView *webView;
@property (readwrite) UIButton *logoutButton;
@property (readwrite) BRBottomView *bottomView;

@end

@implementation MemberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.backgroundView removeFromSuperview];
    self.bReg = NO;
	self.headerView.titleLabel.text = @"个人中心";
	self.headerView.backButton.hidden = YES;
	self.hideKeyboardRecognzier.enabled = NO;
	
	CGSize fullSize = self.view.bounds.size;
	
	_memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, [BRHeaderView height], fullSize.width - 10, fullSize.height - [BRHeaderView height] - [BRBottomView height]) style:UITableViewStyleGrouped];
	_memberTableView.hidden = YES;
	[_memberTableView setDelegate:self];
	[_memberTableView setDataSource:self];
	_memberTableView.backgroundColor = [UIColor clearColor];
	[_memberTableView.layer setCornerRadius:5];
	[_memberTableView.layer setMasksToBounds:YES];
	[_memberTableView setBackgroundView:nil];
	[_memberTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
	[self.view addSubview:_memberTableView];
	
	_logoutButton = [UIButton addButtonWithFrame:CGRectMake(fullSize.width - 60, 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
	[_logoutButton setTitle:@"注销" forState:UIControlStateNormal];
	_logoutButton.hidden = YES;
	[_logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_logoutButton];
	
	_bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	_bottomView.memberButton.selected = YES;
	[self.view addSubview:_bottomView];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(5, [BRHeaderView height], fullSize.width - 2 * 5, fullSize.height - [BRHeaderView height] - [BRBottomView height])];
	_webView.backgroundColor = [UIColor clearColor];
	_webView.scrollView.showsHorizontalScrollIndicator = NO;
	_webView.scrollView.showsVerticalScrollIndicator = NO;
	[self.view addSubview:_webView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deeplink:) name:DEEP_LINK object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:_bottomView selector:@selector(refresh) name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (![ServiceManager showDialogs]) {
		[ServiceManager showDialogsSettingsByAppVersion:[NSString appVersion] withBlock:^(BOOL success, NSError *error) {
			[_bottomView refresh];
		}];
	} else {
		[_bottomView refresh];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self fetchUserInfo];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:DEEP_LINK object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:_bottomView name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)fetchUserInfo
{
	if ([ServiceManager isSessionValid]) {
		_logoutButton.hidden = NO;
		_memberTableView.hidden = YES;
		[self goToMemberCenter];
//        if (self.bReg) {
//            self.bReg = NO;
//            return;
//        }
//        [ServiceManager userInfoWithBlock:^(BOOL success, NSError *error, BRUser *member) {
//			if (success) {
//				[ServiceManager saveUserInfo:member];
//			}
//			[_memberTableView reloadData];
//        }];
    }else {
		_logoutButton.hidden = YES;
		_memberTableView.hidden = YES;
		[self goToSignIn];
    }
}

- (void)setUserinfo:(BRUser *)userinfo
{
     self.bReg = YES;
    _userinfo = userinfo;
    [ServiceManager saveUserInfo:userinfo];
    [_memberTableView reloadData];
}

- (void)goToMemberCenter
{
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&version=%@", kXXSYMemberCenterUrlString, [NSString appVersion]]]]];
}

- (void)goToSignIn
{
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?version=%@", kXXSYLoginUrlString, [NSString appVersion]]]]];
}

- (void)deeplink:(NSNotification *)notification
{
	NSLog(@"DEEP_LINK notification: %@", notification);
	NSURL *URL = notification.object;
	
	NSRange range = [URL.absoluteString rangeOfString:@"findpassword"];
	if (range.location != NSNotFound) {
		PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
		passwordViewController.bFindPassword = YES;
		[self.navigationController pushViewController:passwordViewController animated:NO];
		return;
	}
	
	range = [URL.absoluteString rangeOfString:@"login/success/"];
	NSString *userID = nil;
	if (range.location != NSNotFound) {
		userID = [URL.absoluteString substringFromIndex:range.location + range.length];
		NSLog(@"userID: %@", userID);
		if (!userID) {
			return;
		} else {
			[self loginAfterDeepLink:userID];
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
			return;
		}
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
	[self goToMemberCenter];
	[self fetchUserInfo];
}

- (void)logoutButtonClicked
{
	_logoutAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"是否注销当前用户? " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[_logoutAlert show];
}

- (void)logout
{
	[ServiceManager logout];
	[self goToSignIn];
}

- (void)cleanUp
{
	stopAllSync = YES;
	[self displayHUD:@"正在清理，请稍后..."];
	[self performSelector:@selector(_cleanUp) withObject:nil afterDelay:2];
}

- (void)_cleanUp
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[Book truncateAllInContext:localContext];
		[Chapter truncateAllInContext:localContext];
		[Mark truncateAllInContext:localContext];
		[self hideHUD:YES];
		stopAllSync = NO;
	}];
}

- (void)showMyFav
{
    [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookShelf];
}

- (void)showChangePasswordView
{
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.bFindPassword = NO;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}

#pragma mark -UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 1;
	}
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyCell"];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [cell.textLabel setText:[NSString stringWithFormat:@"用户名 : %@", [ServiceManager userInfo].name ?: @""]];
            }
        } else {
            if (indexPath.row == 0) {
                [cell.textLabel setText:@"修改密码"];
            } else if (indexPath.row == 1){
                [cell.textLabel setText:@"我的书架"];
            } else if (indexPath.row == 2) {
                [cell.textLabel setText:@"用户反馈"];
            } else if (indexPath.row == 3){
				[cell.textLabel setText:@"清除所有数据缓存"];
                [cell.detailTextLabel setText:@"(如占用太多空间，可点击此按钮清除数据)"];
                [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
			} else if (indexPath.row == 4) {
				[cell.textLabel setText:@"用户充值"];
			} else {
                [cell.textLabel setText:@"新版本检测"];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.row == 0) {
        [self showChangePasswordView];
    } else if (indexPath.row == 1) {
        [self showMyFav];
    } else if (indexPath.row == 2) {
        NSLog(@"用户反馈");
        [UMFeedback showFeedback:self withAppkey:UMENG_KEY];
    } else if (indexPath.row == 3) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否进行清理? " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alertView show];
	} else if (indexPath.row == 4) {
		WebViewController *webViewController = [[WebViewController alloc] init];
		webViewController.fromWhere = kFromLogin;
		webViewController.urlString = [NSString stringWithFormat:@"%@?userid=%@&tx=1&version=%@", kXXSYHelpUrlString, [ServiceManager userID], [NSString appVersion]];
		NSLog(@"urlString: %@", webViewController.urlString);
		[self.navigationController pushViewController:webViewController animated:YES];
	} else {
        NSLog(@"新版本检测");
        [[iVersion sharedInstance] setIgnoredVersion:@""];
        [[iVersion sharedInstance] checkForNewVersion];
		[iVersion sharedInstance].delegate = self;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		if (alertView == _logoutAlert) {
			_logoutButton.hidden = YES;
			[self logout];
		} else {
			[self cleanUp];
		}
	}
}

#pragma mark - iVersionDelegate

- (void)iVersionDidNotDetectNewVersion
{
	[self displayHUDTitle:nil message:@"当前为最新版本！"];
}

@end
