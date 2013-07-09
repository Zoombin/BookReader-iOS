//
//  BookMarkCell.m
//  BookReader
//
//  Created by 颜超 on 13-7-9.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookMarkCell.h"

@implementation BookMarkCell
{
    UILabel *markNameLabel;
    UILabel *chapterNameLabel;
    UILabel *progressLabel;
    CGFloat height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        height = 50;
        markNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.contentView.frame.size.width-30, 20)];
        [markNameLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [markNameLabel setBackgroundColor:[UIColor clearColor]];
        [markNameLabel setTextColor:[UIColor blueColor]];
        [self.contentView addSubview:markNameLabel];
        
        chapterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(markNameLabel.frame), CGRectGetMaxY(markNameLabel.frame), 100, 20)];
        [chapterNameLabel setBackgroundColor:[UIColor clearColor]];
        [chapterNameLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:chapterNameLabel];
        
        progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(markNameLabel.frame) - 80, CGRectGetMaxY(markNameLabel.frame), 80, 20)];
        [progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.textAlignment = UITextAlignmentRight;
        [progressLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:progressLabel];

        UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(12,  height-1, self.contentView.bounds.size.width - 36, 1)];
        [separateLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [separateLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.contentView addSubview:separateLine];
    }
    return self;
}

- (CGFloat)height
{
    return height;
}

- (void)setMark:(Mark *)mark
{
    if (mark.reference) {
        [markNameLabel setText:mark.reference];
    }
    if (mark.chapterName) {
        [chapterNameLabel setText:mark.chapterName];
    }
    if (mark.progress) {
        [progressLabel setText:[NSString stringWithFormat:@"%.2f%%", mark.progress.floatValue]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
