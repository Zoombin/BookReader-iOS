//
//  SignInViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SignInViewController.h"
#import "ServiceManager.h"
#import "BookShelfButton.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "SignUpViewController.h"
#import "PasswordViewController.h"
#import "AppDelegate.h"
#import "BookReader.h"
#import "UILabel+BookReader.h"
#import "UIButton+BookReader.h"
#import "UIView+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"
#import "UIColor+BookReader.h"

@implementation SignInViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
    
    UIButton *loginButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"个人中心"];
    
    self.hideBackBtn = YES;
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    UIView *loginBkgView = [UIView loginBackgroundViewWithFrame:CGRectMake(5, 44, self.view.bounds.size.width-5*2, 200) andTitle:@"登录"];
    [self.view addSubview:loginBkgView];
   
    UILabel *accountLabel = [UILabel accountLabelWithFrame:CGRectMake(5, 94, 70, 30)];
    [self.view addSubview:accountLabel];
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(80, 94, self.view.bounds.size.width-80*2, 30)];
    UIImageView *accounttextFieldBackground = [accountTextField backgroundView];
    [self.view addSubview:accounttextFieldBackground];
    [accountTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:accountTextField];
    
    UILabel *passwordLabel = [UILabel passwordLabelWithFrame:CGRectMake(5, 134, 70, 30)];
    [self.view addSubview:passwordLabel];
    
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(80, 134, self.view.bounds.size.width-80*2, 30)];
    UIImageView *pwdtextFieldBackground = [passwordTextField backgroundView];
    [self.view addSubview:pwdtextFieldBackground];
    [passwordTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordTextField];
	
	self.keyboardUsers = @[accountTextField, passwordTextField];
    
     loginButton = [UIButton createButtonWithFrame:CGRectMake(30, 200, 80, 30)];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
	[loginButton setDisabled:YES];
    [self.view addSubview:loginButton];
    
    UIButton *registerButton = [UIButton createButtonWithFrame:CGRectMake(210, 200, 80, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findButton setFrame:CGRectMake(passwordTextField.frame.origin.x+passwordTextField.frame.size.width+10, passwordTextField.frame.origin.y, 50, 30)];
    [findButton addTarget:self action:@selector(findButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [findButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [findButton setTitleColor:[UIColor colorWithRed:124.0/255.0 green:122.0/255.0 blue:114.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [findButton setTitle:@"忘记了" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
}

- (void)valueChanged:(id)sender
{
    if ([accountTextField.text length] && [passwordTextField.text length]) {
        [loginButton setDisabled:NO];
    } else {
        [loginButton setDisabled:YES];
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
    [self.navigationController pushViewController:[[SignUpViewController alloc] init] animated:YES];
}

- (void)loginButtonClicked
{
    [self hideKeyboard];
    [self displayHUD:@"登录中"];
    [ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(Member *member,BOOL success,NSString *message,NSError *error) {
		passwordTextField.text = @"";
        if (error) {
            [self displayHUDError:nil message:@"网络异常"];
        }else {
            if (success) {
				[self hideHUD:YES];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
				[[NSUserDefaults standardUserDefaults] synchronize];
                [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
            } else {
                [self displayHUDError:nil message:message];
            }
        }
    }];
}

@end
