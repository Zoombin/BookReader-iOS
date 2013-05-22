//
//  SignUpViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SignUpViewController.h"
#import "BookReader.h"
#import "UITextField+BookReader.h"
#import "ServiceManager.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "UIViewController+HUD.h"
#import "UIColor+BookReader.h"
#import "AppDelegate.h"

@implementation SignUpViewController {
    UIButton *registerButton;
    UIButton *getCodeButton;
    int emptyCount;
    UITextField *accountTextField;
    UITextField *passwordTextField;
    UITextField *confirmTextField;
    UITextField *codeTextField;
}

- (id)init 
{
    self = [super init];
    if (self) {
        // Custom initialization
        emptyCount = 4;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"注册"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *hidenKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidenKeyboardButton setFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44)];
    [hidenKeyboardButton addTarget:self action:@selector(hidenAllKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hidenKeyboardButton];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIView *signOutView = [UIView findBackgroundViewWithFrame:CGRectMake(10, 44,self.view.bounds.size.width-20, 230)];
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
    if ([accountTextField.text length]>0) {
        [getCodeButton setDisabled:NO];
    } else {
        [getCodeButton setDisabled:YES];
    }
    if ([accountTextField.text length]&&[passwordTextField.text length]&&[confirmTextField.text length]&&[codeTextField.text length]) {
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
    [self displayHUD:@"注册中..."];
    [ServiceManager registerByPhoneNumber:accountTextField.text verifyCode:codeTextField.text andPassword:passwordTextField.text withBlock:^(NSString *result, NSString *resultMessage,NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            [self displayHUDError:nil message:resultMessage];
            if ([result isEqualToString:SUCCESS_FLAG]) {
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
        [ServiceManager verifyCodeByPhoneNumber:accountTextField.text withBlock:^(NSString *result, NSError *error) {
            if (error) {
                
            }else {
                if ([result isEqualToString:SUCCESS_FLAG]) {
                    [self displayHUDError:nil message:@"短信发送成功!"];
                } else {
                    [self displayHUDError:nil message:@"短信发送失败!"];
                }
            }
        }];
    } 
}

- (void)hidenAllKeyboard {
    for (int i =0; i<4; i++) {
        int tag = 102+i;
        UITextField *textField = (UITextField *)[self.view viewWithTag:tag];
        if (textField&&[textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
}




@end
