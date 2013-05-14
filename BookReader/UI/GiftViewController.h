//
//  GiftViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "GiftCell.h"

@interface GiftViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,GiftCellDelegate>
- (id)initWithIndex:(NSString *)index andBookObj:(Book *)bookObject;
@end
