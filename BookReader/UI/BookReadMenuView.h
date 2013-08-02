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
- (void)nextChapterButtonClick;
- (void)previousChapterButtonClick;


- (void)chaptersButtonClicked;
- (void)shareButtonClicked;
- (void)commitButtonClicked;
- (void)orientationButtonClicked;
- (void)resetButtonClicked;

- (void)fontChanged:(BOOL)reduce;
- (void)systemFont;
- (void)foundFont;
- (void)northFont;
- (void)changeTextColor:(NSString *)textColor;
- (void)brightChanged:(id)sender;
- (void)backgroundColorChanged:(NSInteger)index;
- (void)bookDetailButtonClick;

@end

@interface BookReadMenuView : UIView<UIScrollViewDelegate> {
    id<BookReadMenuViewDelegate> delegate;
    UILabel *titleLabel;
}

@property (nonatomic, strong) id<BookReadMenuViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *fontButonMin;
- (void)hidenAllMenu;

@end
