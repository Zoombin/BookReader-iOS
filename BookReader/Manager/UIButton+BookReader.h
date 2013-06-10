//
//  UIButton+BookReader.h
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (BookReader)
+ (UIButton *)createButtonWithFrame:(CGRect)frame;
- (void)cooldownButtonFrame:(CGRect)frame andEnableCooldown:(BOOL)cooldown;
+ (UIButton *)fontButton:(CGRect)frame;

- (void)setDisabled:(BOOL)disabled;
- (void)startCoolDownDuration:(NSTimeInterval)delay;

+ (UIButton *)navigationBackButton;
+ (UIButton *)custumButtonWithFrame:(CGRect)frame;

@end
