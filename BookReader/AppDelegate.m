//
//  AppDelegate.m
//  BookReader
//
//  Created by ZoomBin on 12-11-22.
//  Copyright (c) 2012年 ZoomBin. All rights reserved.
//

#import "AppDelegate.h"
#import "BookShelfViewController.h"
#import "BRBookStoreViewController.h"
#import "MemberViewController.h"
#import "SignInViewController.h"
#import "ServiceManager.h"
#import "NSString+XXSY.h"
#import "UIColor+BookReader.h"
#import "MobClick.h"
#import "iVersion.h"

@implementation AppDelegate {
    UINavigationController *_navController;
    NSMutableDictionary *_rootControllers;
}

- (void)testApis
{
	//<uid: 472523, name: 天价傻妃:娶一送一>
	[ServiceManager getDownChapterList:@"472523" andUserid:nil withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
		;
	}];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"XXSY.sqlite"];
	
	[iVersion sharedInstance].displayAppUsingStorekitIfAvailable = NO;
	
	//TOTEST
	
//	[ServiceManager saveUserID:@(2797792)];//曹正华
//	[ServiceManager saveUserID:@(5639339)];//yanchao
//	[ServiceManager saveUserID:@(4216157)];//zhangbin
//	[ServiceManager saveUserID:@(5639348)];//ton of fav books
//	[ServiceManager login];
	
	[self testApis];


	
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:REALTIME channelId:nil];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	
	[application setStatusBarHidden:NO];
	
    _rootControllers = [@{} mutableCopy];
    _rootControllers[@(kRootControllerIdentifierBookShelf)] = [[BookShelfViewController alloc] init];
    _rootControllers[@(kRootControllerIdentifierBookStore)] = [[BRBookStoreViewController alloc] init];
    _rootControllers[@(kRootControllerIdentifierMember)] = [[MemberViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self gotoRootController:kRootControllerIdentifierBookShelf];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)gotoRootController:(RootControllerIdentifier)identifier
{
    _navController = [[UINavigationController alloc] initWithRootViewController:_rootControllers[@(identifier)]];
	[_navController setNavigationBarHidden:YES];
    self.window.rootViewController = _navController;
}

- (MemberViewController *)memberVC
{
    return _rootControllers[@(kRootControllerIdentifierMember)];
}

- (void)gotoBookShelf
{
	[self gotoRootController:kRootControllerIdentifierBookShelf];
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
	[iVersion sharedInstance].displayAppUsingStorekitIfAvailable = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[iVersion sharedInstance].displayAppUsingStorekitIfAvailable = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[MagicalRecord cleanUp];
}

@end
