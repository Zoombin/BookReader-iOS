//
//  UITextField+category.m
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UITextField+BookReader.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITextField (BookReader)

- (UIImageView *)backgroundView
{
	UIImageView *fieldBackground = [[UIImageView alloc] initWithFrame:CGRectInset(self.frame, -7, 0)];
	[fieldBackground setImage:[[UIImage imageNamed:@"text_field_background"] stretchableImageWithLeftCapWidth:11 topCapHeight:8]];
	return fieldBackground;
}

+ (UITextField *)customWithFrame:(CGRect)frame
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField setFont:[UIFont systemFontOfSize:14]];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setBackgroundColor:[UIColor clearColor]];
    return textField;
}

+ (UITextField *)accountTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"请输入账号"];
    return textField;
}

+ (UITextField *)passwordTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"请输入密码"];
    [textField setSecureTextEntry:YES];
    return textField;
}

+ (UITextField *)passwordConfirmTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"请再次输入密码"];
    [textField setSecureTextEntry:YES];
    return textField;
}

+ (UITextField *)codeTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"请输入验证码"];
    return textField;
}


@end
