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
#import "MobClick.h"
#import "iVersion.h"

@implementation AppDelegate {
    UINavigationController *_navController;
    NSMutableDictionary *_rootControllers;
}

- (void)testApis
{
	//<uid: 472523, name: 天价傻妃:娶一送一>
//	[ServiceManager getDownChapterList:@"472523" andUserid:nil withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
//		;
//	}];
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

	[self umengTrack];

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

- (void)umengTrack
{
	NSInteger random = arc4random() % 1000;
	if (random == 0) {
		[MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常,注释掉此行
	} else {
		[MobClick setCrashReportEnabled:NO];
	}
	
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试,注意Release发布时需要注释掉此行,减少io消耗
    //[MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息,如果不设置,默认从CFBundleVersion里取
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
	//reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
	//channelId 为NSString * 类型,channelId 为nil或@""时,默认会被被当作@"App Store"渠道
	//[MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
	//[MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    [MobClick updateOnlineConfig];  //在线参数配置
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	NSLog(@"DEEP_LINK: %@", url);
	[[NSNotificationCenter defaultCenter] postNotificationName:DEEP_LINK object:url];
	return YES;
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
	//if ([ServiceManager showDialogs]) {
		[ServiceManager showDialogsSettingsByAppVersion:[NSString appVersion] withBlock:^(BOOL success, NSError *error) {
			[[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
		}];
	//}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[MagicalRecord cleanUp];
}

@end
