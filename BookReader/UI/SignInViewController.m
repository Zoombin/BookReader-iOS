//
//  SignInViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SignInViewController.h"
#import "BookReader.h"
#import "ServiceManager.h"
#import "BookShelfButton.h"
#import "UIViewController+HUD.h"
#import "UITextField+BookReader.h"
#import "SignOutViewController.h"
#import "PasswordViewController.h"
#import "AppDelegate.h"
#import "UILabel+BookReader.h"
#import "UIButton+BookReader.h"
#import "UIManager.h"
#import <QuartzCore/QuartzCore.h>

#define ACCOUNT_TEXTFIELD_TAG                   100
#define PASSWORD_TEXTFIELD_TAG                  101

@implementation SignInViewController {
    UITextField *accountTextField;
    UITextField *passwordTextField;
    
    UIButton *loginButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage*img =[UIImage imageNamed:@"main_view_bkg"];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:img]];
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
//    [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
//    [self.view addSubview:backgroundImage];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"个人中心"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *hidenKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidenKeyboardButton setFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44)];
    [hidenKeyboardButton addTarget:self action:@selector(hidenAllKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hidenKeyboardButton];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    UIView *loginBkgView = [[UIView alloc] initWithFrame:CGRectMake(5, 44, self.view.bounds.size.width-5*2, 200)];
    [loginBkgView.layer setCornerRadius:4];
    [loginBkgView.layer setMasksToBounds:YES];
    [loginBkgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:loginBkgView];
    
    UIView *loginMiddleView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, loginBkgView.bounds.size.width, 100)];
    [loginMiddleView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [loginBkgView addSubview:loginMiddleView];
    
    UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    [loginLabel setText:@"登录"];
    [loginLabel setTextAlignment:NSTextAlignmentCenter];
    [loginLabel setBackgroundColor:[UIColor clearColor]];
    [loginLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [loginLabel setTextColor:[UIManager hexStringToColor:@"dd8e28"]];
    [loginBkgView addSubview:loginLabel];
   
    UILabel *accountLabel = [UILabel accountLabelWithFrame:CGRectMake(5, 94, 70, 30)];
    [self.view addSubview:accountLabel];
    
    accountTextField = [UITextField accountTextFieldWithFrame:CGRectMake(80, 94, MAIN_SCREEN.size.width-80*2, 30)];
    [accountTextField setTag:ACCOUNT_TEXTFIELD_TAG];
    [accountTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:accountTextField];
    
    UILabel *passwordLabel = [UILabel passwordLabelWithFrame:CGRectMake(5, 134, 70, 30)];
    [self.view addSubview:passwordLabel];
    
    passwordTextField = [UITextField passwordTextFieldWithFrame:CGRectMake(80, 134, MAIN_SCREEN.size.width-80*2, 30)];
    [passwordTextField setTag:PASSWORD_TEXTFIELD_TAG];
    [passwordTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:passwordTextField];
    
     loginButton = [UIButton createButtonWithFrame:CGRectMake(30, 200, 80, 30)];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setEnabled:NO];
    [self.view addSubview:loginButton];
    
    UIButton *registerButton = [UIButton createButtonWithFrame:CGRectMake(210, 200, 80, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [findButton setFrame:CGRectMake(passwordTextField.frame.origin.x+passwordTextField.frame.size.width+10, passwordTextField.frame.origin.y, 50, 30)];
    [findButton addTarget:self action:@selector(findButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [findButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [findButton setTitleColor:[UIColor colorWithRed:124.0/255.0 green:122.0/255.0 blue:114.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [findButton setTitle:@"忘记了" forState:UIControlStateNormal];
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
    [self displayHUD:@"登录中"];
    [ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(Member *member,NSString *result,NSString *resultMessage,NSError *error) {
        if (error) {
            [self displayHUDError:nil message:@"网络异常"];
        }else {
            [self hideHUD:YES];
            if ([result isEqualToString:SUCCESS_FLAG]) {
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
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
