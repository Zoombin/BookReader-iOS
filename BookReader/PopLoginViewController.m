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
#import "BookReader.h"


@implementation PopLoginViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGFloat delta = [UIApplication sharedApplication].statusBarHidden ? 0 : 20;
	
	self.view.frame = CGRectMake(0, 0 - delta, self.view.frame.size.width, self.view.frame.size.height + delta);
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
	
	CGRect frame = CGRectMake(20, 40, 280, 200);
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    UIView *loginView = [[UIView alloc] initWithFrame:frame];
    loginView.backgroundColor = [UIColor colorWithRed:175.0/255.0 green:88.0/255.0 blue:42.0/255.0 alpha:1.0];
    [self.view addSubview:loginView];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    [titleLable setText:@"登  录"];
    [titleLable setFont:[UIFont systemFontOfSize:20]];
    [titleLable setBackgroundColor:[UIColor clearColor]];
    [titleLable setTextColor:[UIColor whiteColor]];
    [titleLable setTextAlignment:NSTextAlignmentCenter];
    [loginView addSubview:titleLable];
    
    UIView *middleBkg = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(titleLable.frame), width - 5 * 2, height - 40 - 5)];
    [middleBkg setBackgroundColor:[UIColor whiteColor]];
    [loginView addSubview:middleBkg];
    
    accountTextField = [UITextField loginTextFieldWithFrame:CGRectMake(30, 15, middleBkg.frame.size.width - 60, 30)];
    [accountTextField setPlaceholder:@"请输入账号"];
    [middleBkg addSubview:accountTextField];
    
    passwordTextField = [UITextField loginTextFieldWithFrame:CGRectMake(30, CGRectGetMaxY(accountTextField.frame) + 10, middleBkg.frame.size.width - 60, 30)];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setPlaceholder:@"请输入密码"];
    [middleBkg addSubview:passwordTextField];
    
    UIView *bottombkg = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(middleBkg.frame) - middleBkg.frame.size.height / 2.5, width - 5 * 2, middleBkg.frame.size.height / 2.5)];
    [bottombkg setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:231.0/255.0 alpha:1.0]];
    [loginView addSubview:bottombkg];
    
    CGFloat offSetX = 30;
    CGFloat offSetY = 15;
    CGFloat btnWidth = (bottombkg.frame.size.width - offSetX * 3) / 2;
    CGFloat btnHeight = (bottombkg.frame.size.height - offSetY * 2);
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(offSetX, offSetY, btnWidth, btnHeight)];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn.layer setCornerRadius:5];
    [loginBtn.layer setMasksToBounds:YES];
    [loginBtn.layer setBorderWidth:.5];
    [loginBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [loginBtn setBackgroundColor:loginView.backgroundColor];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [bottombkg addSubview:loginBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(CGRectGetMaxX(loginBtn.frame) + offSetX, offSetY, btnWidth, btnHeight)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn.layer setCornerRadius:5];
    [cancelBtn.layer setMasksToBounds:YES];
    [cancelBtn.layer setBorderWidth:.5];
    [cancelBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [cancelBtn setBackgroundColor:bottombkg.backgroundColor];
    [cancelBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [bottombkg addSubview:cancelBtn];
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

- (void)login
{
	if (accountTextField.text.length == 0|| passwordTextField.text.length == 0) {
        [self displayHUDError:nil message:@"账号或者密码不能为空"];
        return;
    }
	[self displayHUD:@"登录中"];
	[ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message, Member *member) {
		[self hideHUD:YES];
        if (error) {
            [self displayHUDError:nil message:@"网络异常"];
        }else {
            if (success) {
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
				[[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [self displayHUDError:nil message:message];
            }
        }
		[self close];
    }];
}

@end
