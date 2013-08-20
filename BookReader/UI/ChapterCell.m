//
//  ChapterCell.m
//  BookReader
//
//  Created by ZoomBin on 13-7-7.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "ChapterCell.h"
#import "NSString+ZBUtilites.h"
#import "NSString+XXSY.h"

#define ChapterCellHeight 50.0f

@implementation ChapterCell
{
	UILabel *_chapterNameLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_chapterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.contentView.bounds.size.width - 30, ChapterCellHeight)];
        [_chapterNameLabel setFont:[UIFont systemFontOfSize:14]];
        [_chapterNameLabel setTextColor:[UIColor blueColor]];
        [_chapterNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_chapterNameLabel];
        
        UILabel *line = [UILabel dashLineWithFrame:CGRectMake(0, ChapterCellHeight - 2, self.contentView.frame.size.width + 20, 2)];
        [self.contentView addSubview:line];
    }
    return self;
}

- (void)setChapter:(Chapter *)chapter isCurrent:(BOOL)current andAllChapters:(NSArray *)allChapters
{
	_chapterNameLabel.text = [chapter displayName:allChapters];
    if (chapter.lastReadIndex == nil) {
        _chapterNameLabel.textColor = [UIColor blackColor];
    }else if (current) {
        _chapterNameLabel.textColor = [UIColor blueColor];
    }
}

- (CGFloat)height
{
    return ChapterCellHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
