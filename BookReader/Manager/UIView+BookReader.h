//
//  UIView+BookReader.h
//  BookReader
//
//  Created by 颜超 on 13-5-9.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BookReader)
+ (UIView *)loginBackgroundViewWithFrame:(CGRect)frame
                           andTitle:(NSString *)title;

+ (UIView *)userBackgroundViewWithFrame:(CGRect)frame
                               andTitle:(NSString *)title;
@end
