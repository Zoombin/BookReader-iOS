//
//  BookReaderDefaultManager.m
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookReaderDefaultManager.h"

@implementation BookReaderDefaultManager

+ (void)saveUserid:(id)object
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:UserDefaultUserid];
}

+ (id)userid
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultUserid];
}

+ (void)deleteUserid
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UserDefaultUserid];
}


+ (void)reset
{
    [self setObject:UserDefaultFontSizeMin ForKey:UserDefaultKeyFontSize];
    [self setObject:UserDefaultSystemFont ForKey:UserDefaultKeyFontName];
    [self setObject:UserDefaultTextColorBlack ForKey:UserDefaultKeyTextColor];
    [self setObject:UserDefaultBrightDefault ForKey:UserDefaultKeyBright];
}


+ (void)setObject:(id)object ForKey:(id)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
}

+ (id)objectForKey:(id)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}
@end
