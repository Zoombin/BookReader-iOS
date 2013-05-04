//
//  BookReaderDefaultManager.h
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultUserID   @"userid"

#define UserDefaultKeyFontSize     @"fontsize"
#define UserDefaultKeyFontName     @"fontname"
#define UserDefaultKeyTextColor    @"textcolor"
#define UserDefaultKeyBright       @"bright"
#define UserDefaultKeyBackground   @"background"

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

//5种背景图
#define ReadBackgroundImageGreen [UIImage imageNamed:@"read_menu_view_background_safe.png"]
#define ReadBackgroundImageBlue [UIImage imageNamed:@"read_menu_view_background_dream.png"]
#define ReadBackgroundImageSheep [UIImage imageNamed:@"Read_SheepPager"]

//5种背景颜色
#define ReadBackgroundColorGreen [UIColor colorWithPatternImage:ReadBackgroundImageGreen]
#define ReadBackgroundColorBlue [UIColor colorWithPatternImage:ReadBackgroundImageBlue]
#define ReadBackgroundColorSheep [UIColor colorWithPatternImage:ReadBackgroundImageSheep]

@interface BookReaderDefaultManager : NSObject
+ (void)saveUserID:(id)object;
+ (id)userID;
+ (void)deleteUserID;

+ (void)setObject:(id)object ForKey:(id)key;
+ (id)objectForKey:(id)key;

+ (void)reset;
@end
