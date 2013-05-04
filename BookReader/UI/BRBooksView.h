//
//  BRBooksView.h
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 颜超. All rights reserved.
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


@interface BRBooksView : PSUICollectionView

@property (nonatomic, weak) id<BRBooksViewDelegate> booksViewDelegate;
@property (nonatomic) BOOL gridStyle;

- (BRBookCell *)cellForBook:(Book *)book atIndexPath:(NSIndexPath *)indexPath;

@end
