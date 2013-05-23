//
//  ReadMenuView.h
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ReadMenuViewDelegate<NSObject>
@required

- (void)backButtonPressed;
- (void)addBookMarkButtonPressed;
- (void)brightnessChanging:(NSNumber *)value;
- (void)modeButtonPressed;
- (void)fontSizeChanged:(NSNumber *)value;
- (void)bookmarkButtonPressed;
- (void)moreButtonPressed;
@end

@interface ReadMenuView : UIView {
    UIView *brightnessView;
    UIView *fontView;
    UILabel *articleTitleLabel;
    UIScrollView *booknameScroll;
    UIButton *modeButton;
}

@property (nonatomic, weak) id<ReadMenuViewDelegate> delegate;
@property (nonatomic, strong) UILabel *articleTitleLabel;

@end