//
//  BookReadMenuView.h
//  BookReader
//
//  Created by 颜超 on 13-4-19.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReadMenuViewDelegate<NSObject>
@required

- (void)backButtonPressed;
- (void)addBookMarkButtonPressed;
- (void)chapterButtonClick;
@end

@interface BookReadMenuView : UIView {
    id<ReadMenuViewDelegate> delegate;
    UILabel *titleLabel;
}

@property (nonatomic, strong) id<ReadMenuViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@end
