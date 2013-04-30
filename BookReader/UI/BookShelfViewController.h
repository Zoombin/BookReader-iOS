//
//  BookShelfViewController.h
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIDefines.h"
#import "BookView.h"
#import "BookShelfHeaderView.h"
#import "BookShelfBottomView.h"
//Local
#import "UIDefines.h"
#import <StoreKit/StoreKit.h>
#import "IAPHandler.h"


typedef enum {
    kBookShelfLayoutStyleShelfLike,
    kBookShelfLayoutStyleTableList
}BookShelfLayoutStyle;


@interface BookShelfViewController : UIViewController<BookViewDelegate,BookShelfHeaderViewDelegate,BookShelfBottomViewDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, assign) BookShelfLayoutStyle layoutStyle;
@end
