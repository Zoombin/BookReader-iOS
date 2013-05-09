//
//  UIView+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-9.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UIView+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIManager.h"

@implementation UIView (BookReader)
+ (UIView *)loginBackgroundViewWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view.layer setCornerRadius:4];
    [view.layer setMasksToBounds:YES];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *loginMiddleView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, view.bounds.size.width, 100)];
    [loginMiddleView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [view addSubview:loginMiddleView];
    
    UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    [loginLabel setText:title];
    [loginLabel setTextAlignment:NSTextAlignmentCenter];
    [loginLabel setBackgroundColor:[UIColor clearColor]];
    [loginLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [loginLabel setTextColor:[UIManager hexStringToColor:@"dd8e28"]];
    [view addSubview:loginLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(65, 14, 15, 10)];
    [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    [view addSubview:arrowImageView];
    
    return view;
}

+ (UIView *)changeBackgroundViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view.layer setCornerRadius:4];
    [view.layer setMasksToBounds:YES];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *changeMiddleView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, view.bounds.size.width, 140)];
    [changeMiddleView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [view addSubview:changeMiddleView];
    return view;
}

+ (UIView *)findBackgroundViewWithFrame:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view.layer setCornerRadius:4];
    [view.layer setMasksToBounds:YES];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *findMiddleView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, view.bounds.size.width, 170)];
    [findMiddleView setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [view addSubview:findMiddleView];
    return view;
}

+ (UIView *)userBackgroundViewWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view.layer setCornerRadius:4];
    [view.layer setMasksToBounds:YES];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
    [loginLabel setText:title];
    [loginLabel setTextAlignment:NSTextAlignmentCenter];
    [loginLabel setBackgroundColor:[UIColor clearColor]];
    [loginLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [loginLabel setTextColor:[UIManager hexStringToColor:@"dd8e28"]];
    [view addSubview:loginLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 14, 15, 10)];
    [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    [view addSubview:arrowImageView];
    
    return view;
}

@end
