//
//  ReadStatusView.m
//  iReader
//
//  Created by Archer on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReadStatusView.h"





@implementation ReadStatusView

@synthesize title;
@synthesize percentage;
@synthesize booknameScroll;



#define TIME_UPDATE_FREQUENCY 5

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect rect = [self bounds];
        float delta = 20.0;
        CGRect newRect = CGRectMake(0, 0, rect.size.width - delta*2, rect.size.height);
        
        NSMutableArray *labelsMutableArray = [NSMutableArray array];
        
        booknameScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-85, rect.size.height)];
        [booknameScroll setShowsHorizontalScrollIndicator:NO];
        [booknameScroll setBackgroundColor:[UIColor clearColor]];
        [self addSubview:booknameScroll];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-85, rect.size.height)];
        [title setBackgroundColor:[UIColor blueColor]];
        [title setTextAlignment:UITextAlignmentCenter];
        [labelsMutableArray addObject:title];
        
        percentage = [[UILabel alloc] initWithFrame:newRect];
        [percentage setTextAlignment:UITextAlignmentRight];
        [labelsMutableArray addObject:percentage];
        
        for(int i = 0; i < [labelsMutableArray count]; ++i) {
            UILabel *label = [labelsMutableArray objectAtIndex:i];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:12.0]];
            if (i==0) {
                [booknameScroll addSubview:label];
            }else {
                [self addSubview:label];
            }
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+frame.size.height-1, frame.size.width, 1)];
        [line setBackgroundColor:[UIColor blackColor]];
        [self addSubview:line];
    }
    return self;
}

@end
