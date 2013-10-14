//
//  BRViewController.h
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRHeaderView.h"
#import "ZBViewController.h"

@interface BRViewController : ZBViewController

@property (nonatomic, strong) BRHeaderView *headerView;
@property (nonatomic, strong) UIView *backgroundView;

@end
