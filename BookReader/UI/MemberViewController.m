//
//  ReMyAccountViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-23.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "MemberViewController.h"
#import "AppDelegate.h"
#import "BookShelfButton.h"
#import "Member+Test.h"
#import "ServiceManager.h"
#import "UIDefines.h"
#import "Pay.h"
    
#define ACCOUNT_TEXTFIELD_TAG                   100
#define PASSWORD_TEXTFIELD_TAG                  101
#define REGISTER_ACCOUNT_TEXTFIELD_TAG          102
#define REGISTER_PASSWORD_TEXTFIELD_TAG         103
#define REGISTER_CONFIRM_TEXTFIELD_TAG          104
#define REGISTER_CODE_TEXTFIELD_TAG             105

#define ERROR_MESSAGE_ONE              @"两次输入的密码不一致!"
#define ERROR_MESSAGE_TWO              @"账号不可为空"
#define ERROR_MESSAGE_THREE            @"请输入密码"
#define ERROR_MESSAGE_FOUR             @"请输入确认密码"
#define ERROR_MESSAGE_FIVE             @"请输入短信验证码"
#define ERROR_MESSAGE_SIX              @"用户已经存在"
#define ERROR_MESSAGE_SEVEN            @"密码不正确"
#define ERROR_MESSAGE_EIGHT            @"账户不存在"
#define ERROR_MESSAGE_NINE             @"用户已注册"
#define ERROR_MESSAGE_TEN              @"未知错误，短信发送失败"
#define ERROR_MESSAGE_ELEVEN           @"服务器异常"

#define ERROR_MESSAGE_TWELVE           @"当前ip获取手机验证码过于频繁"
#define ERROR_MESSAGE_THIRTEEN         @"手机号码每天最多只能获取3条手机验证码"
#define ERROR_MESSAGE_FORTEEN          @"手机号码每月最多只能获取10条手机验证码"
#define ERROR_MESSAGE_FIFTEEN          @"验证码失效"
#define ERROR_MESSAGE_SIXTEEN          @"未知错误注册失败"

#define ERROR_MESSAGE_SEVENTEEN        @"请输入旧密码"
#define ERROR_MESSAGE_EIGHTEEN         @"请输入新密码"

#define SUCCESS_MESSAGE_ONE            @"登陆成功"
#define SUCCESS_MESSAGE_TWO            @"注册成功,请登录!"


#define SUCCESS_MESSAGE_THREE          @"验证码将发送到您的手机,请注意查收!"

#define SUCCESS_MESSAGE_FOUR           @"密码修改成功，请重新登录!"

//Test
#define USERDEFAULT_ACCOUNT            @"account"
#define USERDEFAULT_PASSWORD           @"password"


@implementation MemberViewController
{
    NSArray *fuctionArray;
    Member *_member;
    NSNumber *userid;
    BOOL isLogin;
}

