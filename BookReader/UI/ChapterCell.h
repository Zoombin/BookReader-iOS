//
//  ChapterCell.h
//  BookReader
//
//  Created by ZoomBin on 13-7-7.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setChapter:(Chapter *)chapter andCurrent:(BOOL)current;
- (CGFloat)height;
@end
