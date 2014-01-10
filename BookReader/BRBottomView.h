//
//  BRBottomView.h
//  BookReader
//
//  Created by zhangbin on 10/14/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface BRBottomView : UIView

@property (nonatomic, strong) UIButton *bookshelfButton;
@property (nonatomic, strong) UIButton *bookstoreButton;
@property (nonatomic, strong) UIButton *memberButton;

+ (CGFloat)height;
- (void)refresh;

@end
