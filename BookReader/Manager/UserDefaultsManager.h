//
//  NSUserDefaultsManager.h
//  iReader
//
//  Created by Archer on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//brightness 阅读界面的亮度
#define UserDefaultsValueBrightnessInvalid [NSNumber numberWithFloat:0.0]
#define UserDefaultsValueBrightnessDefault [NSNumber numberWithFloat:1.0]
#define UserDefaultsValueBrightnessMin [NSNumber numberWithFloat:0.6]
#define UserDefaultsValueBrightnessMax [NSNumber numberWithFloat:1.0]

//background 阅读界面的背景设定:"白天","黑夜","怀旧",“护眼”,“梦幻”
#define UserDefaultsValueBackgroundDay @"白天"
#define UserDefaultsValueBackgroundNight @"黑夜"
#define UserDefaultsValueBackgroundOld @"怀旧"
#define UserDefaultsValueBackgroundSafe @"护眼"
#define UserDefaultsValueBackgroundDream @"梦幻"
#define UserDefaultsValueBackgroundNone  @"无主题"

//5种背景图
#define ReadBackgroundImageDay [UIImage imageNamed:@"read_menu_view_background.png"]
#define ReadBackgroundImageNight [UIImage imageNamed:@"read_menu_view_background_night.png"]
#define ReadBackgroundImageOld [UIImage imageNamed:@"read_menu_view_background_old.png"]
#define ReadBackgroundImageSafe [UIImage imageNamed:@"read_menu_view_background_safe.png"]
#define ReadBackgroundImageDream [UIImage imageNamed:@"read_menu_view_background_dream.png"]

//5种背景颜色

#define ReadBackgroundColorDay [UIColor colorWithPatternImage:ReadBackgroundImageDay]
#define ReadBackgroundColorNight [UIColor colorWithPatternImage:ReadBackgroundImageNight]
#define ReadBackgroundColorOld [UIColor colorWithPatternImage:ReadBackgroundImageOld]
#define ReadBackgroundColorSafe [UIColor colorWithPatternImage:ReadBackgroundImageSafe]
#define ReadBackgroundColorDream [UIColor colorWithPatternImage:ReadBackgroundImageDream]



//5种阅读背景对应的文字颜色，因为对方给的是十六进制的RGB所以这里转换一下
#define ReadTextColorRGBDayStr @"#491a03"
#define ReadTextColorRGBDay 0x491a03
#define ReadTextColorRDay (((float)((ReadTextColorRGBDay & 0xFF0000) >> 16))/255.0)
#define ReadTextColorGDay (((float)((ReadTextColorRGBDay & 0xFF00) >> 8))/255.0)
#define ReadTextColorBDay (((float)((ReadTextColorRGBDay & 0xFF)))/255.0)

#define ReadTextColorRGBNightStr @"#725454"
#define ReadTextColorRGBNight 0x725454
#define ReadTextColorRNight (((float)((ReadTextColorRGBNight & 0xFF0000) >> 16))/255.0)
#define ReadTextColorGNight (((float)((ReadTextColorRGBNight & 0xFF00) >> 8))/255.0)
#define ReadTextColorBNight (((float)((ReadTextColorRGBNight & 0xFF)))/255.0)

#define ReadTextColorRGBOldStr @"#330000"
#define ReadTextColorRGBOld 0x330000
#define ReadTextColorROld (((float)((ReadTextColorRGBOld & 0xFF0000) >> 16))/255.0)
#define ReadTextColorGOld (((float)((ReadTextColorRGBOld & 0xFF00) >> 8))/255.0)
#define ReadTextColorBOld (((float)((ReadTextColorRGBOld & 0xFF)))/255.0)

#define ReadTextColorRGBSafeStr @"#000000"
#define ReadTextColorRGBSafe 0x000000
#define ReadTextColorRSafe (((float)((ReadTextColorRGBSafe & 0xFF0000) >> 16))/255.0)
#define ReadTextColorGSafe (((float)((ReadTextColorRGBSafe & 0xFF00) >> 8))/255.0)
#define ReadTextColorBSafe (((float)((ReadTextColorRGBSafe & 0xFF)))/255.0)

