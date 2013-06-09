//
//  BRBookCell.h
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
@class Book;
@class BRBookCell;

@protocol BRBookCellDelegate <NSObject>
- (void)changedValueBookCell:(BRBookCell *)bookCell;
@end

@interface BRBookCell : PSUICollectionViewCell

@property (nonatomic, weak) id<BRBookCellDelegate> bookCellDelegate;
@property (nonatomic, strong) Book *book;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL cellSelected;
@property (nonatomic, assign) BOOL autoBuy;
@property (nonatomic, assign) NSInteger badge;

@end
