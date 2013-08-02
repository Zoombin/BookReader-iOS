//
//  BookShelfButton.m
//  BookReader
//
//  Created by zhangbin on 3/27/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BookShelfButton.h"
#import "BookStoreViewController.h"
#import "AppDelegate.h"
#import "UIColor+Hex.h"
#import "UIButton+BookReader.h"

@implementation BookShelfButton

- (id)init
{
    self = [super init];
    if (self) {
        [self setTitle:@"书架" forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"universal_btn"] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [self setFrame:CGRectMake(10, 3, 50, 32)];
        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clicked
{
    [APP_DELEGATE gotoRootController:kRootControllerTypeBookShelf];
}

@end
