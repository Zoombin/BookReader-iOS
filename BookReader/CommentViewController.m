//
//  CommentViewController.m
//  BookReader
//
//  Created by 颜超 on 13-8-29.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "CommentViewController.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.m"

@implementation CommentViewController {
    UITextView *textView;
    UIView *backgroundView;
}

- (id)init
{
    self = [super init];
    if (self) {
        _bookId = @"";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5]];
	// Do any additional setup after loading the view.
    [self showCommentView];
}

- (void)showCommentView
{
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 150, 300, 170)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:175.0/255.0 green:88.0/255.0 blue:42.0/255.0 alpha:1.0]];
    [self.view addSubview:backgroundView];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundView.frame.size.width, 40)];
    [headerView setImage:[UIImage imageNamed:@"comment_header"]];
    [backgroundView addSubview:headerView];
    
    UIView *middleBkg = [[UIView alloc] initWithFrame:CGRectMake(1, CGRectGetMaxY(headerView.frame), backgroundView.frame.size.width - 1 * 2, backgroundView.frame.size.height - 40 - 1)];
    [middleBkg setBackgroundColor:[UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1.0]];
    [backgroundView addSubview:middleBkg];
    
    UIImageView *textViewBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(headerView.bounds) + 5, backgroundView.bounds.size.width - 40, 80)];
    [textViewBackgroundView setImage:[UIImage imageNamed:@"dis_bg"]];
    [backgroundView addSubview:textViewBackgroundView];
    
     textView = [[UITextView alloc] initWithFrame:textViewBackgroundView.frame];
    [textView setBackgroundColor:[UIColor clearColor]];
    [backgroundView addSubview:textView];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(20, CGRectGetMaxY(textView.frame) + 7.5, 100, 30)];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"discuss_nor"] forState:UIControlStateNormal];
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"discuss_sel"] forState:UIControlStateHighlighted];
    [sendBtn addTarget:self action:@selector(sendCommentMessage) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:sendBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(CGRectGetMaxX(textView.frame) - 100, CGRectGetMinY(sendBtn.frame), 100, 30)];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_nor"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel_sel"] forState:UIControlStateHighlighted];
    [cancelBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:cancelBtn];
}

- (void)close
{
    [self.view removeFromSuperview];
}

- (void)sendCommentMessage
{
    [textView resignFirstResponder];
    if (textView.text.length <= 5) {
        [self displayHUDError:nil message:@"评论内容太短!"];
        return;
    }
    [ServiceManager disscussWithBookID:_bookId andContent:textView.text withBlock:^(BOOL success, NSError *error, NSString *message) {
            if (!success) {
                [self displayHUDError:nil message:message];
            } else {
                [self displayHUDError:nil message:message];
                [self performSelector:@selector(close) withObject:nil afterDelay:1.5];
            }
    }];
}

@end
