//
//  CategoryDetailView.h
//  BookReader
//
//  Created by 颜超 on 13-3-26.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"

@interface CategoryDetailsViewController : BRViewController<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
- (void)reloadDataWithArray:(NSArray *)array andCatagoryId:(int)cataId;
@end
