//
//  UITextField+category.m
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UITextField+BookReader.h"

@implementation UITextField (BookReader)

+ (UITextField *)customWithFrame:(CGRect)frame
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField setBackgroundColor:[UIColor whiteColor]];
    return textField;
}

+ (UITextField *)accountTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"请输入手机号"];
    return textField;
}

+ (UITextField *)passwordTextFieldWithFrame:(CGRect)frame
{
    UITextField *textField = [self customWithFrame:frame];
    [textField setPlaceholder:@"请输入密码"];
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
