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
#import "SignInViewController.h"
#import "HouseAppListViewController.h"
#import "AboutViewController.h"
#import "HouseBookListViewController.h"
#import "BookReader.h"
#import "ServiceManager.h"
#import "NSString+XXSY.h"
#import "BookReaderDefaultsManager.h"
#import "MobileProbe.h"
#import "UIColor+BookReader.h"

#define REMOTE_MODE

@implementation AppDelegate {
    UINavigationController *navController;
    NSMutableDictionary *rootControllers;
    UIView *tabBar;
}

- (void)testApis
{
	NSString *documentDir = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"txt"];
    NSString *string = [[NSString alloc]initWithContentsOfFile:documentDir encoding:NSUTF8StringEncoding error:nil];
    //string = @"393558745974";
	NSString *decodedString = [string XXSYDecodingWithKey:@"522601"];
    NSLog(@"==>%@",[decodedString substringToIndex:decodedString.length]);
	
//	[ServiceManager androidPayWithType:@"2" andPhoneNum:@"13862090556" andCount:@"200" andUserName:@"13862090556" WithBlock:^(NSString *result, NSError *error) {
//        if (error) {
//            NSLog(@"%@",error);
//        }
//    }];
//    [ServiceManager godStatePayCardNum:@"981301623806121" andCardPassword:@"9809849707937394320" andCount:@"5000" andUserName:@"13862090556" WithBlock:^(NSString *result, NSError *error) {
//
//    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//TOTEST
//	[self testApis];
//	[ServiceManager saveUserID:@(5639339)];//yanchao
//	[ServiceManager saveUserID:@(4216157)];//zhangbin
//	[ServiceManager saveUserID:@(5639348)];//ton of fav books
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[MobileProbe initWithAppKey:M_CNZZ_COM channel:@"iOSChannel"];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"XXSY.sqlite"];
    application.statusBarHidden = NO;
    rootControllers = [@{} mutableCopy];
    rootControllers[@(kRootControllerTypeBookShelf)] = [[BookShelfViewController alloc] init];
#ifdef REMOTE_MODE
    rootControllers[@(kRootControllerTypeBookStore)] = [[BookStoreViewController alloc] init];
    rootControllers[@(kRootControllerTypeMember)] = [[MemberViewController alloc] init];
    rootControllers[@(kRootControllerTypeLogin)] = [[SignInViewController alloc] init];
#else
    //[[BookManager sharedInstance] createTxtInfo];//扫描作者信息和书名到Documents下面，用于iTunes Connect
    rootControllers[@(kRootControllerTypeHouseBook)] = [[HouseBookListViewController alloc] init];
    rootControllers[@(kRootControllerTypeHouseApp)] = [[HouseAppListViewController alloc] init];
    rootControllers[@(kRootControllerTypeAbout)] = [[AboutViewController alloc] init];
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
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.window.bounds.size.height-35-20, self.window.bounds.size.width, 35)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *botomBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, 35)];
    [botomBackgroundView setImage:[UIImage imageNamed:@"main_bottombackground.png"]];
    [bottomView addSubview:botomBackgroundView];
    
    UIButton *bookShelfButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bookShelfButton setTitle:NSLocalizedString(@"BookList", nil) forState:UIControlStateNormal];
    [bookShelfButton setTitleColor:[UIColor txtColor] forState:UIControlStateNormal];
    [bookShelfButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [bookShelfButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    [bookShelfButton setFrame:CGRectMake(3, 4, -6+self.window.bounds.size.width/4, 27)];
    bookShelfButton.tag = kRootControllerTypeBookShelf;
    [bookShelfButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:bookShelfButton];
    
    UIButton *houseBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [houseBookButton setFrame:CGRectMake(self.window.bounds.size.width/2+3, 4, -6+self.window.bounds.size.width/4, 27)];
    [houseBookButton setTitleColor:[UIColor txtColor] forState:UIControlStateNormal];
    [houseBookButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [houseBookButton setTitle:NSLocalizedString(@"AppRecommend", nil) forState:UIControlStateNormal];
    [houseBookButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    houseBookButton.tag = kRootControllerTypeHouseBook;
    [houseBookButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:houseBookButton];
    
    UIButton *houseAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [houseAppButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    [houseAppButton setTitleColor:[UIColor txtColor] forState:UIControlStateNormal];
    [houseAppButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [houseAppButton setTitle:NSLocalizedString(@"BookStore", nil) forState:UIControlStateNormal];
    [houseAppButton setFrame:CGRectMake(self.window.bounds.size.width/4+3, 4, -6+self.window.bounds.size.width/4, 27)];
    houseAppButton.tag = kRootControllerTypeHouseApp;
    [houseAppButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:houseAppButton];
    
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aboutButton setBackgroundImage:[UIImage imageNamed:@"main_buttonpressed.png"] forState:UIControlStateHighlighted];
    [aboutButton setTitleColor:[UIColor txtColor] forState:UIControlStateNormal];
    [aboutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [aboutButton setTitle:NSLocalizedString(@"AboutUs", nil) forState:UIControlStateNormal];
    [aboutButton setFrame:CGRectMake(self.window.bounds.size.width*0.75+3, 4, -6+self.window.bounds.size.width/4, 27)];
    aboutButton.tag = kRootControllerTypeAbout;
    [aboutButton addTarget:self action:@selector(bottomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:aboutButton];
    
    tabBar = bottomView;
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
    if (!tabBar) {
		[self createTabBar];
	}
	[navController.view addSubview:tabBar];
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
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[MagicalRecord cleanUp];
}

@end
