//
//  UIView+BookReader.h
//  BookReader
//
//  Created by 颜超 on 13-5-9.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BookReader)
+ (UIView *)tableViewFootView:(CGRect)frame andSel:(SEL)selector andTarget:(id)target;
@end
