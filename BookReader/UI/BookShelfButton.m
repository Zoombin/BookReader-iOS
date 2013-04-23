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

@implementation BookShelfButton

- (id)init
{
    self = [super init];
    if (self) {
        [self setTitle:@"书架" forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self setFrame:CGRectMake(10, 6, 50, 32)];
        [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clicked
{
    [APP_DELEGATE switchToRootController:kRootControllerTypeBookShelf];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
