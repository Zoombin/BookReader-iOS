//
//  ReMyAccountViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-23.
//  Copyright (c) 2013年 颜超. All rights reserved.
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


@implementation MemberViewController
{
    NSArray *fuctionArray;
    Member *_member;
    BOOL isLogin;
    SignInViewController *signViewController;
    UILabel *accountLabel;
    UILabel *moneyLabel;
}

- (id)init {
    self = [super init];
    if (self) {
        fuctionArray = [[NSArray alloc] initWithObjects:@"修改密码", @"我的收藏",nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isLogin = NO;
    [self setHideBackBtn:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ServiceManager userID] != nil) {
        [ServiceManager userInfoWithBlock:^(Member *member, NSError *error) {
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
    UIImageView *topBarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [topBarImage setImage:[UIImage imageNamed:@"nav_header"]];
    [self.view addSubview:topBarImage];
    
    UILabel *titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [titleLabel setText:@"个人中心"];
    [self.view addSubview:titleLabel];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    if (!isLogin) {
        [APP_DELEGATE switchToRootController:kRootControllerTypeLogin];
    }else {
        UIView *userInfoView = [UIView userBackgroundViewWithFrame:CGRectMake(10, 44,self.view.bounds.size.width-20, 130) andTitle:@"会员中心"];
        [self.view addSubview:userInfoView];
        
        accountLabel = [UILabel memberAccountLabelWithFrame:CGRectMake(0, 35, userInfoView.bounds.size.width, 40) andAccountName:_member.name];
        [userInfoView addSubview:accountLabel];
        
        moneyLabel = [UILabel memberUserMoneyLeftWithFrame:CGRectMake(0, 76, userInfoView.bounds.size.width, 40) andMoneyLeft:[_member.coin stringValue]];
        [userInfoView addSubview:moneyLabel];
        
        UIView *fuctionsView = [UIView userBackgroundViewWithFrame:CGRectMake(10, 200,self.view.bounds.size.width-20, 130) andTitle:@"功能列表"];
        [self.view addSubview:fuctionsView];
        
        UIButton *changePassword = [UIButton buttonWithType:UIButtonTypeCustom];
        [changePassword setFrame:CGRectMake(0, 35, fuctionsView.bounds.size.width, 40)];
        [changePassword addTarget:self action:@selector(showChangePasswordView) forControlEvents:UIControlEventTouchUpInside];
        [changePassword setTitle:@"修改密码" forState:UIControlStateNormal];
        [fuctionsView addSubview:changePassword];
        
        UIButton *myFavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [myFavButton setFrame:CGRectMake(0, 35, fuctionsView.bounds.size.width, 40)];
        [myFavButton addTarget:self action:@selector(showMyFav) forControlEvents:UIControlEventTouchUpInside];
        [myFavButton setTitle:@"我的收藏" forState:UIControlStateNormal];
        [fuctionsView addSubview:myFavButton];
        
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [logoutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [logoutButton setTitleColor:[UIColor hexRGB:0xfbbf90] forState:UIControlStateNormal];
        [logoutButton setFrame:CGRectMake(260, 6, 50, 32)];
        [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
    }
}

- (void)logoutButtonClicked
{
	stopAllSync = YES;
	[self displayHUD:@"正在注销"];
	[self performSelector:@selector(logout) withObject:nil afterDelay:2];
}

- (void)logout
{
	isLogin = NO;
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[ServiceManager deleteUserID];
		[ServiceManager deleteUserInfo];
		[Book truncateAll];
		[Chapter truncateAll];
		[self reloadUI];
		[self hideHUD:YES];
	}];
}

- (void)backButtonClicked
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
    [APP_DELEGATE switchToRootController:kRootControllerTypeBookShelf];
}

- (void)showChangePasswordView
{
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.bFindPassword = NO;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}


@end
