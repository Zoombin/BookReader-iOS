//
//  BookReadMenuView.h
//  BookReader
//
//  Created by 颜超 on 13-4-19.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookReadMenuViewDelegate<NSObject>
@required

- (void)backButtonPressed;
- (void)addBookMarkButtonPressed;
- (void)chapterButtonClick;
- (void)nextChapterButtonClick;
- (void)previousChapterButtonClick;

- (void)fontAdd;
- (void)fontReduce;

@end

@interface BookReadMenuView : UIView {
    id<BookReadMenuViewDelegate> delegate;
    UILabel *titleLabel;
}

@property (nonatomic, strong) id<BookReadMenuViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@end
