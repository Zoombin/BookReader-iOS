//
//  NSUserDefaultsManager.m
//  iReader
//
//  Created by Archer on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserDefaultsManager.h"

@implementation UserDefaultsManager

+ (void)reset {
    NSInteger key = UserDefaultsKeyBrightness;
    NSNumber *value = UserDefaultsValueBrightnessDefault;
    [self setObject:value forKey:key];
    
    key = UserDefaultsKeyBackground;
    NSString *valueStr = UserDefaultsValueBackgroundDay;
    [self setObject:valueStr forKey:key];
    
    key = UserDefaultsKeyFlipMode;
    valueStr = UserDefaultsValueFlipModeHorizontal;
    [self setObject:valueStr forKey:key];
    
    key = UserDefaultsKeyFeeNotification;
    valueStr = UserDefaultsValueFeeNotificationOn;
    [self setObject:valueStr forKey:key];
    
    key = UserDefaultsKeyFontSize;
    value = UserDefaultsValueFontSizeDefault;
    [self setObject:value forKey:key];
    
    key = UserDefaultsKeyFontColor;
    NSString *fontvalue = UserDefaultsValueFontColorDefault;
    [self setObject:fontvalue forKey:key];
    
    key = UserDefaultsKeyBackgroundColor;
    NSString *backgroundvalue = UserDefaultsValueBackgroundColorDefault;
    [self setObject:backgroundvalue forKey:key];
    
//    key = UserDefaultsKeyOpenPage;
//    value = UserDefaultsKeyOpenPageDefault;
    [self setObject:UserDefaultsKeyOpenPageDefault forKey:UserDefaultsKeyOpenPage];
}

+ (void)setObject:(id)value forKey:(UserDefaultsKey)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *keyString = [NSString stringWithFormat:@"user_defaults_%d", (int)key];
    

    if(key == UserDefaultsKeyBrightness)
    {
        //you could do something here
    }
    else if(key == UserDefaultsKeyBackground)
    {
        //you could do something here
    }
    
    [defaults setObject:value forKey:keyString];
}

+ (void)setObject:(id)value forKey:(UserDefaultsKey)key withObject:(NSString *)object {
    if(key == UserDefaultsKeyOthers){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *keyString = [NSString stringWithFormat:@"user_defaults_%@",object];
        [defaults setObject:value forKey:keyString]; 
    }
}

+ (id)objectForKey:(UserDefaultsKey)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *keyString = [NSString stringWithFormat:@"user_defaults_%d", (int)key];
    
    if(key == UserDefaultsKeyBrightness)
    {
        NSNumber *value = [defaults objectForKey:keyString];
        if(value == nil || [value isEqualToNumber:UserDefaultsValueBrightnessInvalid]) {
            value = UserDefaultsValueBrightnessDefault;
            [self setObject:value forKey:key];
        }//如果无效说明是第一次请求这个值所以把它赋值为默认的值后存贮一下并且返回
        return value;
    }
    else if(key == UserDefaultsKeyBackground)
    {
        NSString *value = [defaults objectForKey:keyString];
        if(value == nil) {
            value = UserDefaultsValueBackgroundDay;
            [self setObject:value forKey:key];
        }
        return value;
    }
    else if(key == UserDefaultsKeyFlipMode)
    {
        NSString *value = [defaults objectForKey:keyString];
        if(value == nil) {
            value = UserDefaultsValueFlipModeHorizontal;
            [self setObject:value forKey:key];
        }
        return value;
    }
    else if(key == UserDefaultsKeyFeeNotification)
    {
        NSString *value = [defaults objectForKey:keyString];
        if(value == nil) {
            value = UserDefaultsValueFeeNotificationOn;
            [self setObject:value forKey:key];
        }
        return  value;
    }
    else if(key == UserDefaultsKeyFontSize)
    {
        NSNumber *value = [defaults objectForKey:keyString];
        if(value == nil || [value isEqualToNumber:UserDefaultsValueFontSizeInvalid]) {
            value = UserDefaultsValueFontSizeDefault;
            [self setObject:value forKey:key];
        }
        return value;
    }
    else if(key == UserDefaultsKeyFontColor) {
        NSString *value = [defaults objectForKey:keyString];
        if (value == nil || [value isEqualToString:@""]) {
            value = @"brownColor";
            [self setObject:value forKey:key];
        }
        return value;
    }
    else if(key == UserDefaultsKeyBackgroundColor) {
        NSString *value = [defaults objectForKey:keyString];
        if (value == nil || [value isEqualToString:@""]) {
            value = @"clearColor";
            [self setObject:value forKey:key];
        }
        return value;
    }
    else if(key == UserDefaultsKeyOpenPage) {
        NSNumber *value = [defaults objectForKey:keyString];
        if (value == nil) {
            value = UserDefaultsKeyOpenPageDefault;
            [self setObject:value forKey:key];
        }
        return value;
    }
    return nil;
}

+ (id)objectForKey:(UserDefaultsKey)key withObject:(NSString *)object {
    if(key == UserDefaultsKeyOthers) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *keyString = [NSString stringWithFormat:@"user_defaults_%@",object];
        return [defaults valueForKey:keyString];
    }
    return nil;
}

@end
