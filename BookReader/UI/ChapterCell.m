//
//  ChapterCell.m
//  BookReader
//
//  Created by 颜超 on 13-7-7.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ChapterCell.h"

#define ChapterCellHeight 50.0f

@implementation ChapterCell {
    UILabel *chapterNameLabel;
    CGFloat height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        height = ChapterCellHeight;
        
         chapterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.contentView.bounds.size.width - 30, ChapterCellHeight)];
        [chapterNameLabel setTextColor:[UIColor blueColor]];
        [chapterNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:chapterNameLabel];
        
        UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(12,  height-1, self.contentView.bounds.size.width - 36, 1)];
        [separateLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [separateLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:separateLine];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setChapter:(Chapter *)chapter andCurrent:(BOOL)current
{
    if (chapter.name) {
        [chapterNameLabel setText:chapter.name];
    }
    if (chapter.lastReadIndex == nil) {
        chapterNameLabel.textColor = [UIColor blackColor];
    }else if (current) {
        chapterNameLabel.textColor = [UIColor blueColor];
    }
}

- (CGFloat)height
{
    return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
