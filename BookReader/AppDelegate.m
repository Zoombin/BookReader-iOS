//
//  AppDelegate.m
//  BookReader
//
//  Created by ZoomBin on 12-11-22.
//  Copyright (c) 2012年 ZoomBin. All rights reserved.
//

#import "AppDelegate.h"
#import "BookShelfViewController.h"
#import "BookStoreViewController.h"
#import "MemberViewController.h"
#import "SignInViewController.h"
#import "ServiceManager.h"
#import "NSString+XXSY.h"
#import "MobileProbe.h"
#import "UIColor+BookReader.h"
#import "NavViewController.h"

@implementation AppDelegate {
    NavViewController *_navController;
    NSMutableDictionary *_rootControllers;
}

- (void)testApis
{
//	[ServiceManager paymentHistoryWithPageIndex:@"1" andCount:@"10" withBlock:^(NSArray *resultArray, BOOL success, NSError *error) {
//		
//	}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//TOTEST
	
//	[ServiceManager saveUserID:@(2797792)];//曹正华
//	[ServiceManager saveUserID:@(5639339)];//yanchao
//	[ServiceManager saveUserID:@(4216157)];//zhangbin
//	[ServiceManager saveUserID:@(5639348)];//ton of fav books
//	[ServiceManager login];
	
//	[self testApis];
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[MobileProbe initWithAppKey:M_CNZZ_COM channel:@"iOSChannel"];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"XXSY.sqlite"];
    application.statusBarHidden = NO;
    _rootControllers = [@{} mutableCopy];
    _rootControllers[@(kRootControllerIdentifierBookShelf)] = [[BookShelfViewController alloc] init];
    _rootControllers[@(kRootControllerIdentifierBookStore)] = [[BookStoreViewController alloc] init];
    _rootControllers[@(kRootControllerIdentifierMember)] = [[MemberViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self gotoRootController:kRootControllerIdentifierBookShelf];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)gotoRootController:(RootControllerIdentifier)identifier
{
    _navController = [[NavViewController alloc] initWithRootViewController:_rootControllers[@(identifier)]];
    [_navController setNavigationBarHidden:YES];
    self.window.rootViewController = _navController;
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
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[MagicalRecord cleanUp];
}

@end
