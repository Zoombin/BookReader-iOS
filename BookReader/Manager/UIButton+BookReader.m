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
	//[button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
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
    [backButton setBackgroundImage:[UIImage imageNamed:@"universal_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"universal_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
	return backButton;
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
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [button setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
	[button setFrame:frame];
    return button;
}

+ (UIButton *)brownButton:(CGRect)frame
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	return button;
}
@end
