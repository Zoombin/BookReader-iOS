//
//  BookReaderDefaultManager.h
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultKeyFontSize @"font_size"
#define UserDefaultKeyFontName @"font_name"
#define UserDefaultKeyFont @"font"
#define UserDefaultKeyTextColor @"text_color"
#define UserDefaultKeyBright @"bright"
#define UserDefaultKeyBackground @"background"
#define UserDefaultKeyNotFirstRead @"not_first_read"

//字体大小
#define UserDefaultFontSizeMax @23
#define UserDefaultFontSizeMin @19

//字体名
#define UserDefaultSystemFont @"Arial"
#define UserDefaultFoundFont @"FZLTHJW--GB1-0"

//字体颜色
#define UserDefaultTextColorBlack @"blackColor"
#define UserDefaultTextColorWhite @"whiteColor"
#define UserDefaultTextColorGreen @"greenColor"
#define UserDefaultTextColorBlue @"blueColor"
#define UserDefaultTextColorBrown @"brownColor"


@interface BookReaderDefaultsManager : NSObject
+ (void)setObject:(id)object ForKey:(id)key;
+ (id)objectForKey:(id)key;
+ (UIColor *)backgroundColorWithIndex:(NSInteger)index;
+ (void)restoreOriginBright;
+ (void)saveOriginBright;
+ (void)reset;
@end
