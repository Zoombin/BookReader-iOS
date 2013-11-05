//
//  WebViewController.m
//  BookReader
//
//  Created by 颜超 on 13-8-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "WebViewController.h"
#import "BRHeaderView.h"

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.backgroundView removeFromSuperview];
	
    self.headerView.titleLabel.text = @"帮助";
    CGSize fullSize = self.view.bounds.size;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, [BRHeaderView height], fullSize.width, fullSize.height - [BRHeaderView height])];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
	webView.backgroundColor = [UIColor clearColor];
	webView.scrollView.showsHorizontalScrollIndicator = NO;
	webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:webView];
}

- (void)setUrlString:(NSString *)urlString
{
	_urlString = urlString;
	NSLog(@"webView urlString: %@", urlString);
}

- (void)backOrClose
{
	if (_popTarget) {
		[self.navigationController popToViewController:_popTarget animated:YES];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
