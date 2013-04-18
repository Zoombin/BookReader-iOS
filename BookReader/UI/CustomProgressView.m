//
//  CustomProgressView.m
//  BookReader
//
//  Created by 颜超 on 13-3-20.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "CustomProgressView.h"

#define CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_X 1
#define CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_TOP_Y 1
#define CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_BOTTOM_Y 3

@implementation CustomProgressView
- (void)drawRect:(CGRect)rect {
    //CGSize backgroundStretchPoints = {4, 9};
    CGSize fillStretchPoints = {3, 8};
    UIImage *background = [UIImage imageNamed:@"localbook_progress_background"];
    UIImage *fill = [[UIImage imageNamed:@"localbook_progress_front"] stretchableImageWithLeftCapWidth:fillStretchPoints.width topCapHeight:fillStretchPoints.height];
    [background drawInRect:rect];
    NSInteger maxWidth = rect.size.width - (2 * CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_X);
    NSInteger curWidth = floor([self progress] * maxWidth);
    CGRect fillRect = CGRectMake(rect.origin.x + CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_X,
                                 rect.origin.y + CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_TOP_Y,
                                 curWidth,
                                 rect.size.height - CUSTOM_PROGRESS_VIEW_FILL_OFF_SET_BOTTOM_Y);
    [fill drawInRect:fillRect];
}
@end
