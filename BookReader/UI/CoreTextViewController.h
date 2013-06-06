//
//  CoreTextViewController.h
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookReadMenuView.h"
#import "SubscribeViewController.h"
#import <MessageUI/MessageUI.h>

@class Book;
@class Chapter;
@interface CoreTextViewController : UIViewController<BookReadMenuViewDelegate,SubscribeViewDelegate,MFMessageComposeViewControllerDelegate> {
    MFMessageComposeViewController *messageComposeViewController; 
}
@property (nonatomic, strong) Book *book;
@end
