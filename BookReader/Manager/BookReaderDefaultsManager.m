//
//  BookReaderDefaultManager.m
//  BookReader
//
//  Created by ZoomBin on 13-5-4.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BookReaderDefaultsManager.h"

static NSArray *colors;
static NSArray *textColors;

@implementation BookReaderDefaultsManager

+ (UIColor *)brBackgroundColorWithIndex:(NSInteger)index
{
    if ([[self brObjectForKey:UserDefaultKeyScreen] isEqualToString:UserDefaultScreenLandscape] && index == 0) {
        return [UIColor colorWithPatternImage:[UIImage imageNamed:@"read_sheep_paper_hor"]];
    }
    if (!colors) {
        colors =
        @[[UIColor colorWithPatternImage:[UIImage imageNamed:@"read_sheep_paper"]],//羊皮纸风格
          [UIColor colorWithRed:230.0/255.0 green:240.0/255.0 blue:220.0/255.0 alpha:1.0],//水墨江南
          [UIColor colorWithRed:204.0/255.0 green:234.0/255.0 blue:186.0/255.0 alpha:1.0],//护眼
          [UIColor colorWithRed:42.0/255.0 green:39.0/255.0 blue:33.0/255.0 alpha:1.0],//华灯初上
          [UIColor colorWithRed:235.0/255.0 green:202.0/255.0 blue:187.0/255.0 alpha:1.0],//粉红回忆
          [UIColor colorWithRed:245.0/255.0 green:240.0/255.0 blue:230.0/255.0 alpha:1.0],//白色婚纱
          [UIColor colorWithRed:66.0/255.0 green:44.0/255.0 blue:24.0/255.0 alpha:1.0],//咖啡时光
          [UIColor colorWithRed:156.0/255.0 green:209.0/255.0 blue:229.0/255.0 alpha:1.0]];//天空之城
    }
    return [colors objectAtIndex:index];
}

+ (UIColor *)brTextColorWithIndex:(NSInteger)index
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

+ (void)brSetObject:(id)object ForKey:(id)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    NSString *keyString = (NSString *)key;
    if ([keyString isEqualToString:UserDefaultKeyBackground]) {
        [self brSetObject:object ForKey:UserDefaultKeyTextColor];
    }
}

+ (id)brObjectForKey:(id)key
{
	id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (value) {
		return value;
	} else {
		NSString *keyString = (NSString *)key;
		if ([keyString isEqualToString:UserDefaultKeyFontSize]) {
			value = UserDefaultFontSizeMin;
		} else if ([keyString isEqualToString:UserDefaultKeyFontName]) {
			value = UserDefaultNorthFont;
		} else if ([keyString isEqualToString:UserDefaultKeyFont]) {
			NSString *fontName = [self brObjectForKey:UserDefaultKeyFontName];
			NSString *fontSize = [self brObjectForKey:UserDefaultKeyFontSize];
			return [UIFont fontWithName:fontName size:fontSize.floatValue];
		} else if ([keyString isEqualToString:UserDefaultKeyBright]) {
			value = @1.0;
		} else if ([keyString isEqualToString:UserDefaultKeyBackground]) {
			value = @0;//羊皮纸
		} else if ([keyString isEqualToString:UserDefaultKeyScreen]) {
            value = UserDefaultScreenPortrait;
        }
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return value;
}

+ (void)brReset
{
	NSDictionary *defaults = @{	UserDefaultKeyFontSize : UserDefaultFontSizeMin,
								UserDefaultKeyFontName : UserDefaultNorthFont,
								UserDefaultKeyTextColor : UserDefaultTextColorBrown,
								UserDefaultKeyBright : @(1.0f),
								UserDefaultKeyBackground : @(0),
								UserDefaultKeyScreen : UserDefaultScreenPortrait};
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[defaults enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[userDefaults setObject:obj forKey:key];
	}];
	[userDefaults synchronize];
}
@end
