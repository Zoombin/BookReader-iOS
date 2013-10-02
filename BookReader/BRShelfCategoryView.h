//
//  ShelfCategoryView.h
//  BookReader
//
//  Created by zhangbin on 9/28/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRShelfCategoryViewDelegate <NSObject>

- (void)shelfCategoryTapped:(ShelfCategory *)shelfCategory;
- (void)editShelfCategories;
- (void)shelfCategoryViewResize:(CGSize)newSize;

@end

@interface BRShelfCategoryView : UIView

@property (nonatomic, weak) id<BRShelfCategoryViewDelegate> delegate;
@property (nonatomic, strong) NSArray *shelfCategories;

@end
