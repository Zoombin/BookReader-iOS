//
//  SubscribeViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "BRViewController.h"

@protocol SubscribeViewDelegate <NSObject>
- (void)chapterDidSelectAtIndex:(NSInteger)index;
@end

@interface SubscribeViewController : BRViewController<UITableViewDataSource,UITableViewDelegate> {
    
}
@property (nonatomic, weak) id<SubscribeViewDelegate> delegate;
- (id)initWithBookId:(Book *)book
           andOnline:(BOOL)online;
@end
