//
//  BookDetailViewController.h
//  BookReader
//
//  Created by 颜超 on 13-3-27.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate> 
- (id)initWithBook:(NSString *)uid;
@end
