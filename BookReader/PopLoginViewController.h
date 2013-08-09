//
//  LoginViewController.h
//  BookReader
//
//  Created by ZoomBin on 13-7-29.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopLoginViewControllerDelegate <NSObject>

- (void)didLogin:(BOOL)success;

@end



@interface PopLoginViewController : UIViewController

@property (nonatomic, weak) id<PopLoginViewControllerDelegate> delegate;

@end
