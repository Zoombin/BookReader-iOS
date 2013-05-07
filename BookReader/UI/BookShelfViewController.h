//
//  BookShelfViewController.h
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BookReader.h"
#import "BookShelfHeaderView.h"
#import "BookShelfBottomView.h"
//Local
#import "BookReader.h"
#import <StoreKit/StoreKit.h>


typedef enum {
    kBookShelfLayoutStyleShelfLike,
    kBookShelfLayoutStyleTableList
}BookShelfLayoutStyle;


@interface BookShelfViewController : UIViewController

@property (nonatomic, assign) BookShelfLayoutStyle layoutStyle;
@end
