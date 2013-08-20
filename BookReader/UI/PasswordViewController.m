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
#import "UIColor+BookReader.h"
#import <QuartzCore/QuartzCore.h>

@implementation PasswordViewController {
    UILabel *titleLabel;
    UIButton *findButton;
    UIButton *getCodeButton;
    UIButton *changeButton;
    
    UITextField *accountTextField;
    UITextField *passwordTextField;
    UITextField *confirmTextField;
    UITextField *codeTextField;
}
@synthesize bFindPassword;

- (void)viewDidLoad
{
    [super viewDidLoad];
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordConfirmTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    
    if (bFindPassword) {
        [self showFindPassword];
    } else {
        [self showChangePassword];
    }
}

- (void)showFindPassword
{
	self.headerView.titleLabel.text = @"找回密码";
    CGSize fullSize = self.view.bounds.size;
    
    NSArray *textFields = @[accountTextField,codeTextField,passwordTextField,confirmTextField];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(FindPasswordvalueChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:textField];
    }
    NSLog(@"%@",textFields);
    
    findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findButton memberButton:CGRectMake(0, 0, 0, 0)];
    [findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"修改" forState:UIControlStateNormal];
    [findButton setEnabled:NO];
    [self.view addSubview:findButton];
    
    getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
    
    float startX = 25;
    float startY = 55;
    float width = fullSize.width - 25 * 2;
    float height = 50;
    float distance = 10;
    CGRect rect = CGRectMake(startX, startY, width, height);
    accountTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(accountTextField.bounds) + distance;
    passwordTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(passwordTextField.bounds) + distance;
    confirmTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(confirmTextField.bounds) + distance;
    codeTextField.frame = CGRectMake(startX, rect.origin.y, -5 + width/2, height);
    getCodeButton.frame = CGRectMake(CGRectGetMaxX(codeTextField.frame) + 10, rect.origin.y, -5 + width/2, height);
    rect.origin.y += CGRectGetMaxY(getCodeButton.bounds) + distance;
    findButton.frame = rect;
    rect.origin.y += CGRectGetMaxY(findButton.bounds) + distance;
}

- (void)showChangePassword
{
    CGSize fullSize = self.view.bounds.size;
	self.headerView.titleLabel.text = @"修改密码";
    
    NSArray *textFields = @[passwordTextField,confirmTextField,codeTextField];
    [passwordTextField setPlaceholder:@"请输入旧密码"];
    [confirmTextField setPlaceholder:@"请输入新密码"];
    [codeTextField setPlaceholder:@"请再次输入新密码"];
    for (int i = 0; i < textFields.count; i++) {
        UITextField *textField = textFields[i];
        [textField addTarget:self action:@selector(changePasswordValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:textField];
    }
    
    changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton memberButton:CGRectMake(0, 0, 0, 0)];
    [changeButton addTarget:self action:@selector(changeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setEnabled:NO];
    [changeButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
    
    float startX = 25;
    float startY = 55;
    float width = fullSize.width - 25 * 2;
    float height = 50;
    float distance = 10;
    CGRect rect = CGRectMake(startX, startY, width, height);
    passwordTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(passwordTextField.bounds) + distance;
    confirmTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(confirmTextField.bounds) + distance;
    codeTextField.frame = rect;
    rect.origin.y += CGRectGetMaxY(codeTextField.bounds) + distance;
    changeButton.frame = rect;
    rect.origin.y += CGRectGetMaxY(changeButton.bounds) + distance;
    
}

#pragma mark -
#pragma mark FindPassword
- (void)FindPasswordvalueChanged:(id)sender
{
    if ([accountTextField.text length]) {
        [getCodeButton setEnabled:YES];
    } else {
        [getCodeButton setEnabled:NO];
    }
    if ([accountTextField.text length]&&[passwordTextField.text length]&&[confirmTextField.text length]&&[codeTextField.text length]) {
        [findButton setEnabled:YES];
    } else {
        [findButton setEnabled:NO];
    }
}

- (void)findPassword
{
    if (![passwordTextField.text isEqualToString:confirmTextField.text]) {
        [self displayHUDError:nil message:@"两次密码输入不一致"];
        return;
    }
    [self hideKeyboard];
    [self displayHUD:@"请稍等..."];
    [ServiceManager findPassword:accountTextField.text verifyCode:codeTextField.text andNewPassword:passwordTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
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

- (void)getFindPasswordCode
{
    [self hideKeyboard];
    //    [getCodeButton startCoolDownDuration:20];
    [self displayHUD:@"请稍等..."];
    [ServiceManager postFindPasswordCode:accountTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
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

#pragma mark -
#pragma mark ChangePassword
- (void)changeButtonClicked
{
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
        [self displayHUDError:nil message:@"两次密码不一致"];
        return;
    }
    [self displayHUD:@"请稍等..."];
	[self hideKeyboard];
    [ServiceManager changePasswordWithOldPassword:passwordTextField.text andNewPassword:confirmTextField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
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

- (void)changePasswordValueChanged:(id)sender
{
    if ([passwordTextField.text length]&&[confirmTextField.text length]&&[codeTextField.text length]) {
        [changeButton setEnabled:YES];
    } else {
        [changeButton setEnabled:NO];
    }
}

@end
