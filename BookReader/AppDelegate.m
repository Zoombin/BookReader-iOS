//
//  AppDelegate.m
//  BookReader
//
//  Created by 颜超 on 12-11-22.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "BookShelfViewController.h"
#import "BookStoreViewController.h"
#import "MemberViewController.h"
#import "HouseAppListViewController.h"
#import "AboutViewController.h"
#import "HouseBookListViewController.h"
#import "BookManager.h"
#import "Constants.h"
#import "ServiceManager.h"
#import "NSString+XXSYDecoding.h"

#define REMOTE_MODE

@implementation AppDelegate {
    UINavigationController *navController;
    NSMutableDictionary *rootControllers;
    UIView *tabBar;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStack];
    [MobClick startWithAppkey:UMengAppKey reportPolicy:REALTIME channelId:nil];//友盟初始化
    application.statusBarHidden = NO;
    rootControllers = [@{} mutableCopy];
    BookShelfViewController *bookShelfViewController = [[BookShelfViewController alloc] init];
    rootControllers[@(kRootControllerTypeBookShelf)] = bookShelfViewController;
#ifdef REMOTE_MODE
    bookShelfViewController.layoutStyle = kBookShelfLayoutStyleShelfLike;
    
    BookStoreViewController *bookStoreViewController = [[BookStoreViewController alloc] init];
    rootControllers[@(kRootControllerTypeBookStore)] = bookStoreViewController;
    
    MemberViewController *memberViewController = [[MemberViewController alloc] init];
    rootControllers[@(kRootControllerTypeMember)] = memberViewController;
#else
    //[[BookManager sharedInstance] createTxtInfo];//扫描作者信息和书名到Documents下面，用于iTunes Connect
    
    bookShelfViewController.layoutStyle = kBookShelfLayoutStyleTableList;
    
    HouseBookListViewController *houseBookListViewController = [[HouseBookListViewController alloc] init];
    rootControllers[@(kRootControllerTypeHouseBook)] = houseBookListViewController;
    
    HouseAppListViewController *houseAppListViewController = [[HouseAppListViewController alloc] init];
    rootControllers[@(kRootControllerTypeHouseApp)] = houseAppListViewController;
    
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    rootControllers[@(kRootControllerTypeAbout)] = aboutViewController;
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self switchToRootController:kRootControllerTypeBookShelf];
#ifndef REMOTE_MODE
    [self createTabBar];
#endif
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)createTabBar {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN.size.height-35-20, MAIN_SCREEN.size.width, 35)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *botomBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 35)];
    [botomBackgroundView setImage:[UIImage imageNamed:@"main_bottombackground.png"]];
    [bottomView addSubview:botomBackgroundView];
    
    UIButton *bookShelfButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bookShelfButton setTitle:NSLocalizedString(@"BookList", nil) forState:UIControlStateNormal];
    [bookShelfButton setTitleColor:txtColor forState:UIControlStateNormal];
    [bookShelfButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [bookShelfButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    [bookShelfButton setFrame:CGRectMake(3, 4, -6+MAIN_SCREEN.size.width/4, 27)];
    bookShelfButton.tag = kRootControllerTypeBookShelf;
    [bookShelfButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:bookShelfButton];
    
    UIButton *houseBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [houseBookButton setFrame:CGRectMake(MAIN_SCREEN.size.width/2+3, 4, -6+MAIN_SCREEN.size.width/4, 27)];
    [houseBookButton setTitleColor:txtColor forState:UIControlStateNormal];
    [houseBookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [houseBookButton setTitle:NSLocalizedString(@"AppRecommand", nil) forState:UIControlStateNormal];
    [houseBookButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    houseBookButton.tag = kRootControllerTypeHouseBook;
    [houseBookButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:houseBookButton];
    
    UIButton *houseAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [houseAppButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    [houseAppButton setTitleColor:txtColor forState:UIControlStateNormal];
    [houseAppButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [houseAppButton setTitle:NSLocalizedString(@"BookStore", nil) forState:UIControlStateNormal];
    [houseAppButton setFrame:CGRectMake(MAIN_SCREEN.size.width/4+3, 4, -6+MAIN_SCREEN.size.width/4, 27)];
    houseAppButton.tag = kRootControllerTypeHouseApp;
    [houseAppButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:houseAppButton];
    
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aboutButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    [aboutButton setTitleColor:txtColor forState:UIControlStateNormal];
    [aboutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [aboutButton setTitle:NSLocalizedString(@"AboutUs", nil) forState:UIControlStateNormal];
    [aboutButton setFrame:CGRectMake(MAIN_SCREEN.size.width*0.75+3, 4, -6+MAIN_SCREEN.size.width/4, 27)];
    aboutButton.tag = kRootControllerTypeAbout;
    [aboutButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:aboutButton];
    
    tabBar = bottomView;
    [navController.view addSubview:tabBar];
}

- (void)bottomButtonTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self switchToRootController:(RootControllerType)button.tag];
}

- (void)switchToRootController:(RootControllerType)type
{
    UIViewController *controller = rootControllers[@(type)];
    navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [navController setNavigationBarHidden:YES];
    self.window.rootViewController = navController;
#ifndef REMOTE_MODE
    if (tabBar) {
        [navController.view addSubview:tabBar];
    } else {
        [self createTabBar];
    }
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
