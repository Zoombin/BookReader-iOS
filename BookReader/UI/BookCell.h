//
//  Cell.h
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

typedef enum {
    BookCellStyleBig,
    BookCellStyleSmall,
    BookCellStyleCatagory,
} BookCellStyle;

@interface BookCell : UITableViewCell
- (id)initWithStyle:(BookCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setBook:(Book *)book;
- (void)setTextLableText:(NSString *)name;
- (CGFloat)height;
- (void)hidenArrow:(BOOL)hiden;
- (void)separateLineColor:(UIColor *)color;
@end
