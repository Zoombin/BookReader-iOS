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
    [self setTitle:@"登录"];
    
    self.hideBackBtn = YES;
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    UIButton *registerButton = [UIButton custumButtonWithFrame:CGRectMake(self.view.frame.size.width-55, 6, 50, 32)];
    [registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 46, self.view.bounds.size.width-8, self.view.bounds.size.height-56)];
    [backgroundView.layer setCornerRadius:5];
    [backgroundView.layer setMasksToBounds:YES];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backgroundView];
    
    UILabel *accountLabel = [UILabel accountLabelWithFrame:CGRectMake(5, 74, 70, 30)];
    [self.view addSubview:accountLabel];
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(80, 74, self.view.bounds.size.width-60*2, 30)];
    UIImageView *accounttextFieldBackground = [accountTextField backgroundView];
    [self.view addSubview:accounttextFieldBackground];
    [accountTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:accountTextField];
    
    UILabel *passwordLabel = [UILabel passwordLabelWithFrame:CGRectMake(5, 114, 70, 30)];
    [self.view addSubview:passwordLabel];
    
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(80, 114, self.view.bounds.size.width-60*2, 30)];
    UIImageView *pwdtextFieldBackground = [passwordTextField backgroundView];
    [self.view addSubview:pwdtextFieldBackground];
    [passwordTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordTextField];
	
	self.keyboardUsers = @[accountTextField, passwordTextField];
    
    loginButton = [UIButton createMemberbuttonFrame:CGRectMake(35, 160, 250, 30)];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
	[loginButton setEnabled:NO];
    [self.view addSubview:loginButton];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findButton setFrame:CGRectMake(35, 200, 250, 30)];
    [findButton addTarget:self action:@selector(findButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [findButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [findButton setTitleColor:[UIColor colorWithRed:124.0/255.0 green:122.0/255.0 blue:114.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [findButton setTitle:@"忘记密码点这里" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
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
