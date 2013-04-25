//
//  SubscribeViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NonManagedBook.h"

@interface SubscribeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
- (id)initWithBookId:(id<BookInterface>)book
           andOnline:(BOOL)online;
@end
