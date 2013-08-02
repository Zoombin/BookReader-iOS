//
//  BRViewController.h
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRHeaderView.h"

@interface BRViewController : UIViewController

@property (nonatomic, strong) BRHeaderView *headerView;
@property (nonatomic, strong) UITapGestureRecognizer *hideKeyboardRecognzier;

- (void)hideKeyboard;
- (UIImageView *)backgroundImage;

@end