- (id)init {
    self = [super init];
    if (self) {
        fuctionArray = [[NSArray alloc] initWithObjects:@"修改密码", @"我的收藏",nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isLogin = NO;
    UIImage*img =[UIImage imageNamed:@"main_view_bkg"];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:img]];
    userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userid"];
    if (userid !=nil) {
        [ServiceManager userInfo:userid withBlock:^(Member *member, NSError *error) {
            if (error) {
                isLogin = NO;
                [self reloadUI];            
            }
            else {
                isLogin = YES;
                _member = member;
                [self reloadUI];
            }
        }];
    }else {
        [self reloadUI];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)reloadUI {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
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
    
    if (!isLogin) {
        UITextField *accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 74, MAIN_SCREEN.size.width-10*2, 30)];
        [accountTextField setPlaceholder:@"请输入账号"];
        [accountTextField setTag:ACCOUNT_TEXTFIELD_TAG];
        [accountTextField setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:accountTextField];
        
        UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 114, MAIN_SCREEN.size.width-10*2, 30)];
        [passwordTextField setPlaceholder:@"请输入密码"];
        [passwordTextField setTag:PASSWORD_TEXTFIELD_TAG];
        [passwordTextField setBackgroundColor:[UIColor whiteColor]];
        [passwordTextField setSecureTextEntry:YES];
        [self.view addSubview:passwordTextField];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [loginButton setFrame:CGRectMake(30, 150, 100, 30)];
        [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [self.view addSubview:loginButton];
        
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [registerButton setFrame:CGRectMake(190, 150, 100, 30)];
        [registerButton addTarget:self action:@selector(showRegisterView) forControlEvents:UIControlEventTouchUpInside];
        [registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [self.view addSubview:registerButton];
        
        UIButton *findButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [findButton setFrame:CGRectMake(30, 190, 100, 30)];
        [findButton addTarget:self action:@selector(showFindPasswodView) forControlEvents:UIControlEventTouchUpInside];
        [findButton setTitle:@"找回密码" forState:UIControlStateNormal];
        [self.view addSubview:findButton];

    }else {
        UITableView *infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44) style:UITableViewStyleGrouped];
        [infoTableView setBackgroundColor:[UIColor clearColor]];
        [infoTableView setBackgroundView:nil];
        [infoTableView setDataSource:self];
        [infoTableView setDelegate:self];
        [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:infoTableView];
        
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [logoutButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
        [logoutButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [logoutButton setFrame:CGRectMake(260, 6, 50, 32)];
        [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
    }
}

- (void)showRegisterView {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    NSArray *placeHolders = @[@"请输入账号", @"请输入密码", @"请再次输入密码", @"请输入短信验证码"];
    NSArray *tags = @[@REGISTER_ACCOUNT_TEXTFIELD_TAG,@REGISTER_PASSWORD_TEXTFIELD_TAG,@REGISTER_CONFIRM_TEXTFIELD_TAG,@REGISTER_CODE_TEXTFIELD_TAG];
    for (int i =0; i<[placeHolders count]; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 74+40*i, MAIN_SCREEN.size.width-10*2, 30)];
        [textField setPlaceholder:placeHolders[i]];
        [textField setTag:[tags[i] intValue]];
        if (i==1||i==2) {
            [textField setSecureTextEntry:YES];
        }
        [textField setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:textField];
    }
    
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [registerButton setFrame:CGRectMake(30, 234, 100, 30)];
    [registerButton addTarget:self action:@selector(registerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    
    UIButton *getCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getCodeButton setFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.view addSubview:getCodeButton];
}

- (void)showPaymentListView {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [ServiceManager paymentHistory:_member.uid pageIndex:@"1" andCount:@"20" withBlock:^(NSArray *payMent,NSString *result,NSError *error) {
        if (error) {

        }else {
            NSString *historyString = @"";
            for (int i =0; i<[payMent count]; i++) {
                Pay *pay = [payMent objectAtIndex:i];
                historyString = [historyString stringByAppendingString:[NSString stringWithFormat:@"订单号:%@充值金额:%@\n",pay.orderID,pay.count]];
            }
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 60, MAIN_SCREEN.size.width, 300)];
            [textView setEditable:NO];
            [textView setText:historyString];
            [self.view addSubview:textView];
        }
    }];
}

- (void)showFindPasswodView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    NSArray *placeHolders = @[@"请输入账号",@"请输入短信验证码", @"请输入新密码", @"请再次输入新密码"];
    NSArray *tags = @[@REGISTER_ACCOUNT_TEXTFIELD_TAG,@REGISTER_CODE_TEXTFIELD_TAG,@REGISTER_PASSWORD_TEXTFIELD_TAG,@REGISTER_CONFIRM_TEXTFIELD_TAG];
    for (int i =0; i<[placeHolders count]; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 74+40*i, MAIN_SCREEN.size.width-10*2, 30)];
        [textField setPlaceholder:placeHolders[i]];
        [textField setTag:[tags[i] intValue]];
        if (i==1||i==2) {
            [textField setSecureTextEntry:YES];
        }
        [textField setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:textField];
    }
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [findButton setFrame:CGRectMake(30, 234, 100, 30)];
    [findButton addTarget:self action:@selector(findPassword) forControlEvents:UIControlEventTouchUpInside];
    [findButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:findButton];
    
    UIButton *getCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [getCodeButton setFrame:CGRectMake(190, 234, 100, 30)];
    [getCodeButton addTarget:self action:@selector(getFindPasswordCode) forControlEvents:UIControlEventTouchUpInside];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.view addSubview:getCodeButton];
}

