//
//  SignUpViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SignUpViewController.h"
#import "UITextField+BookReader.h"
#import "ServiceManager.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "UIViewController+HUD.h"
#import "UIColor+BookReader.h"
#import "UILabel+BookReader.h"
#import "BookReader.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation SignUpViewController {
    UIButton *registerButton;
    UIButton *getCodeButton;
    UITextField *accountTextField;
    UITextField *passwordTextField;
    UITextField *confirmTextField;
    UITextField *codeTextField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize fullSize = self.view.bounds.size;
    [self setTitle:@"注册"];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 46, fullSize.width-8, self.view.bounds.size.height-56)];
    [backgroundView.layer setCornerRadius:5];
    [backgroundView.layer setMasksToBounds:YES];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [self.view addSubview:backgroundView];
    
	accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
	self.keyboardUsers = @[accountTextField, passwordTextField, confirmTextField, codeTextField];
    NSArray *textFields = @[accountTextField,passwordTextField,confirmTextField,codeTextField];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.view addSubview:textField];
    }
	
	registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton cooldownButtonFrame:CGRectMake(0, 0, 0, 0) andEnableCooldown:NO];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setEnabled:NO];
	[self.view addSubview:registerButton];
    
	getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeButton cooldownButtonFrame:CGRectMake(0, 0, 0, 0) andEnableCooldown:YES];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
	
	CGFloat startX = 15;
	CGFloat startY = CGRectGetMinY(backgroundView.frame) + 15;
	CGFloat width = fullSize.width - startX * 2;
	CGFloat height = 50;
	CGFloat distance = 10;
	CGRect rect = CGRectMake(startX, startY, width, height);
	accountTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(accountTextField.bounds) + distance;
    passwordTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(passwordTextField.bounds) + distance + 5;
	getCodeButton.frame = rect;
	rect.origin.y += CGRectGetMaxY(getCodeButton.bounds) + distance;
    confirmTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(confirmTextField.bounds) + distance;
    codeTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(codeTextField.bounds) + distance + 5;
	registerButton.frame = rect;
	rect.origin.y += CGRectGetMaxY(registerButton.bounds) + distance;
}

- (void)valueChanged:(id)sender
{
    if ([accountTextField.text length]) {
        [getCodeButton setEnabled:YES];
    } else {
        [getCodeButton setEnabled:NO];
    }
    if ([accountTextField.text length] && [passwordTextField.text length] && [confirmTextField.text length] && [codeTextField.text length]) {
        [registerButton setEnabled:YES];
    } else {
        [registerButton setEnabled:NO];
    }
}

- (void)registerButtonClicked
{
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
        [self displayHUDError:nil message:@"两次密码不一致"];
        return;
    }
    [self hideKeyboard];
    [self displayHUD:@"注册中..."];
    [ServiceManager registerByPhoneNumber:accountTextField.text verifyCode:codeTextField.text andPassword:passwordTextField.text withBlock:^(BOOL success, NSString *message,NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            [self displayHUDError:nil message:message];
            if (success) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
                [APP_DELEGATE gotoRootController:kRootControllerTypeMember];
            } else {
                
            }
        }
    }];
}

- (void)getCode
{
    [self hideKeyboard];
//    [getCodeButton startCoolDownDuration:20];
    if ([accountTextField.text length]>0) {
        [ServiceManager verifyCodeByPhoneNumber:accountTextField.text withBlock:^(BOOL success, NSString *message, NSError *error){
            if (error) {
                
            }else {
                [self displayHUDError:nil message:message];
            }
        }];
    } 
}

@end
