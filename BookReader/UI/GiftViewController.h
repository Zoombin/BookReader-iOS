//
//  GiftViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "GiftCell.h"
#import "BRViewController.h"

@interface GiftViewController : BRViewController <UITableViewDataSource,UITableViewDelegate,GiftCellDelegate>
- (id)initWithIndex:(NSString *)index andBook:(Book *)book;
@end
