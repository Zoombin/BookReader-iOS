//
//  BookDetailViewController.h
//  BookReader
//
//  Created by ZoomBin on 13-3-27.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BRViewController.h"
#import "PopLoginViewController.h"

@interface BookDetailsViewController : BRViewController

- (id)initWithBook:(NSString *)uid;

@end
