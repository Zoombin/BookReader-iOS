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
#import "AppDelegate.h"

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

- (void)memberButton:(CGRect)frame
{
    [self setFrame:frame];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn_hl"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn_disable"] forState:UIControlStateDisabled];
}

+ (UIButton *)fontButton:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    return button;
}

+ (UIButton *)bookStoreTabBarButtonWithFrame:(CGRect)frame andStyle:(BRBookStoreTabBarButtonStyle)style
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor cyanColor] forState:UIControlStateSelected];
	button.showsTouchWhenHighlighted = YES;
	button.titleLabel.font = [UIFont systemFontOfSize:16];
    return button;
}

+ (UIButton *)bookShelfButtonWithStartPosition:(CGPoint)position
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:@"书架" forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"universal_btn"] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	[button setFrame:CGRectMake(position.x, position.y, 50, 32)];
	[button addTarget:APP_DELEGATE action:@selector(gotoBookShelf) forControlEvents:UIControlEventTouchUpInside];
	button.showsTouchWhenHighlighted = YES;
	return button;
}

+ (UIButton *)bookMenuButtonWithFrame:(CGRect)frame andTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];
    [button.layer setBorderWidth:0.5];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    
    UILabel *btnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
    [btnTitleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnTitleLabel setTextColor:[UIColor whiteColor]];
    [btnTitleLabel setBackgroundColor:[UIColor clearColor]];
    [btnTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnTitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [btnTitleLabel setText:title];
    [button addSubview:btnTitleLabel];
    
    return button;
}

- (void)shelfCategoryButtonStyle
{
	self.showsTouchWhenHighlighted = YES;
	[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageNamed:@"btn_bg_click"] forState:UIControlStateHighlighted];
}

@end
