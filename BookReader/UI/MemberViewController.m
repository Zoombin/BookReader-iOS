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
#import "BookReaderDefaultsManager.h"
#import "UIColor+Hex.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+BookReader.h"
#import "Member.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "BookReader.h"
#import "BookCell.h"
#import "Mark.h"
#import "NSString+ChineseSpace.h"


@implementation MemberViewController
{
    NSArray *fuctionArray;
    Member *_member;
    BOOL isLogin;
    SignInViewController *signViewController;
    UILabel *accountLabel;
    UILabel *moneyLabel;
    
    UITableView *memberTableView;
}

- (id)init {
    self = [super init];
    if (self) {
        fuctionArray = [[NSArray alloc] initWithObjects:@"修改密码", @"我的书架",nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isLogin = NO;
	self.headerView.backButton.hidden = YES;
	self.hideKeyboardRecognzier.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ServiceManager userID] != nil) {
        [ServiceManager userInfoWithBlock:^(BOOL success, NSError *error, Member *member) {
            if (error) {
                isLogin = YES;
                _member = [ServiceManager userInfo];
                [self reloadUI];
            }
            else {
                isLogin = YES;
                _member = member;
                [ServiceManager saveUserInfo:member.coin andName:member.name];
                [self reloadUI];
            }
        }];
    }else {
        [self reloadUI];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)reloadUI {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    UIImageView *topBarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, BRHeaderView.height)];
    [topBarImage setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
    [self.view addSubview:topBarImage];
    
    UILabel *titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, BRHeaderView.height)];
    [titleLabel setText:@"个人中心"];
    [self.view addSubview:titleLabel];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    if (!isLogin) {
        [APP_DELEGATE gotoRootController:kRootControllerTypeLogin];
    }else {
        memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 40, self.view.bounds.size.width - 10, self.view.bounds.size.height - 50) style:UITableViewStyleGrouped];
        [memberTableView setDelegate:self];
        [memberTableView setDataSource:self];
        [memberTableView setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [memberTableView.layer setCornerRadius:5];
        [memberTableView.layer setMasksToBounds:YES];
        [memberTableView setBackgroundView:nil];
        [memberTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:memberTableView];
        
        UIButton *logoutButton = [UIButton addButtonWithFrame:CGRectMake(self.view.bounds.size.width - 60, 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
        [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
    }
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
	isLogin = NO;
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[ServiceManager deleteUserID];
		[ServiceManager deleteUserInfo];
		[Book truncateAll];
		[Chapter truncateAll];
		[Mark truncateAll];
		[self reloadUI];
		[self hideHUD:YES];
	}];
}

- (void)backOrClose
{
    isLogin = NO;
    [self reloadUI];
}

- (void)backToLoginView
{
    isLogin = YES;
    [self reloadUI];
}

- (void)showMyFav
{
    [APP_DELEGATE gotoRootController:kRootControllerTypeBookShelf];
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
                [(BookCell *)cell setTextLableText:[NSString stringWithFormat:@"用户名 : %@", _member.name]];
                [(BookCell *)cell hidenArrow:YES];
            } else {
                [(BookCell *)cell setTextLableText:[NSString stringWithFormat:@"账%@户 : %@", [NSString ChineseSpace] ,_member.coin]];
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
