//
//  UIColor+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-9.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UIColor+BookReader.h"

@implementation UIColor (BookReader)

+ (UIColor *)mainBackgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_view_bkg"]];
}

+ (UIColor *)txtColor
{
    return [UIColor colorWithRed:91.0/255.0 green:33.0/255.0 blue:0.0/255.0 alpha:1.0];  //UI的字体颜色

}

+ (UIColor *)bookCellGrayTextColor
{
    return [UIColor colorWithRed:162.0/255.0 green:160.0/255.0 blue:147.0/255.0 alpha:1.0];
}
@end
