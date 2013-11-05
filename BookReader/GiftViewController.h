//
//  GiftViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GiftCell.h"
#import "BRViewController.h"

@interface GiftViewController : BRViewController <UITableViewDataSource,UITableViewDelegate,GiftCellDelegate>
- (id)initWithBook:(Book *)book;
@end
