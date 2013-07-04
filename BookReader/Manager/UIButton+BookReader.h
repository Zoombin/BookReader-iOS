//
//  UIButton+BookReader.h
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BookReaderButtonStyleLeft = 0,
    BookReaderButtonStyleRight = 1,
    BookReaderButtonStyleNormal = 2,
    BookReaderButtonStyleBack = 3,
}BookReaderButtonStyle;

@interface UIButton (BookReader)
+ (UIButton *)addButtonWithFrame:(CGRect)frame andStyle:(BookReaderButtonStyle)style;

+ (UIButton *)createButtonWithFrame:(CGRect)frame;
- (void)cooldownButtonFrame:(CGRect)frame andEnableCooldown:(BOOL)cooldown;
+ (UIButton *)fontButton:(CGRect)frame;

- (void)setDisabled:(BOOL)disabled;
- (void)startCoolDownDuration:(NSTimeInterval)delay;

+ (UIButton *)navigationBackButton;

@end
