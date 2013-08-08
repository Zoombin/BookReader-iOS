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

@interface CoreTextViewController : UIViewController

@property (nonatomic, strong) Chapter *chapter;

@end
