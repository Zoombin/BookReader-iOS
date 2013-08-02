//
//  UITextField+category.h
//  BookReader
//
//  Created by 颜超 on 13-5-2.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (BookReader)
+ (UITextField *)accountTextFieldWithFrame:(CGRect)frame;
+ (UITextField *)passwordTextFieldWithFrame:(CGRect)frame;
+ (UITextField *)passwordConfirmTextFieldWithFrame:(CGRect)frame;
+ (UITextField *)codeTextFieldWithFrame:(CGRect)frame;
- (UIImageView *)backgroundView;

+ (UITextField *)loginTextFieldWithFrame:(CGRect)frame;
@end
