//
//  ChapterViewController.h
//  BookReader
//
//  Created by 颜超 on 12-12-24.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadViewController.h"
#import "BookReader.h"

@interface ChapterViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate> {
    NSString        *bookid;
    UITableView     *bookMarkTableView;
   
    NSMutableArray *pageArr;
    NSMutableArray *chaptersArray;
    NSMutableArray *chaptersRealName;
    
    NSString     *text;
    
    NSInteger currentIndex;
    
    NSArray *products_;
    NSString *bought;
    
    BOOL bFirstAppeared;
}
@property (nonatomic, strong) NSMutableArray *chaptersArray;
@property (nonatomic, strong) NSMutableArray *chaptersRealName;
//初始化
- (id)initBookWithUID:(NSString *)uid;
@end
