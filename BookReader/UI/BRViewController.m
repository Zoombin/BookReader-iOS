//
//  BRViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BRViewController.h"
#import "BRHeaderView.h"
#import "UIColor+BookReader.h"

@implementation BRViewController {
    BRHeaderView *headerView;
    UITapGestureRecognizer *gesturerecognier;
}
@synthesize hideBackBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setBackgroundColor:[UIColor mainBackgroundColor]];
     headerView = [[BRHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [headerView.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headerView];
    
     gesturerecognier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gesturerecognier];
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTitle:(NSString *)title
{
    [headerView.titleLabel setText:title];
}

- (void)setHideBackBtn:(BOOL)hiden
{
    headerView.backButton.hidden = hiden;
}

- (void)hideKeyboard
{
    for (UIView *user in _keyboardUsers) {
		[user resignFirstResponder];
	}
}

- (void)removeGestureRecognizer
{
    [self.view removeGestureRecognizer:gesturerecognier];
}


@end