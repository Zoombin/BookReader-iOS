//
//  BookReaderDefaultManager.h
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultKeyFontSize     @"fontsize"
#define UserDefaultKeyFontName     @"fontname"
#define UserDefaultKeyTextColor    @"textcolor"
#define UserDefaultKeyBright       @"bright"
#define UserDefaultKeyBackground   @"background"
#define UserDefaultFirstRead  @"first_read"

//字体大小
#define UserDefaultFontSizeMax [NSNumber numberWithFloat:23]
#define UserDefaultFontSizeMin [NSNumber numberWithFloat:19]

//字体名
#define UserDefaultSystemFont  @"Arial"
#define UserDefaultFoundFont   @"FZLTHJW--GB1-0"

//字体颜色
#define UserDefaultTextColorBlack  @"blackColor"
#define UserDefaultTextColorRed    @"redColor"
#define UserDefaultTextColorGreen  @"greenColor"
#define UserDefaultTextColorBlue   @"blueColor"
#define UserDefaultTextColorBrown  @"brownColor"

//亮度
#define UserDefaultBrightDefault   [NSNumber numberWithFloat:1]

@interface BookReaderDefaultsManager : NSObject


+ (void)setObject:(id)object ForKey:(id)key;
+ (id)objectForKey:(id)key;
+ (UIColor *)backgroundColorWithIndex:(NSInteger)index;

+ (void)reset;
@end
