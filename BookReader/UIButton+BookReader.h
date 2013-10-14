//
//  UIButton+BookReader.h
//  BookReader
//
//  Created by ZoomBin on 13-5-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BookReaderButtonStyleLeft,
    BookReaderButtonStyleRight,
    BookReaderButtonStyleNormal,
    BookReaderButtonStyleBack
}BookReaderButtonStyle;

typedef enum {
    BRBookStoreTabBarButtonStyleRecomend,
    BRBookStoreTabBarButtonStyleCatagory,
    BRBookStoreTabBarButtonStyleRank,
    BRBookStoreTabBarButtonStyleSearch
}BRBookStoreTabBarButtonStyle;

@interface UIButton (BookReader)
+ (UIButton *)addButtonWithFrame:(CGRect)frame andStyle:(BookReaderButtonStyle)style;

+ (UIButton *)createButtonWithFrame:(CGRect)frame;
- (void)memberButton:(CGRect)frame;
+ (UIButton *)fontButton:(CGRect)frame;

- (void)setDisabled:(BOOL)disabled;

+ (UIButton *)bookStoreTabBarButtonWithFrame:(CGRect)frame andStyle:(BRBookStoreTabBarButtonStyle)style;
+ (UIButton *)navigationBackButton;

+ (UIButton *)bookShelfButtonWithStartPosition:(CGPoint)position;

+ (UIButton *)bookMenuButtonWithFrame:(CGRect)frame andTitle:(NSString *)title;

- (void)shelfCategoryButtonStyle;

@end
