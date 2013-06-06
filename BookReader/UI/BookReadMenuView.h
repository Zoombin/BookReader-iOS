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
- (void)chaptersButtonClicked;
- (void)nextChapterButtonClick;
- (void)previousChapterButtonClick;
- (void)shareButtonClicked;

- (void)fontChanged:(BOOL)reduce;
- (void)systemFont;
- (void)foundFont;
- (void)changeTextColor:(NSString *)textColor;
- (void)brightChanged:(id)sender;
- (void)backgroundColorChanged:(NSInteger)index;

@end

@interface BookReadMenuView : UIView<UIScrollViewDelegate> {
    id<BookReadMenuViewDelegate> delegate;
    UILabel *titleLabel;
}

@property (nonatomic, strong) id<BookReadMenuViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *fontButonMin;
@end
