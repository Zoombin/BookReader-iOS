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
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface SignUpViewController ()

@property (readwrite) UIButton *registerButton;
@property (readwrite) UIButton *getCodeButton;
@property (readwrite) UITextField *accountTextField;
@property (readwrite) UITextField *passwordTextField;
@property (readwrite) UITextField *confirmTextField;
@property (readwrite) UITextField *codeTextField;
@property (readwrite) UITextField *mailTextField;
@property (readwrite) UIButton *phoneRegButton;
@property (readwrite) UIButton *nameRegButton;
@property (readwrite) BOOL bPhoneReg;

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"注册";
    CGSize fullSize = self.view.bounds.size;
    
    _bPhoneReg = YES;

	_accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _mailTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    NSArray *textFields = @[_accountTextField, _passwordTextField, _confirmTextField, _codeTextField, _mailTextField];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.view addSubview:textField];
    }
    [_mailTextField setPlaceholder:@"请输入邮箱"];
    
    _getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_getCodeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [_getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [_getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getCodeButton setEnabled:NO];
    [self.view addSubview:_getCodeButton];
    
	_registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_registerButton memberButton:CGRectMake(0, 0, 0, 0)];
    [_registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [_registerButton setEnabled:NO];
	[self.view addSubview:_registerButton];
    
    _phoneRegButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_phoneRegButton.layer setCornerRadius:5];
    [_phoneRegButton.layer setMasksToBounds:YES];
    [_phoneRegButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_phoneRegButton.layer setBorderWidth:0.5];
    [_phoneRegButton setFrame:CGRectMake(5, 45, 155, 45)];
    [_phoneRegButton setBackgroundColor:[UIColor colorWithRed:165.0/255.0 green:134.0/255.0 blue:117.0/255.0 alpha:0.8]];
    [_phoneRegButton setShowsTouchWhenHighlighted:YES];
    [_phoneRegButton setBackgroundImage:[UIImage imageNamed:@"phonereg_nor"] forState:UIControlStateNormal];
    [_phoneRegButton setBackgroundImage:[UIImage imageNamed:@"phonereg_hl"] forState:UIControlStateDisabled];
    [_phoneRegButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_phoneRegButton addTarget:self action:@selector(phoneRegistButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_phoneRegButton];
    
    _nameRegButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nameRegButton.layer setCornerRadius:5];
    [_nameRegButton.layer setMasksToBounds:YES];
    [_nameRegButton.layer setBorderWidth:0.5];
    [_nameRegButton setBackgroundImage:[UIImage imageNamed:@"namereg_nor"] forState:UIControlStateNormal];
    [_nameRegButton setBackgroundImage:[UIImage imageNamed:@"namereg_hl"] forState:UIControlStateDisabled];
    [_nameRegButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_nameRegButton setFrame:CGRectMake(5 + 155, 45, 155, 45)];
    [_nameRegButton setShowsTouchWhenHighlighted:YES];
    [_nameRegButton setBackgroundColor:_phoneRegButton.backgroundColor];
    [_nameRegButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [_nameRegButton addTarget:self action:@selector(nameRegistButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nameRegButton];
    
    [_phoneRegButton setEnabled:NO];
    [_phoneRegButton setAlpha:0.8];
	
	CGFloat startX = 25;
	CGFloat startY = 55 + 50;
	CGFloat width = fullSize.width - startX * 2;
	CGFloat height = 50;
	CGFloat distance = 10;
	CGRect rect = CGRectMake(startX, startY, width, height);
	_accountTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_accountTextField.bounds) + distance;
    _passwordTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_passwordTextField.bounds) + distance;
    _confirmTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_confirmTextField.bounds) + distance;
    
    _codeTextField.frame = CGRectMake(startX, rect.origin.y, -5 + width/2, height);
    _getCodeButton.frame = CGRectMake(CGRectGetMaxX(_codeTextField.frame) + 10, rect.origin.y, -5 +width/2, height);
	rect.origin.y += CGRectGetMaxY(_getCodeButton.bounds) + distance;
    
	_registerButton.frame = rect;
	rect.origin.y += CGRectGetMaxY(_registerButton.bounds) + distance;
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
	_accountTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_accountTextField.bounds) + distance;
    _passwordTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_passwordTextField.bounds) + distance;
    _confirmTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_confirmTextField.bounds) + distance;
    
    _codeTextField.frame = CGRectMake(startX, rect.origin.y, -5 + width/2, height);
    _getCodeButton.frame = CGRectMake(CGRectGetMaxX(_codeTextField.frame) + 10, rect.origin.y, -5 +width/2, height);
	rect.origin.y += CGRectGetMaxY(_getCodeButton.bounds) + distance;
    
	_registerButton.frame = rect;
	rect.origin.y += CGRectGetMaxY(_registerButton.bounds) + distance;

    [_getCodeButton setHidden:NO];
    [_codeTextField setHidden:NO];
    [_mailTextField setHidden:YES];
    [_nameRegButton setEnabled:YES];
    [_nameRegButton setAlpha:1.0];
    [_phoneRegButton setEnabled:NO];
    [_phoneRegButton setAlpha:0.8];
    
    _bPhoneReg = YES;
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
	_accountTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_accountTextField.bounds) + distance;
    _passwordTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_passwordTextField.bounds) + distance;
    _confirmTextField.frame = rect;
	rect.origin.y += CGRectGetMaxY(_confirmTextField.bounds) + distance;
    _mailTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_mailTextField.bounds) + distance;
	_registerButton.frame = rect;
	rect.origin.y += CGRectGetMaxY(_registerButton.bounds) + distance;
    
    [_getCodeButton setHidden:YES];
    [_codeTextField setHidden:YES];
    [_mailTextField setHidden:NO];
    [_nameRegButton setEnabled:NO];
    [_nameRegButton setAlpha:0.8];
    [_phoneRegButton setEnabled:YES];
    [_phoneRegButton setAlpha:1.0];
    
    _bPhoneReg = NO;
    [self clearTextField];
}

