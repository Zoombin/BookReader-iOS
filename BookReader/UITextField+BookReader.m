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

+ (UITextField *)customWithFrame:(CGRect)frame
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField.layer setCornerRadius:4];
    [textField.layer setMasksToBounds:YES];
    [textField.layer setBorderWidth:0.5];
    [textField setFont:[UIFont systemFontOfSize:14]];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setBackgroundColor:[UIColor whiteColor]];
    return textField;
}

+ (UITextField *)accountTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"\t\t请输入账号"];
    return textField;
}

+ (UITextField *)passwordTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"\t\t请输入密码"];
    [textField setSecureTextEntry:YES];
    return textField;
}

+ (UITextField *)passwordConfirmTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"\t\t请再次输入密码"];
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