- (void)findPassword
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:REGISTER_ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:REGISTER_PASSWORD_TEXTFIELD_TAG];
    UITextField *confirmTextField = (UITextField *)[self.view viewWithTag:REGISTER_CONFIRM_TEXTFIELD_TAG];
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:REGISTER_CODE_TEXTFIELD_TAG];
    if ([accountTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_TWO];
        return;
    }
    if ([codeTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_FIVE];
        return;
    }
    if ([passwordTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_THREE];
        return;
    }
    if ([confirmTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_FOUR];
        return;
    }
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
        [self showAlertWithMessage:ERROR_MESSAGE_ONE];
        return;
    }
    [ServiceManager findPassword:accountTextField.text verifyCode:codeTextField.text andNewPassword:passwordTextField.text withBlock:^(NSString *result, NSString *code, NSError *error) {
        if (error) {
            
        }else {
            if ([code isEqualToString:SUCCESS_FLAG]) {
                [self showAlertWithMessage:@"密码修改成功"];
                isLogin = NO;
                [self reloadUI];
            } else {
                [self showAlertWithMessage:@"验证码不正确"];
            }
        }
    }];
}

- (void)getFindPasswordCode
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:REGISTER_ACCOUNT_TEXTFIELD_TAG];
    if ([accountTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_TWO];
        return;
    }
    [ServiceManager postFindPasswordCode:accountTextField.text withBlock:^(NSString *result, NSString *code, NSError *error) {
        if (error) {
            
        } else {
            if ([code isEqualToString:SUCCESS_FLAG]) {
                [self showAlertWithMessage:@"获取验证码成功"];
            } else {
                [self showAlertWithMessage:@"验证码获取失败"];
            }
        }
    }];
}

- (void)showChangePasswordView
{
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
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
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame:CGRectMake(10, 6, 50, 32)];;
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    NSArray *placeHolders = @[@"请输入旧密码", @"请输入新密码", @"请再次输入新密码"];
    NSArray *tags = @[@REGISTER_PASSWORD_TEXTFIELD_TAG,@REGISTER_CONFIRM_TEXTFIELD_TAG,@REGISTER_CODE_TEXTFIELD_TAG];
    for (int i =0; i<[placeHolders count]; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 74+40*i, MAIN_SCREEN.size.width-10*2, 30)];
        [textField setPlaceholder:placeHolders[i]];
        [textField setTag:[tags[i] intValue]];
        [textField setSecureTextEntry:YES];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:textField];
    }
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [changeButton setFrame:CGRectMake(30, 234, 100, 30)];
    [changeButton addTarget:self action:@selector(changeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
}

- (void)changeButtonClicked
{
    UITextField *oldPasswordTextField = (UITextField *)[self.view viewWithTag:REGISTER_PASSWORD_TEXTFIELD_TAG];
    UITextField *newPasswordTextField = (UITextField *)[self.view viewWithTag:REGISTER_CONFIRM_TEXTFIELD_TAG];
    UITextField *confirmPasswordTextField = (UITextField *)[self.view viewWithTag:REGISTER_CODE_TEXTFIELD_TAG];
    if ([oldPasswordTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_SEVENTEEN];
        return;
    }
    if ([newPasswordTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_EIGHTEEN];
        return;
    }
    if ([confirmPasswordTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_FOUR];
        return;
    }
    if (![newPasswordTextField.text isEqualToString:confirmPasswordTextField.text]) {
        [self showAlertWithMessage:ERROR_MESSAGE_ONE];
        return;
    }
   [ServiceManager changePassword:_member.uid oldPassword:oldPasswordTextField.text andNewPassword:newPasswordTextField.text withBlock:^(NSString *result, NSError *error) {
       if (error) {

       }else {
           NSLog(@"%@",result);
           if ([result integerValue]==0000) {
              [self showAlertWithMessage:SUCCESS_MESSAGE_FOUR];
               isLogin = NO;
               [self logoutButtonClicked];
           } else if([result integerValue]==0001) {
               [self showAlertWithMessage:ERROR_MESSAGE_SEVEN];
           }
       }
   }];
}

- (void)registerButtonClicked
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:REGISTER_ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:REGISTER_PASSWORD_TEXTFIELD_TAG];
    UITextField *confirmTextField = (UITextField *)[self.view viewWithTag:REGISTER_CONFIRM_TEXTFIELD_TAG];
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:REGISTER_CODE_TEXTFIELD_TAG];
    if ([accountTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_TWO];
        return;
    }
    if ([passwordTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_THREE];
        return;
    }
    if ([confirmTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_FOUR];
        return;
    }
    if ([codeTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_FIVE];
        return;
    }
    if (![confirmTextField.text isEqualToString:passwordTextField.text]) {
        [self showAlertWithMessage:ERROR_MESSAGE_ONE];
        return;
    }
    [ServiceManager registerByPhoneNumber:accountTextField.text verifyCode:codeTextField.text andPassword:passwordTextField.text withBlock:^(NSString *result, NSError *error) {
        if (error) {

        }else {
            switch ([result integerValue]) {
                case 0000:
                    [self showAlertWithMessage:SUCCESS_MESSAGE_TWO];
                    isLogin = NO;
                    [self reloadUI];
                    break;
                case 0001:
                    [self showAlertWithMessage:ERROR_MESSAGE_SIX];
                    break;
                case 0002:
                    [self showAlertWithMessage:ERROR_MESSAGE_SIXTEEN];
                    break;
                case 0004:
                    [self showAlertWithMessage:ERROR_MESSAGE_FIFTEEN];
                    break;
                default:
                    break;
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
                switch ([result intValue]) {
                    case 0000:
                        [self showAlertWithMessage:SUCCESS_MESSAGE_THREE];
                        break;
                    case 0001:
                        [self showAlertWithMessage:ERROR_MESSAGE_SIX];
                        break;
                    case 0002:
                        [self showAlertWithMessage:ERROR_MESSAGE_THIRTEEN];
                        break;
                    case 0003:
                        [self showAlertWithMessage:ERROR_MESSAGE_FORTEEN];
                        break;
                    case 0004:
                        [self showAlertWithMessage:ERROR_MESSAGE_TWELVE];
                        break;
                    case 0005:
                        [self showAlertWithMessage:ERROR_MESSAGE_TEN];
                        break;
                    default:
                        break;
                }
            }
        }];
    } else {
        [self showAlertWithMessage:ERROR_MESSAGE_TWO];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                       message:nil
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                             otherButtonTitles:nil];
    [alertView show];
}

