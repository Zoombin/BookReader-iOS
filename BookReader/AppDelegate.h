//
//  AppDelegate.h
//  BookReader
//
//  Created by 颜超 on 12-11-22.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    kRootControllerTypeBookShelf,
    kRootControllerTypeBookStore,
    kRootControllerTypeMember,
    kRootControllerTypeHouseBook,
    kRootControllerTypeHouseApp,
    kRootControllerTypeAbout
}RootControllerType;

#define APP_DELEGATE ( (AppDelegate *)[[UIApplication sharedApplication] delegate] )

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

- (void)switchToRootController:(RootControllerType)type;
- (void)shouldRefreshBookStore;
@end
