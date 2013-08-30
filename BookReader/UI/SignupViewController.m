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
    UITextField *mailTextField;
    UITextView *noticeTextView;
    
    UIButton *phoneRegButton;
    UIButton *nameRegButton;
    
    BOOL bPhoneReg;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"注册";
    CGSize fullSize = self.view.bounds.size;
    
    bPhoneReg = YES;
    
	accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    mailTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    NSArray *textFields = @[accountTextField,passwordTextField,confirmTextField,codeTextField,mailTextField];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.view addSubview:textField];
    }
    [mailTextField setPlaceholder:@"请输入邮箱"];
    
    getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
    
	registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerButton memberButton:CGRectMake(0, 0, 0, 0)];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setEnabled:NO];
	[self.view addSubview:registerButton];
    
    phoneRegButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneRegButton.layer setCornerRadius:5];
    [phoneRegButton.layer setMasksToBounds:YES];
    [phoneRegButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [phoneRegButton.layer setBorderWidth:0.5];
    [phoneRegButton setFrame:CGRectMake(5, 45, 155, 45)];
    [phoneRegButton setBackgroundColor:[UIColor colorWithRed:165.0/255.0 green:134.0/255.0 blue:117.0/255.0 alpha:0.8]];
    [phoneRegButton setShowsTouchWhenHighlighted:YES];
    [phoneRegButton setBackgroundImage:[UIImage imageNamed:@"phonereg_nor"] forState:UIControlStateNormal];
    [phoneRegButton setBackgroundImage:[UIImage imageNamed:@"phonereg_hl"] forState:UIControlStateDisabled];
    [phoneRegButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [phoneRegButton addTarget:self action:@selector(phoneRegistButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phoneRegButton];
    
    nameRegButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nameRegButton.layer setCornerRadius:5];
    [nameRegButton.layer setMasksToBounds:YES];
    [nameRegButton.layer setBorderWidth:0.5];
    [nameRegButton setBackgroundImage:[UIImage imageNamed:@"namereg_nor"] forState:UIControlStateNormal];
    [nameRegButton setBackgroundImage:[UIImage imageNamed:@"namereg_hl"] forState:UIControlStateDisabled];
    [nameRegButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [nameRegButton setFrame:CGRectMake(5 + 155, 45, 155, 45)];
    [nameRegButton setShowsTouchWhenHighlighted:YES];
    [nameRegButton setBackgroundColor:phoneRegButton.backgroundColor];
    [nameRegButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [nameRegButton addTarget:self action:@selector(nameRegistButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nameRegButton];
    
    [phoneRegButton setEnabled:NO];
    [phoneRegButton setAlpha:0.8];
	
	CGFloat startX = 25;
	CGFloat startY = 55 + 50;
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
    
    noticeTextView = [[UITextView alloc] initWithFrame:CGRectMake(startX, rect.origin.y, width, 100)];
    [noticeTextView setEditable:NO];
    [noticeTextView setDataDetectorTypes:UIDataDetectorTypeLink];
    [noticeTextView setText:@"如无法使用手机号注册，请前往潇湘书院官网进行注册。网址：http://www.xxsy.net 。官网注册可以使用昵称等更多功能。"];
    [noticeTextView setTextColor:[UIColor blackColor]];
    [self.view addSubview:noticeTextView];
}

- (void)phoneRegistButtonClicked
{
    CGSize fullSize = self.view.bounds.size;
    
   	CGFloat startX = 25;
	CGFloat startY = 55 + 50;
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
    
    [noticeTextView setFrame:CGRectMake(startX, rect.origin.y, width, 100)];
    
    
    [getCodeButton setHidden:NO];
    [codeTextField setHidden:NO];
    [mailTextField setHidden:YES];
    [nameRegButton setEnabled:YES];
    [nameRegButton setAlpha:1.0];
    [phoneRegButton setEnabled:NO];
    [phoneRegButton setAlpha:0.8];
    
    bPhoneReg = YES;
    [self clearTextField];
}

- (void)nameRegistButtonClicked
{
    CGSize fullSize = self.view.bounds.size;
    
   	CGFloat startX = 25;
	CGFloat startY = 55 + 50;
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
    mailTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(mailTextField.bounds) + distance;
	registerButton.frame = rect;
	rect.origin.y += CGRectGetMaxY(registerButton.bounds) + distance;
    
    [noticeTextView setFrame:CGRectMake(startX, rect.origin.y, width, 100)];
    
    [getCodeButton setHidden:YES];
    [codeTextField setHidden:YES];
    [mailTextField setHidden:NO];
    [nameRegButton setEnabled:NO];
    [nameRegButton setAlpha:0.8];
    [phoneRegButton setEnabled:YES];
    [phoneRegButton setAlpha:1.0];
    
    bPhoneReg = NO;
    [self clearTextField];
}

- (void)valueChanged:(id)sender
{
    if ([accountTextField.text length]) {
        [getCodeButton setEnabled:YES];
    } else {
        [getCodeButton setEnabled:NO];
    }
    if (bPhoneReg) {
        if ([accountTextField.text length] && [passwordTextField.text length] && [confirmTextField.text length] && [codeTextField.text length]) {
            [registerButton setEnabled:YES];
        } else {
            [registerButton setEnabled:NO];
        }
    }else {
        if ([accountTextField.text length] && [passwordTextField.text length] && [confirmTextField.text length] && [mailTextField.text length]) {
            [registerButton setEnabled:YES];
        } else {
            [registerButton setEnabled:NO];
        }
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
    if (bPhoneReg == YES) {
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
    } else {
        [ServiceManager registerByNickName:accountTextField.text email:mailTextField.text andPassword:passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
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
}

- (void)clearTextField
{
    accountTextField.text = @"";
    passwordTextField.text = @"";
    confirmTextField.text = @"";
    codeTextField.text = @"";
    mailTextField.text = @"";
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
