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
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
	self.keyboardUsers = @[accountTextField, passwordTextField, confirmTextField, codeTextField];
    [self setTitle:@"注册"];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 46, self.view.bounds.size.width-8, self.view.bounds.size.height-56)];
    [backgroundView.layer setCornerRadius:5];
    [backgroundView.layer setMasksToBounds:YES];
    [backgroundView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:backgroundView];
    
    NSArray *textFields = @[accountTextField,passwordTextField,confirmTextField,codeTextField];
	
	CGFloat startY = CGRectGetMinY(backgroundView.frame) + 15;
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        CGRect frame = CGRectMake(40, startY, fullSize.width - 80, 30);
        [textField setFrame:frame];
		UIImageView *textFieldBackground = [textField backgroundView];
		[self.view addSubview:textFieldBackground];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.view addSubview:textField];
		startY += 40;
    }
    
	startY += 15;
	registerButton = [UIButton createMemberbuttonFrame:CGRectMake(30, startY, 250, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setEnabled:NO];
    [self.view addSubview:registerButton];
    
	getCodeButton = [UIButton createMemberbuttonFrame:CGRectMake(30, startY+50, 250, 30)];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
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
                [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
            } else {
                
            }
        }
    }];
}

- (void)getCode
{
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
