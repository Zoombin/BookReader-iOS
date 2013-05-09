//
//  PasswordViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "PasswordViewController.h"
#import "BookReader.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "BookReaderDefaultsManager.h"
#import "UIColor+BookReader.h"



#define ACCOUNT_TEXTFIELD_TAG          100
#define PASSWORD_TEXTFIELD_TAG         101
#define CONFIRM_TEXTFIELD_TAG          102
#define CODE_TEXTFIELD_TAG             103

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
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    confirmTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    codeTextField = [UITextField codeTextFieldWithFrame:CGRectMake(0, 0, 0, 0)];
    
	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
    [self.view addSubview:backgroundImage];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
     titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *hidenKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidenKeyboardButton setFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44)];
    [hidenKeyboardButton addTarget:self action:@selector(hidenAllKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hidenKeyboardButton];
    
    if (bFindPassword) {
        [self showFindPassword];
    } else {
        [self showChangePassword];
    }
	// Do any additional setup after loading the view.
}

- (void)showFindPassword
{
    [titleLabel setText:@"找回密码"];
    
    UIView *findPasswordView = [UIView findBackgroundViewWithFrame:CGRectMake(10, 44,self.view.bounds.size.width-20, 230)];
    [self.view addSubview:findPasswordView];
    
    NSArray *placeHolders = @[@"\t\t请输入账号",@"\t\t请输入短信验证码", @"\t\t请输入新密码", @"\t\t请再次输入新密码"];
    NSArray *textFields = @[accountTextField,codeTextField,passwordTextField,confirmTextField];
    for (int i =0; i<[placeHolders count]; i++) {
        CGRect frame = CGRectMake(10, 15+40*i, findPasswordView.bounds.size.width-10*2, 30);
        UITextField *textField = textFields[i];
        [textField setFrame:frame];
        [textField setPlaceholder:placeHolders[i]];
        [textField addTarget:self action:@selector(FindPasswordvalueChanged:) forControlEvents:UIControlEventEditingChanged];
        [findPasswordView addSubview:textField];
    }
    
     findButton = [UIButton createButtonWithFrame:CGRectMake(30, 234, 100, 30)];
    [findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"修改" forState:UIControlStateNormal];
    [findButton setEnabled:NO];
    [self.view addSubview:findButton];
    
     getCodeButton = [UIButton createButtonWithFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
}

- (void)showChangePassword
{
    titleLabel.text = @"修改密码";
    UIView *changePasswordView = [UIView changeBackgroundViewWithFrame:CGRectMake(10, 44,self.view.bounds.size.width-20, 200)];
    [self.view addSubview:changePasswordView];
    
    NSArray *placeHolders = @[@"\t\t请输入旧密码", @"\t\t请输入新密码", @"\t\t请再次输入新密码"];
    NSArray *textFields = @[passwordTextField,confirmTextField,codeTextField];
    for (int i =0; i<[placeHolders count]; i++) {
        CGRect frame = CGRectMake(20, 20+40*i, changePasswordView.bounds.size.width-20*2, 30);
        UITextField *textField = textFields[i];
        [textField setFrame:frame];
        [textField setPlaceholder:placeHolders[i]];
        [textField addTarget:self action:@selector(changePasswordValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [changePasswordView addSubview:textField];
    }
    
     changeButton = [UIButton createButtonWithFrame:CGRectMake((self.view.bounds.size.width-80)/2, 200, 80, 30)];
    [changeButton addTarget:self action:@selector(changeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setEnabled:NO];
    [changeButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
 
}

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self displayHUD:@"请稍等..."];
    [ServiceManager findPassword:accountTextField.text verifyCode:codeTextField.text andNewPassword:passwordTextField.text withBlock:^(NSString *result, NSString *code, NSError *error) {
        if (error) {
            
        }else {
            if ([code isEqualToString:SUCCESS_FLAG]) {
                [self displayHUDError:nil message:result];
            } else {
                [self displayHUDError:nil message:result];
            }
        }
    }];
}

- (void)getFindPasswordCode
{
    [self displayHUD:@"请稍等..."];
    [ServiceManager postFindPasswordCode:accountTextField.text withBlock:^(NSString *result, NSString *code, NSError *error) {
        if (error) {
            
        } else {
            if ([code isEqualToString:SUCCESS_FLAG]) {
                [self displayHUDError:nil message:@"获取验证码成功"];
            } else {
                [self displayHUDError:nil message:@"验证码获取失败"];
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
    [ServiceManager changePasswordWithOldPassword:passwordTextField.text andNewPassword:confirmTextField.text withBlock:^(NSString *result,NSString *resultMessage, NSError *error) {
        if (error) {
            [self displayHUDError:nil message:@"网络异常"];
        }else {
            if ([result isEqualToString:SUCCESS_FLAG]) {
                [self displayHUDError:nil message:resultMessage];
            } else {
                [self displayHUDError:nil message:resultMessage];
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

- (void)hidenAllKeyboard {
    for (int i =0; i<4; i++) {
        int tag = 100+i;
        UITextField *textField = (UITextField *)[self.view viewWithTag:tag];
        if (textField&&[textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
}

@end
