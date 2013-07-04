//
//  UILabel+BookReader.h
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (BookReader)
+ (UILabel *)accountLabelWithFrame:(CGRect)frame;
+ (UILabel *)passwordLabelWithFrame:(CGRect)frame;

+ (UILabel *)bookStoreLabelWithFrame:(CGRect)frame;
+ (UILabel *)titleLableWithFrame:(CGRect)frame;
@end
