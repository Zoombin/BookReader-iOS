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

@implementation NSString (XXSY)
- (NSString *)XXSYHandleRedundantTags
{
	return [self stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n"];
}

- (NSString *)XXSYDecoding
{
    NSString *key = @"04B6A5985B70DC641B0E98C0F8B221A60";
    const char *userkey = [[self class] newDictKey:key];
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
//    NSLog(@"---END---");
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
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [md5key length]; i++) {
        char k = [md5key characterAtIndex:i];
        NSString *kString = [NSString stringWithFormat:@"%c",k];
        if (![array containsObject:kString]) {
            [array addObject:kString];
        }
        if ([array count] == 16) {
            break;
        }
    }
    if ([array count] < 16) {
        for (int i = 0; i < 16; i++) {
            NSString *kString = [NSString stringWithFormat:@"%X", i];
            if (![array containsObject:kString]) {
                [array addObject:kString];
            }
            if ([array count] == 16) {
                break;
            }
        }
    }
	
    NSMutableString *dictKey = [NSMutableString string];
    for (int i = 0; i < [array count]; i++) {
		[dictKey  appendString:array[i]];
    }
    return [dictKey UTF8String];
}

- (NSArray *)pagesWithFont:(UIFont *)font inSize:(CGSize)size
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CTFontRef fnt = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize,NULL);
    CFAttributedStringRef str = CFAttributedStringCreate(kCFAllocatorDefault,
                                                         (CFStringRef)self,
                                                         (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fnt,kCTFontAttributeName,nil]);
    
   //TODO:增加行间距
    CFRange range = CFRangeMake(0, CFStringGetLength((CFStringRef)str));
    CTParagraphStyleSetting LineSpacing;
    CGFloat spacing = 10.0;  //指定间距
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &spacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    CTParagraphStyleSetting settings[] = {LineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);   //第二个参数为settings的长度
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)str, range,
                                   kCTParagraphStyleAttributeName, paragraphStyle);
    
    
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

/*
 作用:截取从value1到value2之间的字符串
 str:要处理的字符串
 value1:左边匹配字符串
 value2:右边匹配字符串
 返回值:需要的字符串
 */
+ (NSString *)str:(NSString *)str
          value1:(NSString *)value1
          value2:(NSString *)value2{
    //i:左边匹配字符串在str中的下标
    int i;
    //j:右边匹配字符串在str1中的下标
    int j;
    //该类可以通过value1匹配字符串
    NSRange range1 = [str rangeOfString:value1];
    //判断range1是否匹配到字符串
    if(range1.length>0){
        //把其转换为NSString
        NSString *result1 = NSStringFromRange(range1);
        i = [self indexByValue:result1];
        //原因:加上匹配字符串的长度从而获得正确的下标
        i = i+[value1 length];
    }else {
        return @"";
    }
    
    //通过下标，删除下标以前的字符
    NSString *str1 = [str substringFromIndex:i];
    NSRange range2 = [str1 rangeOfString:value2];
    if(range2.length>0){
        NSString *result2 = NSStringFromRange(range2);
        j = [self indexByValue:result2];
    }else {
        return @"";
    }
    
    NSString *str2 = [str1 substringToIndex:j];
    return str2;
}

/*
 str:得到的range类的集合
 过滤获得的匹配信息
 返回值:返回下标
 */
+ (int)indexByValue:(NSString *)str{
    //使用NSMutableString类，它可以实现追加
    NSMutableString *value = [[NSMutableString alloc] initWithFormat:@""];
    NSString *colum2 = @"";
    int j = 0;
    //遍历出下标值
    for(int i=1;i<[str length];i++){
        NSString *colum1 = [str substringFromIndex:i];
        [value appendString:colum2];
        colum2 = [colum1 substringToIndex:1];
        if([colum2 isEqualToString:@","]){
            j = [value intValue];
            break;
        }
    }
    return j;
}

@end
