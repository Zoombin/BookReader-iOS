//
//  BookRecommandViewController.h
//  BookReader
//
//  Created by 颜超 on 12-11-26.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDefines.h"

@interface HouseBookListViewController: UIViewController<UITableViewDataSource, UITableViewDelegate>
- (void)checkShouldLoadAgain;
@end
