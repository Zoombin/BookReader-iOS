//
//  ReadColorViewController.h
//  iReader
//
//  Created by Archer on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookReader.h"

@interface ReadColorViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    BOOL bFontColor;
    NSMutableArray *marksMutableArray;
    NSArray *colorSelectorStrArray;
    NSArray *cellsTitleArray;
    UITableView *colorSelectTableView;
    UITextView *textView;
}

@property (nonatomic, assign) BOOL bFontColor;
@property (nonatomic, strong) NSMutableArray *marksMutableArray;
@property (nonatomic, strong) NSArray *colorSelectorStrArray;
@end
