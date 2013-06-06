//
//  BookReaderDefaultManager.m
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookReaderDefaultsManager.h"

static NSArray *colors;

@implementation BookReaderDefaultsManager

+ (UIColor *)backgroundColorWithIndex:(NSInteger)index
{
    if (!colors) {
        colors =
  @[[UIColor colorWithPatternImage:[UIImage imageNamed:@"read_sheep_paper"]],//羊皮纸风格
    [UIColor colorWithRed:251.0/255.0 green:249.0/255.0 blue:234.0/255.0 alpha:1.0],
    [UIColor colorWithRed:224.0/255.0 green:236.0/255.0 blue:224.0/255.0 alpha:1.0],
    [UIColor colorWithRed:228.0/255.0 green:237.0/255.0 blue:243.0/255.0 alpha:1.0],
    [UIColor colorWithRed:245.0/255.0 green:251.0/255.0 blue:255.0/255.0 alpha:1.0],
    [UIColor colorWithRed:235.0/255.0 green:237.0/255.0 blue:193.0/255.0 alpha:1.0],
    [UIColor colorWithRed:215.0/255.0 green:243.0/255.0 blue:244.0/255.0 alpha:1.0],
    [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0],
    [UIColor colorWithRed:134.0/255.0 green:180.0/255.0 blue:217.0/255.0 alpha:1.0],
    [UIColor colorWithRed:251.0/255.0 green:225.0/255.0 blue:218.0/255.0 alpha:1.0],
    [UIColor colorWithRed:35.0/255.0 green:48.0/255.0 blue:47.0/255.0 alpha:1.0],
    [UIColor colorWithRed:50.0/255.0 green:62.0/255.0 blue:80.0/255.0 alpha:1.0],
    [UIColor colorWithRed:50.0/255.0 green:53.0/255.0 blue:50.0/255.0 alpha:1.0],
    [UIColor colorWithRed:87.0/255.0 green:103.0/255.0 blue:79.0/255.0 alpha:1.0],
    [UIColor colorWithRed:166.0/255.0 green:137.0/255.0 blue:193.0/255.0 alpha:1.0],
    [UIColor colorWithRed:9.0/255.0 green:14.0/255.0 blue:14.0/255.0 alpha:1.0],];
    }
    return [colors objectAtIndex:index];
}

+ (void)setObject:(id)object ForKey:(id)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
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
		} else if ([keyString isEqualToString:UserDefaultKeyTextColor]) {
			value = UserDefaultTextColorBlack;
		} else if ([keyString isEqualToString:UserDefaultKeyBright]) {
			value = @1.0;
		} else if ([keyString isEqualToString:UserDefaultKeyBackground]) {
			value = @0;//羊皮纸
		}
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return value;
}
@end
