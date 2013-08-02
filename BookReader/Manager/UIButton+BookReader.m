//
//  UIButton+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "UIButton+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"

#define EnabledColorHex 0xc0683a
static float duration = 0;
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

+ (UIButton *)addButtonWithFrame:(CGRect)frame andStyle:(BookReaderButtonStyle)style
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    if (style == BookReaderButtonStyleLeft) {
        [button setBackgroundImage:[UIImage imageNamed:@"universal_btn_l"] forState:UIControlStateNormal];
    } else if (style == BookReaderButtonStyleRight) {
        [button setBackgroundImage:[UIImage imageNamed:@"universal_btn_r"] forState:UIControlStateNormal];
    } else if (style == BookReaderButtonStyleNormal) {
        [button setBackgroundImage:[UIImage imageNamed:@"universal_btn"] forState:UIControlStateNormal];
    } else if (style == BookReaderButtonStyleBack) {
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [button setBackgroundImage:[UIImage imageNamed:@"universal_back_btn"] forState:UIControlStateNormal];
    }
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setFrame:frame];
    return button;
}

+ (UIButton *)navigationBackButton
{
	UIButton *backButton = [UIButton addButtonWithFrame:CGRectMake(0, 0, 0, 0) andStyle:BookReaderButtonStyleNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
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

- (void)cooldownButtonFrame:(CGRect)frame andEnableCooldown:(BOOL)cooldown
{
    [self setFrame:frame];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn_hl"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn_disable"] forState:UIControlStateDisabled];
    if (cooldown) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:1.0];
    }
}

+ (UIButton *)fontButton:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
//    [button setBackgroundImage:[UIImage imageNamed:@"font_select"] forState:UIControlStateDisabled];
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    return button;
}

- (void)startCoolDownDuration:(NSTimeInterval)delay
{
    duration = delay;
    [self setEnabled:NO];
}

- (void)refresh
{
    if (duration == 0) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:1.0];
        return;
    }
    NSLog(@"%f",duration);
    duration--;
    NSString *newTitle = self.titleLabel.text;
    NSRange range = [newTitle rangeOfString:@"("];
    if (range.location != NSNotFound) {
        newTitle = [newTitle substringToIndex:range.location];
    }
    if (duration <= 0) {
        [self setEnabled:YES];
        [self setTitle:newTitle forState:UIControlStateNormal];
        [self performSelector:@selector(refresh) withObject:nil afterDelay:1.0];
    } else {
        newTitle = [NSString stringWithFormat:@"%@(%d)",newTitle,(int)duration];
        [self performSelector:@selector(refresh) withObject:nil afterDelay:1.0];
        [self setTitle:newTitle forState:UIControlStateNormal];
    }
}

@end
