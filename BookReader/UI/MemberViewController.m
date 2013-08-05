//
//  ReMyAccountViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//


#import "MemberViewController.h"
#import "AppDelegate.h"
#import "BookShelfButton.h"
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
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "Mark.h"
#import "NSString+ZBUtilites.h"

@implementation MemberViewController
{
    UITableView *_memberTableView;
	UIAlertView *_logoutAlert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"个人中心";
	self.headerView.backButton.hidden = YES;
	self.hideKeyboardRecognzier.enabled = NO;
	
	BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
	_memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, BRHeaderView.height, self.view.bounds.size.width - 10, self.view.bounds.size.height - BRHeaderView.height) style:UITableViewStyleGrouped];
	[_memberTableView setDelegate:self];
	[_memberTableView setDataSource:self];
	_memberTableView.backgroundColor = [UIColor clearColor];
	[_memberTableView.layer setCornerRadius:5];
	[_memberTableView.layer setMasksToBounds:YES];
	[_memberTableView setBackgroundView:nil];
	[_memberTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.view addSubview:_memberTableView];
	
	UIButton *logoutButton = [UIButton addButtonWithFrame:CGRectMake(self.view.bounds.size.width - 60, 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
	[logoutButton setTitle:@"注销" forState:UIControlStateNormal];
	[logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:logoutButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ServiceManager isSessionValid]) {
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
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[Book truncateAll];
		[Chapter truncateAll];
		[Mark truncateAll];
		[self hideHUD:YES];
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
    return 3;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
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
            } else {
				[cell.textLabel setText:@"清除所有数据缓存"];
			}
            UIImageView *catagoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - 50, 14, 6, 12)];
            [catagoryImage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            [catagoryImage setImage:[UIImage imageNamed:@"catagory_arrow"]];
            [cell.contentView addSubview:catagoryImage];
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
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
    } else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否进行清理? " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alertView show];		
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


@end
