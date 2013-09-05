//
//  BRBookCell.h
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

#define collectionCellIdentifier @"collection_cell_identifier"

@class Book;
@class BRBookCell;

@protocol BRBookCellDelegate <NSObject>
- (void)changedValueBookCell:(BRBookCell *)bookCell;
@end

@interface BRBookCell : PSTCollectionViewCell

@property (nonatomic, weak) id<BRBookCellDelegate> bookCellDelegate;
@property (nonatomic, strong) Book *book;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL cellSelected;
@property (nonatomic, assign) BOOL bUpdate;
//@property (nonatomic, assign) BOOL autoBuy;
//@property (nonatomic, assign) NSInteger badge;

@end
