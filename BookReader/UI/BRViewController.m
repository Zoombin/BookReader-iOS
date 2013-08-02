//
//  BRViewController.m
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BRViewController.h"
#import "UIColor+BookReader.h"
#import <QuartzCore/QuartzCore.h>

@implementation BRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	CGSize fullSize = self.view.bounds.size;
	
	[self.view setBackgroundColor:[UIColor mainBackgroundColor]];
    UIView *bkgWhite = [[UIView alloc] initWithFrame:CGRectMake(5, 0, fullSize.width - 10, fullSize.height - BRHeaderView.height)];
    [bkgWhite.layer setCornerRadius:4];
    [bkgWhite.layer setMasksToBounds:YES];
    [bkgWhite setBackgroundColor:[UIColor whiteColor]];
    
	_backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, BRHeaderView.height, fullSize.width, fullSize.height - BRHeaderView.height)];
	[_backgroundView setImage:[UIImage imageNamed:@"main_view_bkg"]];
	[self.view addSubview:_backgroundView];
    [_backgroundView addSubview:bkgWhite];
    
	_headerView = [[BRHeaderView alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, BRHeaderView.height)];
    [_headerView.backButton addTarget:self action:@selector(backOrClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_headerView];
    
	_hideKeyboardRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:_hideKeyboardRecognzier];
}

- (void)backOrClose
{
	if (self.navigationController.viewControllers[0] != self) {
		[self.navigationController popViewControllerAnimated:YES];
	} else if (self.navigationController.presentingViewController) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)setTitle:(NSString *)title
{
    [_headerView.titleLabel setText:title];
}

- (void)hideKeyboard
{
	[self.view endEditing:YES];
}

@end
