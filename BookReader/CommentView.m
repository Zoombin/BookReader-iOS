//
//  CommentView.m
//  BookReader
//
//  Created by 颜超 on 13-8-7.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "CommentView.h"

@implementation CommentView {
    NSMutableArray *_buttonArrays;
    UIView *backgroundView;
}

- (id)init {
    if (self == [super init]) {
		_buttonArrays = [NSMutableArray arrayWithCapacity:4];
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 170)];
        [backgroundView setBackgroundColor:[UIColor colorWithRed:175.0/255.0 green:88.0/255.0 blue:42.0/255.0 alpha:1.0]];
        [self addSubview:backgroundView];
        
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundView.frame.size.width, 40)];
        [headerView setImage:[UIImage imageNamed:@"comment_header"]];
        [backgroundView addSubview:headerView];
        
        UIView *middleBkg = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(headerView.frame), backgroundView.frame.size.width - 1 * 2, backgroundView.frame.size.height - 40 - 1)];
        [middleBkg setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0]];
        [backgroundView addSubview:middleBkg];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(headerView.frame) + 5, backgroundView.frame.size.width - 40, 80)];
        [self.textField setBackground:[UIImage imageNamed:@"dis_bg"]];
        [self addSubview:self.textField];
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame) + 7.5, 100, 30)];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"discuss_nor"] forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[UIImage imageNamed:@"discuss_sel"] forState:UIControlStateHighlighted];
        [sendBtn addTarget:self action:@selector(sendCommentMessage) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:sendBtn];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setFrame:CGRectMake(CGRectGetMaxX(self.textField.frame) - 100, CGRectGetMinY(sendBtn.frame), 100, 30)];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_nor"] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_sel"] forState:UIControlStateHighlighted];
        [cancelBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:cancelBtn];
    }
    return self;
}

- (void)sendCommentMessage
{
    if ([self.delegate respondsToSelector:@selector(sendButtonClicked)]) {
        [self.delegate sendButtonClicked];
    }
}


- (void)close
{
  [self dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)addButtonWithUIButton:(UIButton *) btn
{
    [_buttonArrays addObject:btn];
}

- (void)layoutSubviews {
    //屏蔽系统的ImageView 和 UIButton
    for (UIView *v in [self subviews]) {
        if ([v class] == [UIImageView class]){
            [v setHidden:YES];
        }
        
        
        if ([v isKindOfClass:[UIButton class]] ||
            [v isKindOfClass:NSClassFromString(@"UIThreePartButton")]) {
            [v setHidden:YES];
        }
    }
}

- (void)buttonClicked:(id)sender
{
    UIButton *btn = (UIButton *) sender;
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
    {
        [self.delegate alertView:self clickedButtonAtIndex:btn.tag];
    }
    [self dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)show {
    [super show];
    self.bounds = CGRectMake(0, 0, 300, 170);
}



@end
