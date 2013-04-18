//
//  ReadMenuBookMarkViewController.h
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadViewController.h"
#import "UIDefines.h"

@interface ReadMenuBookMarkViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    UITableView *bookMarkTableView;
    UIViewController *readViewController;
    
    NSInteger currentRow;
    
    NSMutableArray *bookmarkArray;
    NSMutableArray *chaptersArray;
    
    NSString *bookid;
    BOOL isbookmark;
    
    NSString *text;
    NSMutableArray *pageArr;
    
}

@property (nonatomic, strong) UITableView *bookMarkTableView;
@property (nonatomic, strong) UIViewController *readViewController;
@property (nonatomic, strong) NSMutableArray *bookmarkArray;
@property (nonatomic, strong) NSMutableArray *chaptersArray;
@property (nonatomic, strong) NSString *cntid;

- (id)initBookWithUID:(NSString *)uid andPageArray:(NSMutableArray *)pageArray andText:(NSString *)booktext;
- (void)confirmDelete;

@end
