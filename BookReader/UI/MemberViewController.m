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
#import "SignInViewController.h"
#import "PasswordViewController.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"
#import "UIColor+Hex.h"
#import "UIView+BookReader.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+BookReader.h"
#import "Member.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "BookReader.h"
#import "BookCell.h"


@implementation MemberViewController
{
    NSArray *fuctionArray;
    Member *_member;
    BOOL isLogin;
    SignInViewController *signViewController;
    UILabel *accountLabel;
    UILabel *moneyLabel;
    
    UITableView *memberTableView;
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
    [self setHideBackBtn:YES];
    [self removeGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([ServiceManager userID] != nil) {
        [ServiceManager userInfoWithBlock:^(Member *member, NSError *error) {
            if (error) {
                isLogin = YES;
                _member = [ServiceManager userInfo];
                [self reloadUI];
            }
            else {
                isLogin = YES;
                _member = member;
                [ServiceManager saveUserInfo:member.coin andName:member.name];
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
    UIImageView *topBarImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [topBarImage setImage:[UIImage imageNamed:@"nav_header"]];
    [self.view addSubview:topBarImage];
    
    UILabel *titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [titleLabel setText:@"个人中心"];
    [self.view addSubview:titleLabel];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    if (!isLogin) {
        [APP_DELEGATE switchToRootController:kRootControllerTypeLogin];
    }else {
        memberTableView = [[UITableView alloc] initWithFrame:CGRectMake(4, 46, self.view.bounds.size.width-8, self.view.bounds.size.height-56) style:UITableViewStylePlain];
        [memberTableView setDelegate:self];
        [memberTableView setDataSource:self];
        [memberTableView setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:241.0/255.0 alpha:1.0]];
        [memberTableView.layer setCornerRadius:5];
        [memberTableView.layer setMasksToBounds:YES];
        [memberTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:memberTableView];
        
        UIButton *logoutButton = [UIButton custumButtonWithFrame:CGRectMake(260, 6, 50, 32)];
        [logoutButton setTitle:@"注销" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:logoutButton];
    }
}

- (void)logoutButtonClicked
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您确定要注销吗? " delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        stopAllSync = YES;
        [self displayHUD:@"正在注销"];
        [self performSelector:@selector(logout) withObject:nil afterDelay:2];
    }
}

- (void)logout
{
	isLogin = NO;
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[ServiceManager deleteUserID];
		[ServiceManager deleteUserInfo];
		[Book truncateAll];
		[Chapter truncateAll];
		[self reloadUI];
		[self hideHUD:YES];
	}];
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

- (void)showMyFav
{
    [APP_DELEGATE switchToRootController:kRootControllerTypeBookShelf];
}

- (void)showChangePasswordView
{
    PasswordViewController *passwordViewController = [[PasswordViewController alloc] init];
    passwordViewController.bFindPassword = NO;
    [self.navigationController pushViewController:passwordViewController animated:YES];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[BookCell alloc] initWithStyle:BookCellStyleCatagory reuseIdentifier:@"MyCell"];
        [(BookCell *)cell setTextLableText:@"1"];
        switch (indexPath.row) {
            case 0:
                [(BookCell *)cell setTextLableText:[NSString stringWithFormat:@"用户名 : %@",_member.name]];
                [(BookCell *)cell hidenArrow:YES];
                break;
            case 1:
                [(BookCell *)cell setTextLableText:[NSString stringWithFormat:@"余额 : %@",_member.coin]];
                [(BookCell *)cell hidenArrow:YES];
                break;
            case 2:
                [(BookCell *)cell setTextLableText:@"修改密码"];
                break;
            case 3:
                [(BookCell *)cell setTextLableText:@"我的收藏"];
                break;
            default:
                break;
        }
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        [self showChangePasswordView];
    } else if (indexPath.row == 3) {
        [self showMyFav];
    }
}

//显示热词
- (void)showhotkeyButton {
    NSArray *cgrectArr = [self randomRect:10];
    for (int i=0; i<[cgrectArr count]; i++) {
        NSString *cgrectstring = [cgrectArr objectAtIndex:i];
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setFrame:CGRectFromString(cgrectstring)];
        [tmpButton setTag:i];
        [tmpButton addTarget:self action:@selector(hotkeybuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [tmpButton setAlpha:0.8];
        [self.view addSubview:tmpButton];
    }
}

- (NSArray *)randomRect:(int)rectCount {
    NSMutableArray *rectArray = [NSMutableArray array];
    while([rectArray count] < rectCount) {
        int x =arc4random()%220+15;    //随机坐标x
        int y = arc4random()%220+100;//随机坐标y
        CGRect rect = CGRectMake(x, y, 80, 30);
        if ([rectArray count] == 0) {
            [rectArray addObject:NSStringFromCGRect(rect)];
            continue;
        }
        BOOL bIntersects = NO;
        for (int i = 0; i < [rectArray count]; ++i) {
            CGRect tmpRect = CGRectFromString([rectArray objectAtIndex:i]);
            if (CGRectIntersectsRect(rect, tmpRect)) {
                //NSLog(@"rect = %@, tmpRect = %@", NSStringFromCGRect(rect), NSStringFromCGRect(tmpRect));
                bIntersects = YES;
            }
        }
        if (bIntersects == NO) {
            [rectArray addObject:NSStringFromCGRect(rect)];
        }
    }
    return rectArray;
}


@end
