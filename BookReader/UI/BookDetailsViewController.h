//
//  BookDetailViewController.h
//  BookReader
//
//  Created by 颜超 on 13-3-27.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BRViewController.h"

@interface BookDetailsViewController : BRViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate> {
}
- (id)initWithBook:(NSString *)uid;
@end
