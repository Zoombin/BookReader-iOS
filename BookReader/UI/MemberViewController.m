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
#import "ServiceManager.h"
#import "UIDefines.h"
#import "SignInViewController.h"
#import "PasswordViewController.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultManager.h"
    


@implementation MemberViewController
{
    NSArray *fuctionArray;
    Member *_member;
    NSNumber *userid;
    BOOL isLogin;
    SignInViewController *signViewController;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    userid = [BookReaderDefaultManager userID];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    if (!isLogin) {
        [APP_DELEGATE switchToRootController:kRootControllerTypeLogin];
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

- (void)logoutButtonClicked
{
    isLogin = NO;
    //清除个人信息等...
    [BookReaderDefaultManager deleteUserID];
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
                break;
            case 1:
                [APP_DELEGATE switchToRootController:kRootControllerTypeBookShelf];
                break;
            default:
                break;
        }
    }
}

- (void)showChangePasswordView
{
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.bFindPassword = NO;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}


@end
