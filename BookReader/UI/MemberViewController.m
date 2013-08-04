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
#import "UILabel+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+BookReader.h"
#import "BRUser.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "BookCell.h"
#import "Mark.h"
#import "NSString+ChineseSpace.h"


@implementation MemberViewController
{
    UITableView *_memberTableView;
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您确定要注销吗? " delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        stopAllSync = YES;
        [self displayHUD:@"正在注销"];
        [self performSelector:@selector(logout) withObject:nil afterDelay:2];
    }
}

- (void)logout
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[ServiceManager logout];
		[Book truncateAll];
		[Chapter truncateAll];
		[Mark truncateAll];
		[self hideHUD:YES];
		[self goToSignIn];
		
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

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
        cell = [[BookCell alloc] initWithStyle:BookCellStyleCatagory reuseIdentifier:@"MyCell"];
        [(BookCell *)cell hidenDottedLine];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [(BookCell *)cell setTextLableText:[NSString stringWithFormat:@"用户名 : %@", [ServiceManager userInfo].name ?: @""]];
                [(BookCell *)cell hidenArrow:YES];
            } else {
                [(BookCell *)cell setTextLableText:[NSString stringWithFormat:@"账%@户 : %@", [NSString ChineseSpace] , [ServiceManager userInfo].coin ?: @""]];
                [(BookCell *)cell hidenArrow:YES];
            }
        } else {
            if (indexPath.row == 0) {
                [(BookCell *)cell setTextLableText:@"修改密码"];
            } else {
                [(BookCell *)cell setTextLableText:@"我的书架"];
            }
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell height];
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
    }
}


@end
