//
//  UIButton+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UIButton+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"

#define EnabledColorHex 0xc0683a

@implementation UIButton (BookReader)
+ (UIButton *)initButtonWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor hexRGB:EnabledColorHex]];
	button.showsTouchWhenHighlighted = YES;
    [button.layer setCornerRadius:4];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button.layer setMasksToBounds:YES];
    [button setFrame:frame];
    return button;
}

+ (UIButton *)navigationBackButton
{
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bookreader_universal_btn"] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
	return backButton;
}

+ (UIButton *)custumButtonWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundImage:[UIImage imageNamed:@"bookreader_universal_btn"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
	return button;
}

- (void)setDisabled:(BOOL)disabled
{
	self.enabled = !disabled;
	UIColor *color;
	if (disabled) {
		color = [UIColor grayColor];
	} else {
		color = [UIColor hexRGB:EnabledColorHex];
	}
	[UIView animateWithDuration:0.2 animations:^(void) {
		self.backgroundColor = color;
	}];
}

+ (UIButton *)createButtonWithFrame:(CGRect)frame
{
    UIButton *button = [self initButtonWithFrame:frame];
    return button;
}

+ (UIButton *)createMemberbuttonFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundImage:[UIImage imageNamed:@"member_btn"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"member_btn_hl"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:@"member_btn_disable"] forState:UIControlStateDisabled];
    return button;
}

+ (UIButton *)fontButton:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setBackgroundImage:[UIImage imageNamed:@"font_select"] forState:UIControlStateDisabled];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    return button;
}

@end
