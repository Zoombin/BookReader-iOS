//
//  ReadHelpView.m
//  BookReader
//
//  Created by 颜超 on 13-5-7.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ReadHelpView.h"

@implementation ReadHelpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blackColor]];
        [self setAlpha:0.8];
        
        #define LEFT_LABEL_FRAME CGRectMake((self.bounds.size.width/3-24)/2, 0, 24, 50)
        #define RIGHT_LABEL_FRAME CGRectMake((self.bounds.size.width/3*2)+(self.bounds.size.width/3-24)/2, 0, 24, 50)
        #define CENTER_LABEL_FRAME CGRectMake(self.bounds.size.width/3+(self.bounds.size.width/3-24)/2, 0, 24, 50)
        
        #define LEFT_LABEL_FRAME_STR NSStringFromCGRect(LEFT_LABEL_FRAME)
        #define RIGHT_LABEL_FRAME_STR NSStringFromCGRect(RIGHT_LABEL_FRAME)
        #define CENTER_LABEL_FRAME_STR NSStringFromCGRect(CENTER_LABEL_FRAME)
        NSArray *noticesArray = @[@"点击左侧往前翻页", @"点击右侧往后翻页", @"中间显示菜单"];
        NSArray *rectsArray = @[LEFT_LABEL_FRAME_STR,RIGHT_LABEL_FRAME_STR,CENTER_LABEL_FRAME_STR];
        
        for (int i =0; i<[noticesArray count]; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(rectsArray[i])];
            [label setFont:[UIFont systemFontOfSize:24]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setText:noticesArray[i]];
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.numberOfLines = 0;
            [label sizeToFit];
            [label setFrame:CGRectMake(label.frame.origin.x, (self.bounds.size.height - label.frame.size.height)/2, label.frame.size.width, label.frame.size.height)];
            [self addSubview:label];
        }
		
		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
		[self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)dismiss
{
	[self removeFromSuperview];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, self.bounds.size.width/3, self.bounds.size.height/4);
    CGContextAddLineToPoint(context, self.bounds.size.width/3*2, self.bounds.size.height/4);
    CGContextAddLineToPoint(context, self.bounds.size.width/3*2, self.bounds.size.height/4*3);
    CGContextAddLineToPoint(context, self.bounds.size.width/3, self.bounds.size.height/4*3);
    CGContextAddLineToPoint(context, self.bounds.size.width/3, self.bounds.size.height/4);
    
    CGContextMoveToPoint(context, self.bounds.size.width/2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, self.bounds.size.height/4);
    
    CGContextMoveToPoint(context, self.bounds.size.width/2, self.bounds.size.height/4*3);
    CGContextAddLineToPoint(context, self.bounds.size.width/2, self.bounds.size.height);
    
    CGContextStrokePath(context);
}



@end