- (void)logoutButtonClicked
{
    isLogin = NO;
    //清除个人信息等...
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userid"];
    [self reloadUI];
}

- (void)backButtonClicked
{
    isLogin = NO;
    [self reloadUI];
}

- (void)backToLoginView
{
    isLogin = YES;
    [self reloadUI];
}

- (void)loginButtonClicked
{
    UITextField *accountTextField = (UITextField *)[self.view viewWithTag:ACCOUNT_TEXTFIELD_TAG];
    UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:PASSWORD_TEXTFIELD_TAG];
    
    if ([accountTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_TWO];
        return;
    }
    if ([passwordTextField.text length]==0) {
        [self showAlertWithMessage:ERROR_MESSAGE_THREE];
        return;
    }
    [ServiceManager loginByPhoneNumber:accountTextField.text andPassword:passwordTextField.text withBlock:^(Member *member,NSString *result,NSError *error) {
        if (error) {
            isLogin = NO;

        }else {
            isLogin = YES;
            if ([result isEqualToString:SUCCESS_FLAG]) {
                _member = member;
                [self reloadUI];
            }else if([result isEqualToString:@"0001"]) {
                [self showAlertWithMessage:ERROR_MESSAGE_EIGHT];
            }else if([result isEqualToString:@"0002"]) {
                [self showAlertWithMessage:ERROR_MESSAGE_SEVEN];
            }
        }
    }];
}

#pragma mark tableview
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"会员中心";
    }
    return @"功能列表";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }
    return [fuctionArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
        if ([indexPath section]==1) {
            cell.textLabel.text = fuctionArray[[indexPath row]];
        }else {
            if ([indexPath row]==0) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",@"用户名:",_member.name];
            }else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ %@点",@"余额:",_member.coin];
            }
        }
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section]==1) {
        switch ([indexPath row]) {
            case 0:
                [self showChangePasswordView];
                NSLog(@"修改密码");
                break;
            case 1:
                [APP_DELEGATE switchToRootController:kRootControllerTypeBookShelf];
                NSLog(@"我的收藏");
                break;
            default:
                break;
        }
    }
}

- (void)hidenAllKeyboard {
    for (int i =0; i<6; i++) {
        int tag = 100+i;
        UITextField *textField = (UITextField *)[self.view viewWithTag:tag];
        if (textField&&[textField isKindOfClass:[UITextField class]]) {
        [textField resignFirstResponder];
        }
    }
}


@end
