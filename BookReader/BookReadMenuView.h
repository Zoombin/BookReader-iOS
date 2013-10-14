//
//  BookReadMenuView.h
//  BookReader
//
//  Created by ZoomBin on 13-4-19.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookReadMenuViewDelegate<NSObject>
@required

- (void)backButtonPressed;
- (void)addBookMarkButtonPressed;

- (void)gotoNextChapter;
- (void)gotoPreviousChapter;

- (void)chaptersButtonClicked;
- (void)shareButtonClicked;
- (void)commitButtonClicked;
- (void)orientationButtonClicked;
- (void)resetButtonClicked;

- (void)fontChanged:(BOOL)reduce;
- (void)systemFont;
- (void)foundFont;
- (void)northFont;
- (void)brightChanged:(id)sender;
- (void)backgroundColorChanged:(NSInteger)index;
- (void)willAddFav;
- (void)bookDetailButtonClick;
- (void)realPaging;
- (void)simplePaging;

@end

@interface BookReadMenuView : UIView

@property (nonatomic, weak) id<BookReadMenuViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *fontButonMin;
@property (nonatomic, assign) BOOL favorited;
- (void)hidenAllMenu;

@end
