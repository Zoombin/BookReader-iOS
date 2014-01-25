//
//  SignInViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "SignInViewController.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "SignUpViewController.h"
#import "PasswordViewController.h"
#import "AppDelegate.h"
#import "UIButton+BookReader.h"
#import "UIView+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"
#import "BRBottomView.h"

@interface SignInViewController () <SignUpViewControllerDelegate>

@end

@implementation SignInViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
    
    UIButton *loginButton;
	BRBottomView *bottomView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"登录";
    self.headerView.backButton.hidden = YES;
    CGSize fullSize = self.view.bounds.size;
	
	UIButton *registerButton = [UIButton addButtonWithFrame:CGRectMake(fullSize.width - 55, 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
	[registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[registerButton setTitle:@"注册" forState:UIControlStateNormal];
	registerButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:registerButton];
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(25, 74, fullSize.width - 25 * 2, 50)];
    [accountTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:accountTextField];
    
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(25, CGRectGetMaxY(accountTextField.frame) + 10, fullSize.width-25*2, 50)];
    [passwordTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordTextField];

    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton memberButton:CGRectMake(25, CGRectGetMaxY(passwordTextField.frame) + 10, fullSize.width-25*2, 50)];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
	[loginButton setEnabled:NO];
    [self.view addSubview:loginButton];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findButton setFrame:CGRectMake(40, CGRectGetMaxY(loginButton.frame) + 10, fullSize.width-40*2, 30)];
    [findButton addTarget:self action:@selector(findButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [findButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [findButton setTitleColor:[UIColor colorWithRed:124.0/255.0 green:122.0/255.0 blue:114.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [findButton setTitle:@"密码忘记点这里" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
	
	bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	bottomView.memberButton.selected = YES;
	[self.view addSubview:bottomView];
	
	[[NSNotificationCenter defaultCenter] addObserver:bottomView selector:@selector(refresh) name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[bottomView refresh];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:bottomView name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)valueChanged:(id)sender
{
    if ([accountTextField.text length] && [passwordTextField.text length]) {
        [loginButton setEnabled:YES];
    } else {
        [loginButton setEnabled:NO];
    }
}

- (void)findButtonClicked
{
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.bFindPassword = YES;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}

- (void)registerButtonClick
{
	SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
	signUpViewController.delegate = self;
	[self.navigationController pushViewController:signUpViewController animated:YES];
}

- (void)loginButtonClicked
{
    [self hideKeyboard];
    [self displayHUD:@"加载..."];
    [ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message, BRUser *member) {
		passwordTextField.text = @"";
            if (success) {
				[self hideHUD:YES];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[self.navigationController popViewControllerAnimated:YES];
            } else {
                if (error) {
                    [self displayHUDTitle:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDTitle:nil message:message];
                }
            }
    }];
}

#pragma mark - SignUpViewControllerDelegate

- (void)signUpDone:(SignUpViewController *)signUpViewController
{
	[APP_DELEGATE gotoRootController:kRootControllerIdentifierMember];
}

@end
