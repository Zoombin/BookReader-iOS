//
//  PasswordViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "PasswordViewController.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "BookReaderDefaultsManager.h"
#import "UIColor+BookReader.h"
#import "UILabel+BookReader.h"

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
    confirmTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
	self.keyboardUsers = @[accountTextField, passwordTextField, confirmTextField, codeTextField];
    
    if (bFindPassword) {
        [self showFindPassword];
    } else {
        [self showChangePassword];
    }
}

- (void)showFindPassword
{
    [self setTitle:@"找回密码"];
    UIView *findPasswordView = [UIView findBackgroundViewWithFrame:CGRectMake(10, 44,self.view.bounds.size.width-20, 230)];
    [self.view addSubview:findPasswordView];
    
    NSArray *textFields = @[accountTextField,codeTextField,passwordTextField,confirmTextField];
    for (int i = 0; i < textFields.count; i++) {
        CGRect frame = CGRectMake(10, 15+40*i, findPasswordView.bounds.size.width-10*2, 30);
        UITextField *textField = textFields[i];
        [textField setFrame:frame];
        UIImageView *textFieldBackground = [textField backgroundView];
		[findPasswordView addSubview:textFieldBackground];
        [textField addTarget:self action:@selector(FindPasswordvalueChanged:) forControlEvents:UIControlEventEditingChanged];
        [findPasswordView addSubview:textField];
    }
    
     findButton = [UIButton createButtonWithFrame:CGRectMake(30, 234, 100, 30)];
    [findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"修改" forState:UIControlStateNormal];
    [findButton setDisabled:YES];
    [self.view addSubview:findButton];
    
     getCodeButton = [UIButton createButtonWithFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setDisabled:YES];
    [self.view addSubview:getCodeButton];
}

- (void)showChangePassword
{
    [self setTitle:@"修改密码"];
    UIView *changePasswordView = [UIView changeBackgroundViewWithFrame:CGRectMake(10, 44,self.view.bounds.size.width-20, 200)];
    [self.view addSubview:changePasswordView];
    
    NSArray *textFields = @[passwordTextField,confirmTextField,codeTextField];
    for (int i = 0; i < textFields.count; i++) {
        CGRect frame = CGRectMake(20, 20+40*i, changePasswordView.bounds.size.width-20*2, 30);
        UITextField *textField = textFields[i];
        [textField setFrame:frame];
        UIImageView *textFieldBackground = [textField backgroundView];
		[changePasswordView addSubview:textFieldBackground];
        [textField addTarget:self action:@selector(changePasswordValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor clearColor]];
        [changePasswordView addSubview:textField];
    }
    
     changeButton = [UIButton createButtonWithFrame:CGRectMake((self.view.bounds.size.width-80)/2, 200, 80, 30)];
    [changeButton addTarget:self action:@selector(changeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setDisabled:YES];
    [changeButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
}

#pragma mark -
#pragma mark FindPassword
- (void)FindPasswordvalueChanged:(id)sender
{
    if ([accountTextField.text length]) {
        [getCodeButton setDisabled:NO];
    } else {
        [getCodeButton setDisabled:YES];
    }
    if ([accountTextField.text length]&&[passwordTextField.text length]&&[confirmTextField.text length]&&[codeTextField.text length]) {
        [findButton setDisabled:NO];
    } else {
        [findButton setDisabled:YES];
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
    [ServiceManager findPassword:accountTextField.text verifyCode:codeTextField.text andNewPassword:passwordTextField.text withBlock:^(BOOL success, NSString *message, NSError *error) {
        if (error) {
            
        }else {
            if (success) {
                [self displayHUDError:nil message:message];
            } else {
                [self displayHUDError:nil message:message];
            }
        }
    }];
}

- (void)getFindPasswordCode
{
    [self hideKeyboard];
    [self displayHUD:@"请稍等..."];
    [ServiceManager postFindPasswordCode:accountTextField.text withBlock:^(BOOL success, NSString *message, NSError *error) {
        if (error) {
            
        } else {
           [self displayHUDError:nil message:message];
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
    [ServiceManager changePasswordWithOldPassword:passwordTextField.text andNewPassword:confirmTextField.text withBlock:^(BOOL success,NSString *message, NSError *error) {
        if (error) {
            [self displayHUDError:nil message:@"网络异常"];
        }else {
            if (success) {
                [self displayHUDError:nil message:message];
            } else {
                [self displayHUDError:nil message:message];
            }
        }
    }];
}

- (void)changePasswordValueChanged:(id)sender
{
    if ([passwordTextField.text length]&&[confirmTextField.text length]&&[codeTextField.text length]) {
        [changeButton setDisabled:NO];
    } else {
        [changeButton setDisabled:YES];
    }
}

@end
