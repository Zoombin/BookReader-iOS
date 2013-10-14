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
#import "UIDevice+ZBUtilites.h"

@implementation BRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
		self.hideKeyboardRecognzier.enabled = NO;
	}
	[self prefersStatusBarHidden];
	CGSize fullSize = self.view.bounds.size;
	
	[self.view setBackgroundColor:[UIColor mainBackgroundColor]];
	
	_headerView = [[BRHeaderView alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, [BRHeaderView height])];
    [_headerView.backButton addTarget:self action:@selector(backOrClose) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_headerView];
	
	_backgroundView = [[UIView alloc] initWithFrame:CGRectMake(5, [BRHeaderView height], fullSize.width - 5 - 5, fullSize.height - [BRHeaderView height])];
    [_backgroundView.layer setCornerRadius:4];
    [_backgroundView.layer setMasksToBounds:YES];
    [_backgroundView setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:_backgroundView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}


@end
