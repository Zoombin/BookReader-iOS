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

@property (readwrite) UITextField *accountTextField;
@property (readwrite) UITextField *passwordTextField;
@property (readwrite) UIButton *loginButton;
@property (readwrite) BRBottomView *bottomView;

@end

@implementation SignInViewController

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
    
    _accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(25, 74, fullSize.width - 25 * 2, 50)];
    [_accountTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_accountTextField];
    
    _passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(25, CGRectGetMaxY(_accountTextField.frame) + 10, fullSize.width - 25 * 2, 50)];
    [_passwordTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_passwordTextField];

    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton memberButton:CGRectMake(25, CGRectGetMaxY(_passwordTextField.frame) + 10, fullSize.width-25*2, 50)];
    [_loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
	[_loginButton setEnabled:NO];
    [self.view addSubview:_loginButton];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findButton setFrame:CGRectMake(40, CGRectGetMaxY(_loginButton.frame) + 10, fullSize.width-40*2, 30)];
    [findButton addTarget:self action:@selector(findButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [findButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [findButton setTitleColor:[UIColor colorWithRed:124.0/255.0 green:122.0/255.0 blue:114.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [findButton setTitle:@"密码忘记点这里" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
	
	_bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	_bottomView.memberButton.selected = YES;
	[self.view addSubview:_bottomView];
	
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

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:_bottomView name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)valueChanged:(id)sender
{
    if ([_accountTextField.text length] && [_passwordTextField.text length]) {
        [_loginButton setEnabled:YES];
    } else {
        [_loginButton setEnabled:NO];
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
    [ServiceManager loginByPhoneNumber:_accountTextField.text andPassword:_passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message, BRUser *member) {
		_passwordTextField.text = @"";
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
