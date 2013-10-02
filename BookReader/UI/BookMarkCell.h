//
//  BookMarkCell.h
//  BookReader
//
//  Created by ZoomBin on 13-7-9.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mark.h"

@interface BookMarkCell : UITableViewCell

- (CGFloat)height;
- (void)setMark:(Mark *)mark;

@end
