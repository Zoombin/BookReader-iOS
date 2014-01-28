//
//  PasswordViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "PasswordViewController.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import <QuartzCore/QuartzCore.h>

@interface PasswordViewController ()

@property (readwrite) UILabel *titleLabel;
@property (readwrite) UIButton *findButton;
@property (readwrite) UIButton *getCodeButton;
@property (readwrite) UIButton *changeButton;
@property (readwrite) UITextField *accountTextField;
@property (readwrite) UITextField *passwordTextField;
@property (readwrite) UITextField *confirmTextField;
@property (readwrite) UITextField *codeTextField;

@end

@implementation PasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    _codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    
    if (_bFindPassword) {
        [self showFindPassword];
    } else {
        [self showChangePassword];
    }
}

- (void)showFindPassword
{
	self.headerView.titleLabel.text = @"找回密码";
    CGSize fullSize = self.view.bounds.size;
    
    NSArray *textFields = @[_accountTextField, _codeTextField, _passwordTextField, _confirmTextField];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(findPasswordvalueChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:textField];
    }
    NSLog(@"%@",textFields);
    
    _findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_findButton memberButton:CGRectMake(0, 0, 0, 0)];
    [_findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [_findButton setTitle:@"修改" forState:UIControlStateNormal];
    [_findButton setEnabled:NO];
    [self.view addSubview:_findButton];
    
    _getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_getCodeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [_getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [_getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getCodeButton setEnabled:NO];
    [self.view addSubview:_getCodeButton];
    
    float startX = 25;
    float startY = 55;
    float width = fullSize.width - 25 * 2;
    float height = 50;
    float distance = 10;
    CGRect rect = CGRectMake(startX, startY, width, height);
    _accountTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_accountTextField.bounds) + distance;
    _passwordTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_passwordTextField.bounds) + distance;
    _confirmTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_confirmTextField.bounds) + distance;
    _codeTextField.frame = CGRectMake(startX, rect.origin.y, -5 + width/2, height);
    _getCodeButton.frame = CGRectMake(CGRectGetMaxX(_codeTextField.frame) + 10, rect.origin.y, -5 + width/2, height);
    rect.origin.y += CGRectGetMaxY(_getCodeButton.bounds) + distance;
    _findButton.frame = rect;
    rect.origin.y += CGRectGetMaxY(_findButton.bounds) + distance;
}

- (void)showChangePassword
{
    CGSize fullSize = self.view.bounds.size;
	self.headerView.titleLabel.text = @"修改密码";
    
    NSArray *textFields = @[_passwordTextField, _confirmTextField, _codeTextField];
    [_passwordTextField setPlaceholder:@"请输入旧密码"];
    [_confirmTextField setPlaceholder:@"请输入新密码"];
    [_codeTextField setPlaceholder:@"请再次输入新密码"];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(changePasswordValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:textField];
    }
    
    _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_changeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [_changeButton addTarget:self action:@selector(changeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_changeButton setEnabled:NO];
    [_changeButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:_changeButton];
    
    float startX = 25;
    float startY = 55;
    float width = fullSize.width - 25 * 2;
    float height = 50;
    float distance = 10;
    CGRect rect = CGRectMake(startX, startY, width, height);
    _passwordTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_passwordTextField.bounds) + distance;
    _confirmTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_confirmTextField.bounds) + distance;
    _codeTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(_codeTextField.bounds) + distance;
    _changeButton.frame = rect;
    rect.origin.y += CGRectGetMaxY(_changeButton.bounds) + distance;
}

#pragma mark -
#pragma mark FindPassword
- (void)findPasswordvalueChanged:(id)sender
{
    if ([_accountTextField.text length]) {
        [_getCodeButton setEnabled:YES];
    } else {
        [_getCodeButton setEnabled:NO];
    }
    if (_accountTextField.text.length && _passwordTextField.text.length && _confirmTextField.text.length && _codeTextField.text.length) {
        [_findButton setEnabled:YES];
    } else {
        [_findButton setEnabled:NO];
    }
}

- (void)findPassword
{
    if (![_passwordTextField.text isEqualToString:_confirmTextField.text]) {
        [self displayHUDTitle:nil message:@"两次密码输入不一致"];
        return;
    }
    [self hideKeyboard];
    [self displayHUD:@"请稍等..."];
    [ServiceManager findPassword:_accountTextField.text verifyCode:_codeTextField.text andNewPassword:_passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
        if (success) {
            [self displayHUDTitle:nil message:message];
			[self performSelector:@selector(backOrClose) withObject:nil afterDelay:1.0];
        } else {
            if (error) {
                [self displayHUDTitle:nil message:NETWORK_ERROR];
            } else {
                [self displayHUDTitle:nil message:message];
            }
        }
    }];
}

- (void)getFindPasswordCode
{
    [self hideKeyboard];
    [self displayHUD:@"请稍等..."];
    [ServiceManager postFindPasswordCode:_accountTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
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

#pragma mark -
#pragma mark ChangePassword
- (void)changeButtonClicked
{
    if (![_confirmTextField.text isEqualToString:_passwordTextField.text]) {
        [self displayHUDTitle:nil message:@"两次密码不一致"];
        return;
    }
    [self displayHUD:@"请稍等..."];
	[self hideKeyboard];
    [ServiceManager changePasswordWithOldPassword:_passwordTextField.text andNewPassword:_confirmTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
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

- (void)changePasswordValueChanged:(id)sender
{
    if (_passwordTextField.text.length && _confirmTextField.text.length && _codeTextField.text.length) {
		[_changeButton setEnabled:YES];
    } else {
        [_changeButton setEnabled:NO];
    }
}

@end
