//
//  NSString+XXSYDecoding.m
//  BookReader
//
//  Created by zhangbin on 4/11/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "NSString+XXSYDecoding.h"
#import "NSString+MD5.h"

#define dic @"0123456789ABCDEF"


@implementation NSString (XXSYDecoding)


- (NSString *)XXSYDecodingWithKey:(NSString *)key {
    NSLog(@"--Start--");
    NSString *userkey = [[self class] newDictKey:key];
    NSLog(@"key = %@, userKey = %@", key, userkey);
    NSMutableString *enString = [@"" mutableCopy];
    NSMutableString *deString = [@"" mutableCopy];
    NSInteger length = [self length];
    NSInteger count = 0;
    for (int i = 0; i < length; i++) {
        char k = [self characterAtIndex:i];
        int index = 0;
        for (int j = 0; j < [userkey length]; j++) {
            char m = [userkey characterAtIndex:j];
            if (m == k) {
                index = j;
                count++;
                break;
            }
        }
        [enString appendString:[NSString stringWithFormat:@"%X", index]];
        if (count == 4) {
            [deString appendString:[[self class] replaceUnicode:enString]];
            enString = [@"" mutableCopy];
            count = 0;
        }
    }
    NSLog(@"---END---");
    return deString;
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSMutableString *unicode = [@"" mutableCopy];
    [unicode setString:unicodeStr];
    [unicode insertString:@"\\U" atIndex:0];
    [unicode stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    [unicode insertString:@"\"" atIndex:0];
    [unicode appendString:@"\""];
    NSData *tempData = [unicode dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}


+ (NSString *)newDictKey:(NSString *)userkey {
    NSString *md5key = userkey;
    md5key = [[md5key md532] uppercaseString];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i = 0; i<[md5key length]; i++) {
        char k = [md5key characterAtIndex:i];
        NSString *kString = [NSString stringWithFormat:@"%c",k];
        if (![array containsObject:kString]) {
            [array addObject:kString];
        }
        if ([array count]>=16) {
            break;
        }
    }
    if ([array count]<16) {
        for (int i = 0; i<[dic length]; i++) {
            char k = [dic characterAtIndex:i];
            NSString *kString = [NSString stringWithFormat:@"%c",k];
            if (![array containsObject:kString]) {
                [array addObject:kString];
            }
            if ([array count]>=16) {
                break;
            }
        }
    }
    NSString *dictKey = @"";
    for (int i =0; i<[array count]; i++) {
        NSString  *kString = array[i];
        dictKey = [dictKey stringByAppendingString:kString];
    }
    return dictKey;
}

@end
