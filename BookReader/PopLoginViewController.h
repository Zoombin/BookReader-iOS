//
//  LoginViewController.h
//  BookReader
//
//  Created by ZoomBin on 13-7-29.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBViewController.h"

@protocol PopLoginViewControllerDelegate <NSObject>

- (void)popLoginDidLogin;
- (void)popLoginDidCancel;
- (void)popLoginWillSignup;

@end



@interface PopLoginViewController : ZBViewController

@property (nonatomic, weak) id<PopLoginViewControllerDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

@end
