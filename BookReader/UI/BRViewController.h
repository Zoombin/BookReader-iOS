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

@property (nonatomic, assign) BOOL hideBackBtn;
@property (nonatomic, strong) NSArray *keyboardUsers;


- (void)hideKeyboard;
- (void)removeGestureRecognizer;
- (BRHeaderView *)BRHeaderView;
- (UIImageView *)backgroundImage;

@end
