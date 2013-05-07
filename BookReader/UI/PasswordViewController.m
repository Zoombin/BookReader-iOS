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
#import "BookReaderDefaultsManager.h"


#define ACCOUNT_TEXTFIELD_TAG          100
#define PASSWORD_TEXTFIELD_TAG         101
#define CONFIRM_TEXTFIELD_TAG          102
#define CODE_TEXTFIELD_TAG             103

@implementation PasswordViewController {
    UILabel *titleLabel;
    UIButton *findButton;
    UIButton *getCodeButton;
    UIButton *changeButton;
}
@synthesize bFindPassword;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
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
    NSArray *placeHolders = @[@"请输入账号",@"请输入短信验证码", @"请输入新密码", @"请再次输入新密码"];
    NSArray *tags = @[@ACCOUNT_TEXTFIELD_TAG,@CODE_TEXTFIELD_TAG,@PASSWORD_TEXTFIELD_TAG,@CONFIRM_TEXTFIELD_TAG];
    for (int i =0; i<[placeHolders count]; i++) {
        CGRect frame = CGRectMake(10, 74+40*i, MAIN_SCREEN.size.width-10*2, 30);
        UITextField *textField;
        switch (i) {
            case 0:
                textField = [UITextField accountTextFieldWithFrame:frame];
                break;
            case 1:
                textField = [UITextField codeTextFieldWithFrame:frame];
                break;
            case 2:
                textField = [UITextField passwordTextFieldWithFrame:frame];
                break;
            case 3:
                textField = [UITextField passwordTextFieldWithFrame:frame];
                break;
            default:
                break;
        }
        [textField setPlaceholder:placeHolders[i]];
        [textField setTag:[tags[i] intValue]];
        [textField addTarget:self action:@selector(FindPasswordvalueChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:textField];
    }
    
     findButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [findButton setFrame:CGRectMake(30, 234, 100, 30)];
    [findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"修改" forState:UIControlStateNormal];
    [findButton setEnabled:NO];
    [self.view addSubview:findButton];
    
     getCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getCodeButton setFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setEnabled:NO];
    [self.view addSubview:getCodeButton];
}

- (void)showChangePassword
{
    titleLabel.text = @"修改密码";
    NSArray *placeHolders = @[@"请输入旧密码", @"请输入新密码", @"请再次输入新密码"];
    NSArray *tags = @[@PASSWORD_TEXTFIELD_TAG,@CONFIRM_TEXTFIELD_TAG,@CODE_TEXTFIELD_TAG];
    for (int i =0; i<[placeHolders count]; i++) {
        CGRect frame = CGRectMake(10, 74+40*i, MAIN_SCREEN.size.width-10*2, 30);
        UITextField *textField = [UITextField passwordTextFieldWithFrame:frame];
        [textField setPlaceholder:placeHolders[i]];
        [textField setTag:[tags[i] intValue]];
        [textField addTarget:self action:@selector(changePasswordValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:textField];
    }
    
     changeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [changeButton setFrame:CGRectMake(30, 200, 100, 30)];
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
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:PASSWORD_TEXTFIELD_TAG];
    UITextField *confirmTextField = (UITextField *)[self.view viewWithTag:CONFIRM_TEXTFIELD_TAG];
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:CODE_TEXTFIELD_TAG];
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
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:PASSWORD_TEXTFIELD_TAG];
    UITextField *confirmTextField = (UITextField *)[self.view viewWithTag:CONFIRM_TEXTFIELD_TAG];
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:CODE_TEXTFIELD_TAG];
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
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
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:ACCOUNT_TEXTFIELD_TAG];
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
    UITextField *oldPasswordTextField = (UITextField *)[self.view viewWithTag:PASSWORD_TEXTFIELD_TAG];
    UITextField *newPasswordTextField = (UITextField *)[self.view viewWithTag:CONFIRM_TEXTFIELD_TAG];
    UITextField *confirmPasswordTextField = (UITextField *)[self.view viewWithTag:CODE_TEXTFIELD_TAG];
    if (![newPasswordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        [self displayHUDError:nil message:@"两次密码不一致"];
        return;
    }
    [self displayHUD:@"请稍等..."];
    [ServiceManager changePasswordWithOldPassword:oldPasswordTextField.text andNewPassword:newPasswordTextField.text withBlock:^(NSString *result,NSString *resultMessage, NSError *error) {
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
    UITextField *oldPasswordTextField = (UITextField *)[self.view viewWithTag:PASSWORD_TEXTFIELD_TAG];
    UITextField *newPasswordTextField = (UITextField *)[self.view viewWithTag:CONFIRM_TEXTFIELD_TAG];
    UITextField *confirmPasswordTextField = (UITextField *)[self.view viewWithTag:CODE_TEXTFIELD_TAG];
    if ([oldPasswordTextField.text length]&&[newPasswordTextField.text length]&&[confirmPasswordTextField.text length]) {
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
