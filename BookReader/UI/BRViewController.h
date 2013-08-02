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

@property (nonatomic, strong) NSArray *keyboardUsers;
@property (nonatomic, strong) BRHeaderView *headerView;

- (void)hideKeyboard;
- (void)removeGestureRecognizer;
- (UIImageView *)backgroundImage;

@end
