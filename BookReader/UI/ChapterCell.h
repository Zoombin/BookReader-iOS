//
//  ChapterCell.h
//  BookReader
//
//  Created by 颜超 on 13-7-7.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chapter.h"

@interface ChapterCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setChapter:(Chapter *)obj andCurrent:(BOOL)current;
- (CGFloat)height;
@end
