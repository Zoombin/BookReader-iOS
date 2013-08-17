//
//  CoreTextViewController.h
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookReadMenuView.h"
#import <MessageUI/MessageUI.h>
#import "ChaptersViewController.h"
#import "PopLoginViewController.h"
#import "Book.h"
#import "Chapter.h"
#import "CommentView.h"

@interface CoreTextViewController : UIViewController<UIAlertViewDelegate,CommentDelegate>

@property (nonatomic, strong) Chapter *chapter;
@property (nonatomic, strong) UIViewController *previousViewController;

@end
