//
//  BRChapterNameView.m
//  BookReader
//
//  Created by zhangbin on 8/17/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRChapterNameView.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat fontSize = 16;

@implementation BRChapterNameView
{
	UILabel *chapterNameLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		
		chapterNameLabel = [[UILabel alloc] initWithFrame:self.bounds];
		chapterNameLabel.layer.cornerRadius = 3;
		chapterNameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
		chapterNameLabel.font = [UIFont systemFontOfSize:fontSize];
		chapterNameLabel.textColor = [UIColor whiteColor];
		chapterNameLabel.adjustsFontSizeToFitWidth = YES;
		chapterNameLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:chapterNameLabel];
    }
    return self;
}

- (void)setChapter:(Chapter *)chapter
{
	if (_chapter == chapter) return;
	_chapter = chapter;
	CGSize size = [chapter.name sizeWithFont:[UIFont systemFontOfSize:fontSize + 3] constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
	chapterNameLabel.frame = CGRectMake(0, 0, size.width, size.height);
	chapterNameLabel.center = self.center;
	chapterNameLabel.text = chapter.name;
	[self performSelector:@selector(close) withObject:nil afterDelay:1.5f];
}

- (void)close
{
	[self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
