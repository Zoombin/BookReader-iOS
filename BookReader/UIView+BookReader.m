//
//  UIView+BookReader.m
//  BookReader
//
//  Created by ZoomBin on 13-5-9.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "UIView+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"

@implementation UIView (BookReader)
+ (UIView *)tableViewFootView:(CGRect)frame andSel:(SEL)selector andTarget:(id)target
{
    UIView *footview = [[UIView alloc]initWithFrame:frame];
    [footview setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(-4, 0, frame.size.width - 4, 26)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setTitle:@"正在加载数据..." forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:button];
    return footview;
}

@end
