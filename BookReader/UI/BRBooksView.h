//
//  BRBooksView.h
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

@class BRBooksView;
@class BRBookCell;
@class Book;

@protocol BRBooksViewDelegate <NSObject>
- (void)booksView:(BRBooksView *)booksView tappedBookCell:(BRBookCell *)bookCell;
- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell;
@end


@interface BRBooksView : PSTCollectionView

@property (nonatomic, weak) id<BRBooksViewDelegate> booksViewDelegate;

+ (PSTCollectionViewFlowLayout *)defaultLayout;
- (BRBookCell *)bookCell:(Book *)book atIndexPath:(NSIndexPath *)indexPath;

+ (CGFloat)headerHeight;

@end
