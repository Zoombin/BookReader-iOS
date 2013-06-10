//
//  SubscribeViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"

@class Mark;
@class Book;
@protocol SubscribeViewDelegate <NSObject>
- (void)didSelect:(id)selected;
@end

@interface SubscribeViewController : BRViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<SubscribeViewDelegate> delegate;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSString *currentChapterID;
@end
