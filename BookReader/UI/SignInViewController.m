//
//  SignInViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SignInViewController.h"
#import "UIDefines.h"
#import "ServiceManager.h"
#import "BookShelfButton.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "SignOutViewController.h"
#import "PasswordViewController.h"
#import "AppDelegate.h"

#define ACCOUNT_TEXTFIELD_TAG                   100
#define PASSWORD_TEXTFIELD_TAG                  101

@implementation SignInViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
    
    UIButton *loginButton;
}

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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"个人中心"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *hidenKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidenKeyboardButton setFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44)];
    [hidenKeyboardButton addTarget:self action:@selector(hidenAllKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hidenKeyboardButton];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(10, 74, MAIN_SCREEN.size.width-10*2, 30)];
    [accountTextField setTag:ACCOUNT_TEXTFIELD_TAG];
    [accountTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:accountTextField];
    
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(10, 114, MAIN_SCREEN.size.width-10*2, 30)];
    [passwordTextField setTag:PASSWORD_TEXTFIELD_TAG];
    [passwordTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordTextField];
    
     loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginButton setFrame:CGRectMake(30, 150, 100, 30)];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setEnabled:NO];
    [self.view addSubview:loginButton];
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton setFrame:CGRectMake(190, 150, 100, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [findButton setFrame:CGRectMake(30, 190, 100, 30)];
    [findButton addTarget:self action:@selector(findButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"找回密码" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    accountTextField.text = @"";
    passwordTextField.text = @"";
    [loginButton setEnabled:NO];
}

- (void)valueChanged:(id)sender
{
    if ([accountTextField.text length]&&[passwordTextField.text length]) {
        [loginButton setEnabled:YES];
    } else {
        [loginButton setEnabled:NO];
    }
}

- (void)findButtonClicked
{
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.bFindPassword = YES;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}

- (void)registerButtonClick
{
    SignOutViewController *signoutViewController = [[SignOutViewController alloc] init];
    [self.navigationController pushViewController:signoutViewController animated:YES];
}

- (void)loginButtonClicked
{
    if ([accountTextField.text length]!=8&&[accountTextField.text length]!=11) {
        [self displayHUDError:nil message:@"手机号不合法"];
        return;
    }
    [self displayHUD:@"登录中"];
    [ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(Member *member,NSString *result,NSString *resultMessage,NSError *error) {
        if (error) {
            [self displayHUDError:nil message:@"网络异常"];
        }else {
            [self hideHUD:YES];
            if ([result isEqualToString:SUCCESS_FLAG]) {
                [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
            } else {
                [self displayHUDError:nil message:resultMessage];
            }
        }
    }];
}

- (void)hidenAllKeyboard {
    for (int i =0; i<2; i++) {
        int tag = 100+i;
        UITextField *textField = (UITextField *)[self.view viewWithTag:tag];
        if (textField&&[textField isKindOfClass:[UITextField class]]) {
            [textField resignFirstResponder];
        }
    }
}


@end
