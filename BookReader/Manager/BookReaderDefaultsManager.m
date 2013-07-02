//
//  BookReaderDefaultManager.m
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookReaderDefaultsManager.h"

static NSArray *colors;
static NSArray *textColors;
static float brightValue;

@implementation BookReaderDefaultsManager

+ (UIColor *)backgroundColorWithIndex:(NSInteger)index
{
    if (!colors) {
        colors =
        @[[UIColor colorWithPatternImage:[UIImage imageNamed:@"read_sheep_paper"]],//羊皮纸风格
          [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_river_paper"]],//水墨江南
          [UIColor colorWithRed:204.0/255.0 green:234.0/255.0 blue:186.0/255.0 alpha:1.0],//护眼
          [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:33.0/255.0 alpha:1.0],//华灯初上
          [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_remember_paper"]],//粉红回忆
          [UIColor colorWithRed:245.0/255.0 green:240.0/255.0 blue:230.0/255.0 alpha:1.0],//白色婚纱
          [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_coffee_paper"]],//咖啡时光
          [UIColor colorWithRed:156.0/255.0 green:209.0/255.0 blue:229.0/255.0 alpha:1.0]];//天空之城
    }
    return [colors objectAtIndex:index];
}

+ (UIColor *)textColorWithIndex:(NSInteger)index
{
    if (!textColors) {
        textColors =
        @[[UIColor colorWithRed:65.0/255.0 green:51.0/255.0 blue:44.0/255.0 alpha:1.0],//羊皮纸风格
          [UIColor colorWithRed:23.0/255.0 green:32.0/255.0 blue:14.0/255.0 alpha:1.0],//水墨江南
          [UIColor colorWithRed:26.0/255.0 green:39.0/255.0 blue:20.0/255.0 alpha:1.0],//护眼
          [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0],//华灯初上
          [UIColor colorWithRed:82.0/255.0 green:9.0/255.0 blue:28.0/255.0 alpha:1.0],//粉红回忆
          [UIColor colorWithRed:50.0/255.0 green:49.0/255.0 blue:43.0/255.0 alpha:1.0],//白色婚纱
          [UIColor colorWithRed:214.0/255.0 green:195.0/255.0 blue:155.0/255.0 alpha:1.0],//咖啡时光
          [UIColor brownColor]];//天空之城
    }
    return [textColors objectAtIndex:index];
}

+ (void)setObject:(id)object ForKey:(id)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    NSString *keyString = (NSString *)key;
    if ([keyString isEqualToString:UserDefaultKeyBackground]) {
        [self setObject:object ForKey:UserDefaultKeyTextColor];
    }
}

+ (void)restoreOriginBright
{
    [[UIScreen mainScreen] setBrightness:brightValue];
}

+ (void)saveOriginBright
{
    brightValue = [[UIScreen mainScreen] brightness];
}

+ (id)objectForKey:(id)key
{
	id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (value) {
		return value;
	} else {
		NSString *keyString = (NSString *)key;
		if ([keyString isEqualToString:UserDefaultKeyFontSize]) {
			value = UserDefaultFontSizeMin;
		} else if ([keyString isEqualToString:UserDefaultKeyFontName]) {
			value = UserDefaultFoundFont;
		} else if ([keyString isEqualToString:UserDefaultKeyFont]) {
			NSString *fontName = [self objectForKey:UserDefaultKeyFontName];
			NSString *fontSize = [self objectForKey:UserDefaultKeyFontSize];
			return [UIFont fontWithName:fontName size:fontSize.floatValue];
		} else if ([keyString isEqualToString:UserDefaultKeyBright]) {
			value = @1.0;
		} else if ([keyString isEqualToString:UserDefaultKeyBackground]) {
			value = @0;//羊皮纸
		} else if ([keyString isEqualToString:UserDefaultKeyScreen]) {
            value = UserDefaultScreenVer;
        }
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return value;
}

+ (void)reset
{
    id value;
    NSString *keyString = @"";
    
    keyString = UserDefaultKeyFontSize;
    value = UserDefaultFontSizeMin;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyString];
    
    keyString = UserDefaultKeyFontName;
    value = UserDefaultFoundFont;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyString];
    
    keyString = UserDefaultKeyTextColor;
    value = UserDefaultTextColorBrown;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyString];
    
    keyString = UserDefaultKeyBright;
    value = @1.0;
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyString];
    
    keyString = UserDefaultKeyBackground;
    value = @0;//羊皮纸
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyString];
    
    keyString = UserDefaultKeyScreen;
    value = UserDefaultScreenVer;//羊皮纸
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyString];
}
@end
