//
//  ChapterCell.h
//  BookReader
//
//  Created by ZoomBin on 13-7-7.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChapterCell : UITableViewCell

- (CGFloat)height;
- (void)setChapter:(Chapter *)chapter isCurrent:(BOOL)current andAllChapters:(NSArray *)allChapters;

@end
