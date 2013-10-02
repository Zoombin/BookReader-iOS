//
//  Cell.h
//  BookReader
//
//  Created by ZoomBin on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BookCellStyleBig,
    BookCellStyleSmall,
    BookCellStyleCatagory,
    BookCellStyleEmpty,
} BookCellStyle;

@interface BookCell : UITableViewCell

- (id)initWithStyle:(BookCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setBook:(Book *)book;
- (void)setTextLableText:(NSString *)name;
- (CGFloat)height;
- (void)hidenDottedLine;

@end
