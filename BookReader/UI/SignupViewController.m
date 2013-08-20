//
//  SignUpViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "SignUpViewController.h"
#import "UITextField+BookReader.h"
#import "ServiceManager.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "UIViewController+HUD.h"
#import "UIColor+BookReader.h"
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
	self.headerView.titleLabel.text = @"注册";
    CGSize fullSize = self.view.bounds.size;
    
	accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    NSArray *textFields = @[accountTextField,passwordTextField,confirmTextField,codeTextField];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.view addSubview:textField];
    }
	
	registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton memberButton:CGRectMake(0, 0, 0, 0)];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setEnabled:NO];
	[self.view addSubview:registerButton];
    
	getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
	
	CGFloat startX = 25;
	CGFloat startY = 55;
	CGFloat width = fullSize.width - startX * 2;
	CGFloat height = 50;
	CGFloat distance = 10;
	CGRect rect = CGRectMake(startX, startY, width, height);
	accountTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(accountTextField.bounds) + distance;
    passwordTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(passwordTextField.bounds) + distance;
    confirmTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(confirmTextField.bounds) + distance;
    
    codeTextField.frame = CGRectMake(startX, rect.origin.y, -5 + width/2, height);
    getCodeButton.frame = CGRectMake(CGRectGetMaxX(codeTextField.frame) + 10, rect.origin.y, -5 +width/2, height);
	rect.origin.y += CGRectGetMaxY(getCodeButton.bounds) + distance;
    
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
    [ServiceManager registerByPhoneNumber:accountTextField.text verifyCode:codeTextField.text andPassword:passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
            if (success) {
                [self displayHUDError:nil message:message];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
                [APP_DELEGATE gotoRootController:kRootControllerIdentifierMember];
            } else {
                if (error) {
                    [self displayHUDError:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDError:nil message:message];
                }
            }
    }];
}

- (void)getCode
{
    [self hideKeyboard];
    if ([accountTextField.text length]>0) {
        [ServiceManager verifyCodeByPhoneNumber:accountTextField.text withBlock:^(BOOL success, NSError *error, NSString *message){
            if (success) {
                [self displayHUDError:nil message:message];
            } else {
                if (error) {
                    [self displayHUDError:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDError:nil message:message];
                }
            }
        }];
    } 
}

@end
