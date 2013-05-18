//
//  NSString+XXSY.m
//  BookReader
//
//  Created by zhangbin on 4/11/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "NSString+XXSY.h"
#import "ServiceManager.h"
#import <CoreText/CoreText.h>

#define dic @"0123456789ABCDEF"

@implementation NSString (XXSY)
- (NSString *)XXSYHandleRedundantTags
{
	return [self stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
}

- (NSString *)XXSYDecoding
{
	return [self XXSYDecodingWithKey:[ServiceManager XXSYDecodingKey]];
}

- (NSString *)XXSYDecodingWithKey:(NSString *)key
{
    NSLog(@"--Start--");
    const char *userkey = [[self class] newDictKey:key];
    NSLog(@"key = %@, userKey = %s", key, userkey);
    NSInteger length = [self length];
	char deBuffer[length*2];
    NSInteger count = 0;
	NSInteger bufferLoop = 0;
	deBuffer[bufferLoop++] = '\\';
	deBuffer[bufferLoop++] = 'u';
    for (int i = 0; i < length; i++) {
        char k = [self characterAtIndex:i];
        int index = 0;
        for (int j = 0; j < strlen(userkey); j++) {
            char m = userkey[j];
            if (m == k) {
                index = j;
                count++;
                break;
            }
        }
		char c[2];
		sprintf(c, "%X", index);
		deBuffer[bufferLoop++] = c[0];
		if (i == length - 1) {
			deBuffer[bufferLoop++] = '\0';
		}
		if (count == 4) {
			deBuffer[bufferLoop++] = '\\';
			deBuffer[bufferLoop++] = 'u';
			count = 0;
		}
    }
	NSString *debufferString = [[NSString alloc] initWithCString:deBuffer encoding:NSUTF8StringEncoding];
    NSLog(@"---END---");
    return [[[self class] replaceUnicode:debufferString] XXSYHandleRedundantTags];
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

+ (const char *)newDictKey:(NSString *)userkey
{
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
    return [dictKey UTF8String];
}

- (NSArray *)pagesWithFont:(CGSize)size inSize:(UIFont *)font
{
	
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CTFontRef fnt = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize,NULL);
    CFAttributedStringRef str = CFAttributedStringCreate(kCFAllocatorDefault,
                                                         (CFStringRef)self,
                                                         (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fnt,kCTFontAttributeName,nil]);
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString(str);
    CFRange r = {0,0};
    CFRange res = {0,0};
    NSInteger str_len = self.length;
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(fs,r, NULL, size, &res);
        r.location += res.length;
        NSRange range = NSMakeRange(res.location, res.length);
		[result addObject:NSStringFromRange(range)];
    } while(r.location < str_len);
	
    CFRelease(fs);
    CFRelease(str);
    CFRelease(fnt);
    return result;
}

@end
