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
#import "BookReader.h"
#import "AppDelegate.h"

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
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
	
	CGSize fullSize = self.view.bounds.size;
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, fullSize.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"注册"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *hidenKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidenKeyboardButton setFrame:CGRectMake(0, 44, fullSize.width, fullSize.height-24)];
    [hidenKeyboardButton addTarget:self action:@selector(hidenAllKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hidenKeyboardButton];
    
	UIButton *backButton = [UIButton navigationBackButton];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;

    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIView *signOutView = [UIView findBackgroundViewWithFrame:CGRectMake(10, 44 ,fullSize.width - 20, 230)];
    [self.view addSubview:signOutView];
    
    NSArray *placeHolders = @[@"\t\t请输入账号", @"\t\t请输入密码", @"\t\t请再次输入密码", @"\t\t请输入短信验证码"];
    NSArray *textFields = @[accountTextField,passwordTextField,confirmTextField,codeTextField];
    for (int i =0; i<[placeHolders count]; i++) {
        UITextField *textField = textFields[i];
        CGRect frame = CGRectMake(10, 15+40*i, signOutView.bounds.size.width-10*2, 30);
        [textField setFrame:frame];
        [textField setPlaceholder:placeHolders[i]];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        [signOutView addSubview:textField];
    }
    
     registerButton = [UIButton createButtonWithFrame:CGRectMake(30, 234, 100, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setDisabled:YES];
    [self.view addSubview:registerButton];
    
     getCodeButton = [UIButton createButtonWithFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setDisabled:YES];
    [self.view addSubview:getCodeButton];
}

- (void)valueChanged:(id)sender
{
    if ([accountTextField.text length]) {
        [getCodeButton setDisabled:NO];
    } else {
        [getCodeButton setDisabled:YES];
    }
    if ([accountTextField.text length] && [passwordTextField.text length] && [confirmTextField.text length] && [codeTextField.text length]) {
        [registerButton setDisabled:NO];
    } else {
        [registerButton setDisabled:YES];
    }
}


- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerButtonClicked
{
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
        [self displayHUDError:nil message:@"两次密码不一致"];
        return;
    }
    [self hidenAllKeyboard];
    [self displayHUD:@"注册中..."];
    [ServiceManager registerByPhoneNumber:accountTextField.text verifyCode:codeTextField.text andPassword:passwordTextField.text withBlock:^(NSString *code, NSString *resultMessage,NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            [self displayHUDError:nil message:resultMessage];
            if ([code isEqualToString:SUCCESS_FLAG]) {
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
        [ServiceManager verifyCodeByPhoneNumber:accountTextField.text withBlock:^(NSString *code, NSString *resultMessage, NSError *error){
            if (error) {
                
            }else {
                [self displayHUDError:nil message:resultMessage];
            }
        }];
    } 
}

- (void)hidenAllKeyboard {
    [accountTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [confirmTextField resignFirstResponder];
    [codeTextField resignFirstResponder];
}




@end
