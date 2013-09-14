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
#import "UIColor+BookReader.h"


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
	
	CGRect frame = CGRectMake((self.view.frame.size.width - 280)/ 2, 0, 280, 200);
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    UIView *loginView = [[UIView alloc] initWithFrame:frame];
    loginView.backgroundColor = [UIColor colorWithRed:175.0/255.0 green:88.0/255.0 blue:42.0/255.0 alpha:1.0];
	loginView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:loginView];
    
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
	titleImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [titleImage setImage:[UIImage imageNamed:@"login_header"]];
    [loginView addSubview:titleImage];
    
    UIView *middleBkg = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(titleImage.frame), width - 1 * 2, height - 40 - 1)];
    [middleBkg setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0]];
	middleBkg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [loginView addSubview:middleBkg];
    
    accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 15, middleBkg.frame.size.width - 40, 35)];
    [accountTextField setLeftViewMode:UITextFieldViewModeAlways];
    [accountTextField setLeftView: [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)]];
    [accountTextField setBackground:[UIImage imageNamed:@"login_username"]];
    [accountTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [middleBkg addSubview:accountTextField];
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(accountTextField.frame) + 10, middleBkg.frame.size.width - 40, 35)];
    [passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    [passwordTextField setLeftView: [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)]];
    [passwordTextField setBackground:[UIImage imageNamed:@"login_password"]];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [middleBkg addSubview:passwordTextField];
    
    CGFloat offSetX = 20;
    CGFloat offSetY = 15;
    CGFloat btnWidth = (width - 5 * 2 - offSetX * 3) / 2;
    CGFloat btnHeight = ((middleBkg.frame.size.height / 2.5) - offSetY * 2);
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(offSetX, CGRectGetMaxY(passwordTextField.frame) + offSetY, btnWidth, btnHeight)];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_nor"] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"login_sel"] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [middleBkg addSubview:loginBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(CGRectGetMaxX(passwordTextField.frame) - btnWidth, CGRectGetMinY(loginBtn.frame), btnWidth, btnHeight)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_nor"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_sel"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [middleBkg addSubview:cancelBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
	[accountTextField becomeFirstResponder];
}

- (void)close
{
	_actionAfterLogin = nil;
	_actionAfterCancel = nil;
	[self willMoveToParentViewController:nil];
	[self viewWillDisappear:YES];
	[self.view removeFromSuperview];
	[self removeFromParentViewController];
}

- (void)cancel
{
	[self hideKeyboard];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if (_actionAfterCancel) {
		if ([_delegate respondsToSelector:_actionAfterCancel]) {
			[_delegate performSelector:_actionAfterCancel];
		}
	}
#pragma clang diagnostic pop
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if (_actionAfterLogin) {
                if ([_delegate respondsToSelector:_actionAfterLogin]) {
                    [_delegate performSelector:_actionAfterLogin];
                }
            }
#pragma clang diagnostic pop
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

@end
