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
#import "UIColor+BookReader.h"
#import "BRUser.h"
#import "Mark.h"
#import "NSString+ZBUtilites.h"
#import "UMFeedback.h"
#import "BRBottomView.h"

@interface MemberViewController() <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, iVersionDelegate>
@end

@implementation MemberViewController
{
    UITableView *_memberTableView;
	UIAlertView *_logoutAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bReg = NO;
	self.headerView.titleLabel.text = @"个人中心";
	self.headerView.backButton.hidden = YES;
	self.hideKeyboardRecognzier.enabled = NO;
	
	CGSize fullSize = self.view.bounds.size;
	
	_memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, [BRHeaderView height], fullSize.width - 10, fullSize.height - [BRHeaderView height] - [BRBottomView height]) style:UITableViewStyleGrouped];
	[_memberTableView setDelegate:self];
	[_memberTableView setDataSource:self];
	_memberTableView.backgroundColor = [UIColor clearColor];
	[_memberTableView.layer setCornerRadius:5];
	[_memberTableView.layer setMasksToBounds:YES];
	[_memberTableView setBackgroundView:nil];
	[_memberTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
	[self.view addSubview:_memberTableView];
	
	UIButton *logoutButton = [UIButton addButtonWithFrame:CGRectMake(fullSize.width - 60, 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
	[logoutButton setTitle:@"注销" forState:UIControlStateNormal];
	[logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:logoutButton];
	
	BRBottomView *bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	bottomView.memberButton.selected = YES;
	[self.view addSubview:bottomView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ServiceManager isSessionValid]) {
        if (self.bReg) {
            self.bReg = NO;
            return;
        }
        [ServiceManager userInfoWithBlock:^(BOOL success, NSError *error, BRUser *member) {
			if (success) {
				[ServiceManager saveUserInfo:member];
			}
			[_memberTableView reloadData];
        }];
    }else {
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

- (void)goToSignIn
{
	SignInViewController *signInViewController = [[SignInViewController alloc] init];
	[self.navigationController pushViewController:signInViewController animated:NO];
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
		return 2;
	}
    return 5;
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
            } else {
                [cell.textLabel setText:[NSString stringWithFormat:@"账%@户 : %@", [NSString ChineseSpace] , [ServiceManager userInfo].coin ?: @""]];
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
    } else if (indexPath.row == 3){
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否进行清理? " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alertView show];
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
