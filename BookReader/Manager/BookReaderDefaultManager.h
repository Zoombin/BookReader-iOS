//
//  BookReaderDefaultManager.h
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultUserid   @"userid"

#define UserDefaultKeyFontSize     @"fontsize"
#define UserDefaultKeyFontName     @"fontname"
#define UserDefaultKeyTextColor    @"textcolor"

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


@interface BookReaderDefaultManager : NSObject
+ (void)saveUserid:(id)object;
+ (id)userid;
+ (void)deleteUserid;

+ (void)setObject:(id)object ForKey:(id)key;
+ (id)objectForKey:(id)key;

+ (void)reset;
@end
