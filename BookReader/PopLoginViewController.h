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

@end



@interface PopLoginViewController : ZBViewController

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<PopLoginViewControllerDelegate> delegate;
@property (nonatomic, assign) SEL actionAfterLogin;
@property (nonatomic, assign) SEL actionAfterCancel;

@end
