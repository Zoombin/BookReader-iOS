//
//  Cell.h
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookCell : UITableViewCell
+ (CGFloat)height;
- (void)setBook:(Book *)book;
@end
