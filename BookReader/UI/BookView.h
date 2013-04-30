//
//  BookView.h
//  BookReader
//
//  Created by 颜超 on 13-4-14.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@protocol BookViewDelegate <NSObject>
- (void)bookViewButtonClick:(id)sender;
- (void)switchOnOrOff:(id)sender andBookName:(NSString *)name;
@end

@interface BookView : UIView
@property (nonatomic, weak) id<BookViewDelegate> delegate;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL selected;
- (void)setBook:(Book *)book;
- (void)setBadgeValue:(NSInteger)badgeValue;
@end
