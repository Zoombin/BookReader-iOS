//
//  BookView.h
//  BookReader
//
//  Created by 颜超 on 13-4-14.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Book;

@protocol BookViewDelegate <NSObject>
- (void)bookViewButtonClick:(id)sender;
@end

@interface BookView : UIView
@property (nonatomic, weak) id<BookViewDelegate> delegate;
@property (nonatomic, assign) BOOL isInEditing;
@property (nonatomic, assign) BOOL isSelected;
- (void)setBook:(Book *)book;
@end
