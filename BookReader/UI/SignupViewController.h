//
//  SignUpViewController.h
//  BookReader
//
//  Created by 颜超 on 13-5-3.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"

@class SignUpViewController;
@protocol SignUpViewControllerDelegate <NSObject>

- (void)signUpDone:(SignUpViewController *)signUpViewController;

@end

@interface SignUpViewController : BRViewController

@property (nonatomic, weak) id<SignUpViewControllerDelegate> delegate;

@end