#define ReadTextColorRGBDreamStr @"#660033"
#define ReadTextColorRGBDream 0x660033
#define ReadTextColorRDream (((float)((ReadTextColorRGBDream & 0xFF0000) >> 16))/255.0)
#define ReadTextColorGDream (((float)((ReadTextColorRGBDream & 0xFF00) >> 8))/255.0)
#define ReadTextColorBDream (((float)((ReadTextColorRGBDream & 0xFF)))/255.0)

//真正用到的5种背景颜色
#define ReadTextColorDay [UIColor colorWithRed:ReadTextColorRDay green:ReadTextColorGDay blue:ReadTextColorBDay alpha:1.0];
#define ReadTextColorNight [UIColor colorWithRed:ReadTextColorRNight green:ReadTextColorGNight blue:ReadTextColorBNight alpha:1.0];
#define ReadTextColorOld [UIColor colorWithRed:ReadTextColorROld green:ReadTextColorGOld blue:ReadTextColorBOld alpha:1.0];
#define ReadTextColorSafe [UIColor colorWithRed:ReadTextColorRSafe green:ReadTextColorGSafe blue:ReadTextColorBSafe alpha:1.0];
#define ReadTextColorDream [UIColor colorWithRed:ReadTextColorRDream green:ReadTextColorGDream blue:ReadTextColorBDream alpha:1.0];




//flip mode 阅读时候的翻页方式
#define UserDefaultsValueFlipModeHorizontal @"左右翻页"
#define UserDefaultsValueFlipModeVertical @"上下翻页"

//fee notification 阅读时候时候自动续费的设定
#define UserDefaultsValueFeeNotificationOn @"续费提醒开"
#define UserDefaultsValueFeeNotificationOff @"续费提醒关"

//font size 阅读时候的字体大小设定
#define UserDefaultsValueFontSizeInvalid [NSNumber numberWithFloat:0.0]
#define UserDefaultsValueFontSizeDefault [NSNumber numberWithFloat:21.0]
#define UserDefaultsValueFontSizeMin [NSNumber numberWithFloat:19.0]
#define UserDefaultsValueFontSizeMax [NSNumber numberWithFloat:23.0]

#define UserDefaultsValueFontColorDefault @"blackColor"
#define UserDefaultsValueBackgroundColorDefault  @"clearColor"

#define UserDefaultsBookReadingPercentZero [NSNumber numberWithFloat:0.0] 
#define UserDefaultsBookReadingPercent @"user_defaults_key_book_reading_percent_%@"  //阅读进度

#define UserDefaultsValueToken              @"token"            //token
#define UserDefaultsValueUserid             @"userid"           //用户id
#define UserDefaultsValueVerifycode         @"verifycode"       //用户verifycode
#define UserDefaultsValueSnsid              @"snsid"            //sns账户id
#define UserDefaultsValueWidth              @"width"            //屏幕大小
#define UserDefaultsValuePassword           @"password"         //用户密码
#define UserDefaultsValueAccount            @"account"          //用户账号
#define UserDefaultsValueSavePassword       @"savepassword"     //是否保存了密码

//默认打开书架或书城时用到的键
#define UserDefaultsKeyOpenPageDefault  [NSNumber numberWithBool:NO]
#define UserDefaultsKeyOpenPageStore    [NSNumber numberWithBool:YES]

typedef enum {
    UserDefaultsKeyBrightness = 0, //brightness 阅读界面的亮度
    UserDefaultsKeyLastBackground,
    UserDefaultsKeyBackground,
    UserDefaultsKeyFlipMode, //flip mode 阅读时候的翻页方式
    UserDefaultsKeyFeeNotification, //fee notification 阅读时候时候自动续费的设定
    UserDefaultsKeyFontSize, //font size 阅读时候的字体大小设定
    UserDefaultsKeyFontColor,//字体颜色，不是候选的几种风格而是用户自己选择的颜色
    UserDefaultsKeyBackgroundColor,//背景颜色，不是候选的几种风格而是用户自己选择的颜色
    UserDefaultsKeyOthers,
    UserDefaultsKeyOpenPage,
    
}UserDefaultsKey;

@interface UserDefaultsManager : NSObject

+ (void)reset;
+ (void)setObject:(id)value forKey:(UserDefaultsKey)key;
+ (void)setObject:(id)value forKey:(UserDefaultsKey)key withObject:(NSString *)object;
+ (id)objectForKey:(UserDefaultsKey)key;
+ (id)objectForKey:(UserDefaultsKey)key withObject:(id)object;

@end
