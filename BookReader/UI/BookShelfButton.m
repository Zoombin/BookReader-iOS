//
//  BookShelfButton.m
//  BookReader
//
//  Created by zhangbin on 3/27/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "BookShelfButton.h"
#import "BookStoreViewController.h"
#import "AppDelegate.h"
#import "UIColor+Hex.h"

@implementation BookShelfButton

- (id)init
{
    self = [super init];
    if (self) {
        [self setTitle:@"书架" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor hexRGB:0xfbbf90] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [self setFrame:CGRectMake(10, 6, 50, 32)];
        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clicked
{
    [APP_DELEGATE switchToRootController:kRootControllerTypeBookShelf];
}

@end
