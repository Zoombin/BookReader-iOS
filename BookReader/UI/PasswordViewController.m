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
    CGSize fullSize = self.view.bounds.size;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 46, fullSize.width-8, fullSize.height-56)];
    [backgroundView.layer setCornerRadius:5];
    [backgroundView.layer setMasksToBounds:YES];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [self.view addSubview:backgroundView];
    
    NSArray *textFields = @[accountTextField,codeTextField,passwordTextField,confirmTextField];
    int k = 0;
    for (int i = 0; i < textFields.count; i++) {
        k = i>1 ? i+1 : i;
        CGRect frame = CGRectMake(15, 44+15+50*k, fullSize.width-15*2, 40);
        UITextField *textField = textFields[i];
        [textField setFrame:frame];
        [textField addTarget:self action:@selector(FindPasswordvalueChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:textField];
    }
    
     findButton = [UIButton createMemberbuttonFrame:CGRectMake(15, 310, fullSize.width-15*2, 40)];
    [findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"修改" forState:UIControlStateNormal];
    [findButton setEnabled:NO];
    [self.view addSubview:findButton];
    
     getCodeButton = [UIButton createMemberbuttonFrame:CGRectMake(15, 160, fullSize.width-15*2, 40)];
    [getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
}

- (void)showChangePassword
{
    CGSize fullSize = self.view.bounds.size;
    [self setTitle:@"修改密码"];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 46, fullSize.width-8, self.view.bounds.size.height-56)];
    [backgroundView.layer setCornerRadius:5];
    [backgroundView.layer setMasksToBounds:YES];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [self.view addSubview:backgroundView];
    
    
    NSArray *textFields = @[passwordTextField,confirmTextField,codeTextField];
    [passwordTextField setPlaceholder:@"请输入旧密码"];
    [confirmTextField setPlaceholder:@"请输入新密码"];
    [codeTextField setPlaceholder:@"请再次输入新密码"];
    for (int i = 0; i < textFields.count; i++) {
        CGRect frame = CGRectMake(15, 44+20+50*i, fullSize.width-15*2, 40);
        UITextField *textField = textFields[i];
        [textField setFrame:frame];
        [textField addTarget:self action:@selector(changePasswordValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:textField];
    }
    
     changeButton = [UIButton createMemberbuttonFrame:CGRectMake(15, 210, fullSize.width-15*2, 40)];
    [changeButton addTarget:self action:@selector(changeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setEnabled:NO];
    [changeButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
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
        [changeButton setEnabled:YES];
    } else {
        [changeButton setEnabled:NO];
    }
}

@end
