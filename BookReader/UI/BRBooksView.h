//
//  BRBooksView.h
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

#define kLessBookEdgeInsets UIEdgeInsetsMake(30, 25, 200, 25)
#define kMoreBookEdgeInsets UIEdgeInsetsMake(30, 25, 200, 25)

@class BRBooksView;
@class BRBookCell;
@class Book;

@protocol BRBooksViewDelegate <NSObject>
- (void)booksView:(BRBooksView *)booksView tappedBookCell:(BRBookCell *)bookCell;
- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell;
@end


@interface BRBooksView : PSUICollectionView

@property (nonatomic, weak) id<BRBooksViewDelegate> booksViewDelegate;
@property (nonatomic, strong) PSUICollectionViewFlowLayout *layout;

- (BRBookCell *)bookCell:(Book *)book atIndexPath:(NSIndexPath *)indexPath;

+ (CGFloat)headerHeight;

@end
