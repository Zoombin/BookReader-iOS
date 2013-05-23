//
//  ReadMenuDirectoryViewController.m
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#define TOP_BAR_IMAGE [UIImage imageNamed:@"read_top_bar.png"]



#import "ReadMenuDirectoryViewController.h"
#import "UILabel+BookReader.h"

@implementation ReadMenuDirectoryViewController

- (id) init {
    self = [super init];
    if(self) {
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [super viewDidLoad];

    UIImageView *topBarImageView = [[UIImageView alloc] initWithImage:TOP_BAR_IMAGE];
    [self.view addSubview:topBarImageView];
    
    UILabel *titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, 320, 42)];
    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Catalogue", nil)]];
    [self.view addSubview:titleLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_menu_top_view_back_button.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"] forState:UIControlStateHighlighted];
//    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5, 5, 63, 29)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 320, 420)];
    [backgroundImage setImage:[UIImage imageNamed:@"bookstore_search_background"]];
    [self.view addSubview:backgroundImage];
    
}


- (void)backButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


@end
