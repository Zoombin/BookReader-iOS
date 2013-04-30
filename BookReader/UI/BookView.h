//
//  BookView.h
//  BookReader
//
//  Created by 颜超 on 13-4-14.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@class BookView;
@protocol BookViewDelegate <NSObject>
- (void)bookViewClicked:(BookView *)bookView;
- (void)switchOnOrOff:(id)sender andBookName:(NSString *)name;
@end

@interface BookView : UIView
@property (nonatomic, weak) id<BookViewDelegate> delegate;
@property (nonatomic, strong) Book *book;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL selected;

- (void)setBook:(Book *)book;
- (void)setBadgeValue:(NSInteger)badgeValue;
@end
