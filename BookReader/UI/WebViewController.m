//
//  WebViewController.m
//  BookReader
//
//  Created by 颜超 on 13-8-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.headerView.titleLabel.text = @"帮助";
    CGSize fullSize = self.view.bounds.size;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(5, 44, fullSize.width - 5 - 5, fullSize.height - 44)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.xxsy.net/help.html"]]];
	webView.backgroundColor = [UIColor clearColor];
	webView.scrollView.showsHorizontalScrollIndicator = NO;
	webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:webView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
