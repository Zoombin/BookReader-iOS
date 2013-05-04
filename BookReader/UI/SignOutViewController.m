//
//  SignOutViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SignOutViewController.h"
#import "UIDefines.h"
#import "UITextField+BookReader.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"

#define REGISTER_ACCOUNT_TEXTFIELD_TAG          102
#define REGISTER_PASSWORD_TEXTFIELD_TAG         103
#define REGISTER_CONFIRM_TEXTFIELD_TAG          104
#define REGISTER_CODE_TEXTFIELD_TAG             105

@implementation SignOutViewController {
    UIButton *registerButton;
    UIButton *getCodeButton;
    int emptyCount;
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
    UIImage*img =[UIImage imageNamed:@"main_view_bkg"];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:img]];
    
	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
    [self.view addSubview:backgroundImage];
    
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
    
    NSArray *placeHolders = @[@"请输入手机号", @"请输入密码", @"请再次输入密码", @"请输入短信验证码"];
    NSArray *tags = @[@REGISTER_ACCOUNT_TEXTFIELD_TAG,@REGISTER_PASSWORD_TEXTFIELD_TAG,@REGISTER_CONFIRM_TEXTFIELD_TAG,@REGISTER_CODE_TEXTFIELD_TAG];
    for (int i =0; i<[placeHolders count]; i++) {
        UITextField *textField;
        CGRect frame = CGRectMake(10, 74+40*i, MAIN_SCREEN.size.width-10*2, 30);
        switch (i) {
            case 0:
                textField = [UITextField accountTextFieldWithFrame:frame];
                break;
            case 1:
                textField = [UITextField passwordTextFieldWithFrame:frame];
                break;
            case 2:
                textField = [UITextField passwordTextFieldWithFrame:frame];
                break;
            case 3:
                textField = [UITextField codeTextFieldWithFrame:frame];
                break;
            default:
                break;
        }
        [textField setPlaceholder:placeHolders[i]];
        [textField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        [textField setTag:[tags[i] intValue]];
        [self.view addSubview:textField];
    }
    
     registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton setFrame:CGRectMake(30, 234, 100, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton setEnabled:NO];
    [self.view addSubview:registerButton];
    
     getCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getCodeButton setFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
}

- (void)valueChanged:(id)sender
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:REGISTER_ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:REGISTER_PASSWORD_TEXTFIELD_TAG];
    UITextField *confirmTextField = (UITextField *)[self.view viewWithTag:REGISTER_CONFIRM_TEXTFIELD_TAG];
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:REGISTER_CODE_TEXTFIELD_TAG];
    if ([accountTextField.text length]>0) {
        [getCodeButton setEnabled:YES];
    } else {
        [getCodeButton setEnabled:NO];
    }
    if ([accountTextField.text length]&&[passwordTextField.text length]&&[confirmTextField.text length]&&[codeTextField.text length]) {
        [registerButton setEnabled:YES];
    } else {
        [registerButton setEnabled:NO];
    }
}


- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerButtonClicked
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:REGISTER_ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:REGISTER_PASSWORD_TEXTFIELD_TAG];
    UITextField *confirmTextField = (UITextField *)[self.view viewWithTag:REGISTER_CONFIRM_TEXTFIELD_TAG];
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:REGISTER_CODE_TEXTFIELD_TAG];
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
        [self displayHUDError:nil message:@"两次密码不一致"];
        return;
    }
    if ([accountTextField.text length]!=8&&[accountTextField.text length]!=11) {
        [self displayHUDError:nil message:@"手机号不合法"];
        return;
    }
    [self displayHUD:@"注册中..."];
    [ServiceManager registerByPhoneNumber:accountTextField.text verifyCode:codeTextField.text andPassword:passwordTextField.text withBlock:^(NSString *result, NSString *resultMessage,NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORKERROR];
        }else {
            [self displayHUDError:nil message:resultMessage];
            if ([result isEqualToString:SUCCESS_FLAG]) {
                
            } else {
                
            }
        }
    }];
}

- (void)getCode
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:REGISTER_ACCOUNT_TEXTFIELD_TAG];
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
