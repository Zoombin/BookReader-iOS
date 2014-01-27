//
//  CommentViewController.m
//  BookReader
//
//  Created by 颜超 on 13-8-29.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "CommentViewController.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import <QuartzCore/QuartzCore.h>

@interface CommentViewController ()

@property (readwrite) UITextView *textView;
@property (readwrite) UIView *backgroundView;
@property (readwrite) CGRect frame;

@end

@implementation CommentViewController

- (id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if (self) {
		_frame = frame;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.frame = _frame;
	
    [self.view setBackgroundColor:[UIColor semitransparentBackgroundColor]];
	
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 20, _frame.size.width - 2 * 10, 170)];
    [_backgroundView setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0]];
	_backgroundView.layer.cornerRadius = 10;
    [self.view addSubview:_backgroundView];
    
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_backgroundView.frame), 40)];
	titleLabel.font = [UIFont systemFontOfSize:22];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.text = @"我要评论";
	[_backgroundView addSubview:titleLabel];
	
    UIImageView *textViewBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40, _backgroundView.bounds.size.width - 40, 80)];
    [textViewBackgroundView setImage:[UIImage imageNamed:@"dis_bg"]];
    [_backgroundView addSubview:textViewBackgroundView];
    
	_textView = [[UITextView alloc] initWithFrame:textViewBackgroundView.frame];
    [_textView setBackgroundColor:[UIColor clearColor]];
	_textView.font = [UIFont systemFontOfSize:18];
    [_backgroundView addSubview:_textView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(20, CGRectGetMaxY(_textView.frame) + 7.5, 100, 30)];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_click"] forState:UIControlStateHighlighted];
	[sendBtn setTitle:@"评论" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendCommentMessage) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:sendBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(CGRectGetMaxX(_textView.frame) - 100, CGRectGetMinY(sendBtn.frame), 100, 30)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_normal"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_click"] forState:UIControlStateHighlighted];
	[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:cancelBtn];
}

- (void)close
{
    [self.view removeFromSuperview];
}

- (void)sendCommentMessage
{
    [_textView resignFirstResponder];
    if (_textView.text.length <= 5) {
        [self displayHUDTitle:nil message:@"评论内容太短!"];
        return;
    }
    [ServiceManager disscussWithBookID:_bookId andContent:_textView.text withBlock:^(BOOL success, NSError *error, NSString *message) {
            if (!success) {
                [self displayHUDTitle:nil message:message];
            } else {
                [self displayHUDTitle:nil message:message];
                [self performSelector:@selector(close) withObject:nil afterDelay:1.5];
            }
    }];
}

@end
