//
//  ReadHelpView.m
//  BookReader
//
//  Created by 颜超 on 13-5-7.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ReadHelpView.h"

@implementation ReadHelpView

- (id)initWithFrame:(CGRect)frame andMenuFrame:(CGRect)menuFrame
{
    self = [super initWithFrame:frame];
	_menuRect = menuFrame;
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        [self setAlpha:0.8];
        
		CGRect leftRect = CGRectMake(0, 0, (self.bounds.size.width - _menuRect.size.width) / 2, self.bounds.size.height);
		CGRect centerRect = CGRectMake((self.bounds.size.width - _menuRect.size.width) / 2, 0, _menuRect.size.width, self.bounds.size.height);
		CGRect rightRect = CGRectMake((self.bounds.size.width + _menuRect.size.width) / 2, 0, _menuRect.size.width, self.bounds.size.height);
        
		NSString *leftRectString = NSStringFromCGRect(leftRect);
		NSString *centerRectString = NSStringFromCGRect(centerRect);
		NSString *rightRectString = NSStringFromCGRect(rightRect);
        NSArray *noticesArray = @[@"点\n击\n左\n侧\n往\n前\n翻\n页",  @"中\n间\n显\n示\n菜\n单", @"点\n击\n右\n侧\n往\n后\n翻\n页"];
        NSArray *rectsArray = @[leftRectString, centerRectString,rightRectString];

        for (int i = 0; i < [noticesArray count]; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectFromString(rectsArray[i])];
            [label setFont:[UIFont systemFontOfSize:24]];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:UITextAlignmentCenter];
            [label setText:noticesArray[i]];
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.numberOfLines = 0;
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

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);

    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, CGRectGetMinX(_menuRect), CGRectGetMinY(_menuRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(_menuRect), CGRectGetMinY(_menuRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(_menuRect), CGRectGetMaxY(_menuRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_menuRect), CGRectGetMaxY(_menuRect));
    CGContextAddLineToPoint(context, CGRectGetMinX(_menuRect), CGRectGetMinY(_menuRect));
    
    CGContextMoveToPoint(context, self.bounds.size.width / 2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width / 2, (self.bounds.size.height - _menuRect.size.height) / 2);
    
    CGContextMoveToPoint(context, self.bounds.size.width / 2, ((self.bounds.size.height + _menuRect.size.height) / 2));
    CGContextAddLineToPoint(context, self.bounds.size.width / 2, CGRectGetMaxY(self.bounds));
    
    CGContextStrokePath(context);
}



@end
