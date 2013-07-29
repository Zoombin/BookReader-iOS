//
//  LoginViewController.m
//  BookReader
//
//  Created by 颜超 on 13-7-29.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "LoginViewController.h"
#import "UITextField+BookReader.h"
#import <QuartzCore/QuartzCore.h>


@implementation LoginViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
}
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)showLoginView
{
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
    [loginBtn addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
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
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [bottombkg addSubview:cancelBtn];
    
    [accountTextField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
	// Do any additional setup after loading the view.
    [self showLoginView];
}

- (void)cancelBtnClicked
{
    [self.view removeFromSuperview];
}

- (void)loginBtnClicked
{
    if ([self.delegate respondsToSelector:@selector(loginWithAccount:andPassword:)]) {
        [self.delegate loginWithAccount:accountTextField.text andPassword:passwordTextField.text];
    }
}

@end
