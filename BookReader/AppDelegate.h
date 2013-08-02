//
//  AppDelegate.h
//  BookReader
//
//  Created by ZoomBin on 12-11-22.
//  Copyright (c) 2012年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    kRootControllerTypeBookShelf,
    kRootControllerTypeBookStore,
    kRootControllerTypeMember,
    kRootControllerTypeLogin,
}RootControllerType;

#define APP_DELEGATE ( (AppDelegate *)[[UIApplication sharedApplication] delegate] )

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

- (void)gotoRootController:(RootControllerType)type;
@end
