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

@implementation BRViewController {
    UITapGestureRecognizer *gesturerecognier;
    UIImageView *backgroundImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	CGSize fullSize = self.view.bounds.size;
	
	[self.view setBackgroundColor:[UIColor mainBackgroundColor]];
    UIView *bkgWhite = [[UIView alloc] initWithFrame:CGRectMake(5, 0, fullSize.width - 10, fullSize.height - BRHeaderView.height)];
    [bkgWhite.layer setCornerRadius:4];
    [bkgWhite.layer setMasksToBounds:YES];
    [bkgWhite setBackgroundColor:[UIColor whiteColor]];
    
	 backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, BRHeaderView.height, fullSize.width, fullSize.height - BRHeaderView.height)];
	[backgroundImage setImage:[UIImage imageNamed:@"main_view_bkg"]];
	[self.view addSubview:backgroundImage];
    [backgroundImage addSubview:bkgWhite];
    
	_headerView = [[BRHeaderView alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, BRHeaderView.height)];
    [_headerView.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_headerView];
    
     gesturerecognier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gesturerecognier];
}

- (UIImageView *)backgroundImage
{
    return backgroundImage;
}

- (void)backButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTitle:(NSString *)title
{
    [_headerView.titleLabel setText:title];
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
