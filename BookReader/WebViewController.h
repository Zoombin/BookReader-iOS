//
//  WebViewController.h
//  BookReader
//
//  Created by 颜超 on 13-8-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"
#import "Chapter.h"

@protocol WebViewControllerDelegate <NSObject>

- (void)didSubscribe:(Chapter *)chapter;

@end

@interface WebViewController : BRViewController

@property (nonatomic, weak) id<WebViewControllerDelegate> delegate;
@property (nonatomic, strong) UIViewController *popTarget;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) Chapter *chapter;

@end
