//
//  ReadStatusView.m
//  iReader
//
//  Created by Archer on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReadStatusView.h"

@implementation ReadStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 60, frame.size.height)];
		_title.backgroundColor = [UIColor clearColor];
        _title.textAlignment = UITextAlignmentLeft;
		_title.font = [UIFont systemFontOfSize:12];
        [self addSubview:_title];
		
        _percentage = [[UILabel alloc] initWithFrame:self.bounds];
		_percentage.backgroundColor = [UIColor clearColor];
        _percentage.textAlignment = UITextAlignmentRight;
		_percentage.font = [UIFont systemFontOfSize:12];
		[self addSubview:_percentage];
		
		UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame) - 1, frame.size.width, 1)];
        [line setBackgroundColor:[UIColor blackColor]];
        [self addSubview:line];
    }
    return self;
}

@end
