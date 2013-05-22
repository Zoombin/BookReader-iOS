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
#import "BookReader.h"
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
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ServiceManager userID] != nil) {
        [ServiceManager userInfoWithBlock:^(Member *member, NSError *error) {
            if (error) {
                isLogin = NO;
                [self reloadUI];
            }
            else {
                isLogin = YES;
                _member = member;
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"个人中心"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
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
        
        UIButton *changePassword = [UIButton createMemberbuttonFrame:CGRectMake(0, 35, fuctionsView.bounds.size.width, 40)];
        [changePassword addTarget:self action:@selector(showChangePasswordView) forControlEvents:UIControlEventTouchUpInside];
        [changePassword setTitle:@"修改密码" forState:UIControlStateNormal];
        [fuctionsView addSubview:changePassword];
        
        UIButton *myFavButton = [UIButton createMemberbuttonFrame:CGRectMake(0, 76, fuctionsView.bounds.size.width, 40)];
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
    isLogin = NO;
    //清除个人信息等...
    [ServiceManager deleteUserID];
	//TODO
	[Book truncateAll];
	[Chapter truncateAll];
    [self reloadUI];
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
