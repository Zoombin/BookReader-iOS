//
//  LoginViewController.m
//  BookReader
//
//  Created by ZoomBin on 13-7-29.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "PopLoginViewController.h"
#import "UITextField+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+HUD.h"
#import	"ServiceManager.h"
#import "UIDevice+ZBUtilites.h"

@implementation PopLoginViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
	CGRect _frame;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if (self) {
		_frame = frame;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
		self.hideKeyboardRecognzier.enabled = NO;
	}
	
	self.view.frame = _frame;
	self.view.backgroundColor = [UIColor semitransparentBackgroundColor];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleWidth;
	
	CGRect frame = CGRectMake((self.view.frame.size.width - 280)/ 2, 0, 280, 230);
    CGFloat width = frame.size.width;
    
    UIView *loginView = [[UIView alloc] initWithFrame:frame];
    loginView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0];
	loginView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	loginView.layer.cornerRadius = 10;
    [self.view addSubview:loginView];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(loginView.frame), 40)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont systemFontOfSize:22];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.text = @"用户登录";
	[loginView addSubview:titleLabel];
    
    accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, loginView.frame.size.width - 20 * 2, 35)];
    [accountTextField setLeftViewMode:UITextFieldViewModeAlways];
    [accountTextField setLeftView: [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)]];
    [accountTextField setBackground:[UIImage imageNamed:@"login_username"]];
    [accountTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	accountTextField.placeholder = @"请输入用户名";
    [loginView addSubview:accountTextField];
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(accountTextField.frame) + 10, loginView.frame.size.width - 20 * 2, 35)];
    [passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    [passwordTextField setLeftView: [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)]];
    [passwordTextField setBackground:[UIImage imageNamed:@"login_password"]];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	passwordTextField.placeholder = @"请输入密码";
    [loginView addSubview:passwordTextField];
    
    CGFloat offSetX = 20;
    CGFloat offSetY = 15;
    CGFloat btnWidth = (width - 5 * 2 - offSetX * 3) / 3;
    CGFloat btnHeight = 40;
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(offSetX, CGRectGetMaxY(passwordTextField.frame) + offSetY, btnWidth, btnHeight)];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_click"] forState:UIControlStateHighlighted];
	[loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:loginBtn];
    
    UIButton *signupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signupBtn setFrame:CGRectMake(CGRectGetMaxX(loginBtn.frame) + offSetX, CGRectGetMinY(loginBtn.frame), btnWidth, btnHeight)];
    [signupBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signupBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
    [signupBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_click"] forState:UIControlStateHighlighted];
	[signupBtn setTitle:@"注册" forState:UIControlStateNormal];
    [signupBtn addTarget:self action:@selector(signup) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:signupBtn];
	
	UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(CGRectGetMaxX(signupBtn.frame) + offSetX, CGRectGetMinY(loginBtn.frame), btnWidth, btnHeight)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_click"] forState:UIControlStateHighlighted];
	[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [loginView addSubview:cancelBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
	[accountTextField becomeFirstResponder];
}

- (void)close
{
	[self willMoveToParentViewController:nil];
	[self viewWillDisappear:YES];
	[self.view removeFromSuperview];
	[self removeFromParentViewController];
}

- (void)cancel
{
	[self hideKeyboard];
	if ([_delegate respondsToSelector:@selector(popLoginDidCancel)]) {
		[_delegate popLoginDidCancel];
	}
	[self close];
}

- (void)login
{
	
	if (accountTextField.text.length == 0|| passwordTextField.text.length == 0) {
        [self displayHUDTitle:nil message:@"账号或者密码不能为空"];
        return;
    }
	[self hideKeyboard];
	[self displayHUD:@"登录中"];
	[ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message, BRUser *member) {
        if (success) {
            [self hideHUD:YES];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
            [[NSUserDefaults standardUserDefaults] synchronize];
			if ([_delegate respondsToSelector:@selector(popLoginDidLogin)]) {
				[_delegate popLoginDidLogin];
			}
            [self close];
        } else {
            if (error) {
                [self displayHUDTitle:nil message:NETWORK_ERROR];
            } else {
                [self displayHUDTitle:nil message:message];
            }
        }
     }];
}
- (void)signup
{
	if ([_delegate respondsToSelector:@selector(popLoginWillSignup)]) {
		[_delegate popLoginWillSignup];
	}
	[self close];
}

@end
