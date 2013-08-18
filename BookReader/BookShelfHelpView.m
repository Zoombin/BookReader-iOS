//
//  BookShelfHelpView.m
//  BookReader
//
//  Created by zhangbin on 8/18/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BookShelfHelpView.h"

@implementation BookShelfHelpView
{
	NSUInteger tapCount;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self helpFirst];
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
		[self addGestureRecognizer:tap];
    }
    return self;
}

- (void)helpFirst
{
	UIImage *image = [UIImage imageNamed:@"help1_2"];
	UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image];
	imageView1.frame = CGRectMake(30, -3, image.size.width, image.size.height);
	[self addSubview:imageView1];
	
	image = [UIImage imageNamed:@"help2_2"];
	UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image];
	imageView2.frame = CGRectMake(198, 4, image.size.width, image.size.height);
	[self addSubview:imageView2];
	
	image = [UIImage imageNamed:@"help3_2"];
	UIImageView *imageView3 = [[UIImageView alloc] initWithImage:image];
	imageView3.frame = CGRectMake(65, 175, image.size.width, image.size.height);
	[self addSubview:imageView3];
}

- (void)helpSecond
{	
	UIImage *image = [UIImage imageNamed:@"help4_2"];
	UIImageView *imageView1 = [[UIImageView alloc] initWithImage:image];
	imageView1.frame = CGRectMake(10, 0, image.size.width, image.size.height);
	[self addSubview:imageView1];
	
	image = [UIImage imageNamed:@"help5_2"];
	UIImageView *imageView2 = [[UIImageView alloc] initWithImage:image];
	imageView2.frame = CGRectMake(20, 113, image.size.width, image.size.height);
	[self addSubview:imageView2];
	
	image = [UIImage imageNamed:@"help6_2"];
	UIImageView *imageView3 = [[UIImageView alloc] initWithImage:image];
	imageView3.frame = CGRectMake(95, 185, image.size.width, image.size.height);
	[self addSubview:imageView3];
}

- (void)removeSubviews
{
	NSArray *subViews = [self subviews];
	for (UIView *sView in subViews) {
		[sView removeFromSuperview];
	}
}

- (void)tapped
{
	tapCount++;
	if (tapCount == 1) {
		[self removeSubviews];
		[_delegate willAppearSecondHelpView];
		[self helpSecond];
	} else {
		[_delegate willDismiss];
		[self removeFromSuperview];
	}
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