- (void)valueChanged:(id)sender
{
	_getCodeButton.enabled = _accountTextField.text.length ? YES : NO;
    if (_bPhoneReg) {
        if (_accountTextField.text.length && _passwordTextField.text.length && _confirmTextField.text.length && _codeTextField.text.length) {
            [_registerButton setEnabled:YES];
        } else {
            [_registerButton setEnabled:NO];
        }
    }else {
        if (_accountTextField.text.length && _passwordTextField.text.length && _confirmTextField.text.length && _mailTextField.text.length) {
            [_registerButton setEnabled:YES];
        } else {
            [_registerButton setEnabled:NO];
        }
    }
}

- (void)registerButtonClicked
{
    if (![_confirmTextField.text isEqualToString:_passwordTextField.text]) {
        [self displayHUDTitle:nil message:@"两次密码不一致"];
        return;
    }
    [self hideKeyboard];
    [self displayHUD:@"注册中..."];
    if (_bPhoneReg) {
        [ServiceManager registerByPhoneNumber:_accountTextField.text verifyCode:_codeTextField.text andPassword:_passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message, BRUser *member) {
            if (success) {
                [self displayHUDTitle:nil message:message];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
                [APP_DELEGATE.memberVC setUserinfo:member];
				if ([_delegate respondsToSelector:@selector(signUpDone:)]) {
					[_delegate signUpDone:self];
				}
            } else {
                if (error) {
                    [self displayHUDTitle:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDTitle:nil message:message];
                }
            }
        }];
    } else {
        [ServiceManager registerByNickName:_accountTextField.text email:_mailTextField.text andPassword:_passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message, BRUser *member) {
            if (success) {
                [self displayHUDTitle:nil message:message];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
                [APP_DELEGATE.memberVC setUserinfo:member];
				if ([_delegate respondsToSelector:@selector(signUpDone:)]) {
					[_delegate signUpDone:self];
				}
            } else {
                if (error) {
                    [self displayHUDTitle:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDTitle:nil message:message];
                }
            }
        }];
    }
}

- (void)clearTextField
{
    _accountTextField.text = @"";
    _passwordTextField.text = @"";
    _confirmTextField.text = @"";
    _codeTextField.text = @"";
    _mailTextField.text = @"";
}

- (void)getCode
{
    [self hideKeyboard];
    if (_accountTextField.text.length) {
        [ServiceManager verifyCodeByPhoneNumber:_accountTextField.text withBlock:^(BOOL success, NSError *error, NSString *message){
            if (success) {
                [self displayHUDTitle:nil message:message];
            } else {
                if (error) {
                    [self displayHUDTitle:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDTitle:nil message:message];
                }
            }
        }];
    } 
}

@end
