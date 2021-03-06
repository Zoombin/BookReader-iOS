//
//  UIColor+BookReader.m
//  BookReader
//
//  Created by ZoomBin on 13-5-9.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
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

+ (UIColor *)rankButtonTextColor
{
    return [UIColor colorWithRed:71.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0];
}

+ (UIColor *)bookStoreTxtColor
{
    return [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
}

+ (UIColor *)bookCellGrayTextColor
{
    return [UIColor colorWithRed:162.0/255.0 green:160.0/255.0 blue:147.0/255.0 alpha:1.0];
}

+ (UIColor *)semitransparentBackgroundColor
{
	return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
}

+ (UIColor *)brGreenColor
{
	return [UIColor colorWithRed:87/255.0f green:144/255.0f blue:65/255.0f alpha:1];
}
@end
