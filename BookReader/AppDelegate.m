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

- (void)testAPIs
{
    //    NSString *documentDir = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"txt"];
    //    NSString *string = [[NSString alloc]initWithContentsOfFile:documentDir encoding:NSUTF8StringEncoding error:nil];
    //    //string = @"35B3";
    //    NSLog(@"==>%@",[string XXSYDecodingWithKey:@"522601"]);
    //    NSLog(@"%@", [[NSData  dataWithBase64EncodedString:@"asdadasdsa"] base64Encoding]);
    //    NSData *data = [NSData data];
    //    [[NSData  dataWithBase64EncodedString:@"adadasd"] base64Encoding];
    //    [ServiceManager verifyCodeByPhoneNumber:@"13862090556" withBlock:nil];
    //    [ServiceManager registerByPhoneNumber:@"13862090556" verifyCode:@"9162" andPassword:@"123456" withBlock:nil];
    //    [ServiceManager loginByPhoneNumber:@"13862090556" andPassword:@"123456" withBlock:nil];
    //    [ServiceManager changePassword:@"5508883" andOldPassword:@"123456" andNewPassword:@"123456" withBlock:nil];
    //    [ServiceManager postFindPasswordCode:@"15850236194" withBlock:nil];
    //    [ServiceManager findPassword:@"15850236194" andverifiyCode:@"7394" andNewPassword:@"654321" withBlock:nil];
    //    [ServiceManager getUserInfo:@"5508883" withBlock:nil];
//        [ServiceManager pay:@"5639339" type:@"5" withBlock:nil];
    //    [ServiceManager getUserPayList:@"5508883" andPageIndex:@"1" andCount:@"10" withBlock:nil];
    //    [ServiceManager seachBook:@"" withBlock:nil];
    //    [ServiceManager getRecommandBooksWithBlock:nil];
    //    [ServiceManager getBooks:@"玄幻" andClassId:@"0" andRanking:@"0" andSize:@"10" andIndex:@"1" withBlock:nil];
    //    [ServiceManager bookDiccusssListByBookId:@"449218" size:@"10" andIndex:@"1" withBlock:nil];
    //    [ServiceManager bookDetailInfoByBookId:@"449218" andIntro:@"1" withBlock:nil];
    //   [ServiceManager bookCatalogueList:@"449218" andNewestCataId:@"0" withBlock:nil];
    //     [ServiceManager bookCatalogue:@"5067267" andUserid:@"5508883" withBlock:nil];
    //    [ServiceManager ChapterSubscribe:@"5508883" chapterId:@"5067267" bookId:@"449218" authorId:@"285344" andPrice:@"0" withBlock:nil];
    //  [ServiceManager userBooks:@"5508883" size:@"10" andIndex:@"1" withBlock:nil];
    //    [ServiceManager favBook:@"5508883" Bookid:@"449218" andValue:YES withBlock:nil];
    //    [ServiceManager autoSubscribe:@"5508883" Bookid:@"449218" andValue:@"1" withBlock:nil];
    //    [ServiceManager disscussSend:@"5508883" bookid:@"449218" andContent:@"111adasdasdasd" withBlock:nil];
    //    [ServiceManager authorOtherBook:@"285344" andCount:@"10" withBlock:nil];
    //    [ServiceManager bookRecommand:@"1" andCount:@"10" withBlock:nil];
    //    [ServiceManager checkIsExist:@"5508883" andBookid:@"449218" withBlock:nil];
    //    [ServiceManager giveGift:@"5508883" type:@"" andBookid:@"449218" withBlock:nil];
    //    [ServiceManager giveGift:@"5508883" type:@"5" authorid:@"285344" count:@"1" integral:@"1" andBookid:@"449218" withBlock:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self testAPIs];

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

- (void)shouldRefreshBookStore
{
    BookStoreViewController *bookStoreViewController = rootControllers[@(kRootControllerTypeBookStore)];
    [bookStoreViewController shouldRefresh];
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
