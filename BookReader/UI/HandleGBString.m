
#import "HandleGBString.h"
#import <CoreText/CoreText.h>

@implementation HandleGBString


+ (NSMutableString *)handleGBString:(NSString *)origin withFontSize:(int)fontSize andPages:(NSMutableArray **)pages andGBCode:(BOOL)bGB andAD:(BOOL)bAD {
    
/*
    NSStringEncoding enc;
    if(bGB)
        enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    else {
        enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    }
    NSString *gbString = [NSString stringWithString:origin];
    NSData *data = [gbString dataUsingEncoding:enc];
    
    int len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    for(int i = 0; i < len; ++i) {
        if(!bGB) {
            if(byteData[i] == 0x0a) {
                byteData[i] = 0x00;
            }
        }
        else {
            if(byteData[i] == 0x0a) {
                byteData[i] = 0x00;
            }
        }
    }
    data = [[NSData alloc] initWithBytes:byteData length:len];
    NSMutableString *handledString = [[NSMutableString alloc] initWithData:data encoding:enc];
    
    free(byteData);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:handledString];
    
    CGFloat lineSpace =1.9;
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceStyle.valueSize = sizeof(lineSpace);
    lineSpaceStyle.value =&lineSpace;
    
    uint8_t breakMode = kCTLineBreakByWordWrapping;
    CTParagraphStyleSetting wordBreakingStyle = { kCTParagraphStyleSpecifierLineBreakMode, sizeof(uint8_t), &breakMode };
    
    //    CGFloat paragraphSpacing = 0.0;
    //    CTParagraphStyleSetting paragraphSpaceStyle;
    //    paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierLineBreakMode;
    //    paragraphSpaceStyle.valueSize = sizeof(CGFloat);
    //    paragraphSpaceStyle.value = &paragraphSpacing;
    
    CTParagraphStyleSetting settings[] ={ lineSpaceStyle, wordBreakingStyle };
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings , sizeof(settings));
    
	// make a few words bold
	CTFontRef helvetica = CTFontCreateWithName(CFSTR("STHeitiSC-Light"), fontSize, NULL);
    
	[string addAttribute:(id)kCTFontAttributeName value:(id)helvetica range:NSMakeRange(0, [string length])];
    
    [string addAttribute:(id)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0 , [string length])];
    
	//[string addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, [string length])];
    
	// layout master
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    
    NSString *verstionStr = [NSString stringWithFormat:@"%c",[[[UIDevice currentDevice] systemVersion] characterAtIndex:0]];
    int version = [verstionStr intValue];
    float TEXT_HEIGHT = [[UIScreen mainScreen]bounds].size.height-30;
    float TEXT_WIDTH = [[UIScreen mainScreen]bounds].size.width;
    if ([[UIScreen mainScreen]bounds].size.height==480) {
        NSLog(@"--->>>iphone4");
        if (!bAD) {
            if (version<5) {
                NSLog(@"低版本");
                if (fontSize == 21) {
                    TEXT_WIDTH -= 20;
                    TEXT_HEIGHT -= 15;
                }
                if (fontSize == 22) {
                    TEXT_WIDTH -= 15;
                    TEXT_HEIGHT -= 15;
                }
                if(fontSize == 23) {
                    TEXT_WIDTH -= 15;
                    TEXT_HEIGHT -= 15;
                }
            }else {
                if(fontSize == 20) {
                    TEXT_WIDTH -= 20;
                    TEXT_HEIGHT -= 10;
                }
                if(fontSize == 23) {
                    TEXT_HEIGHT -= 15;
                }
            }
        } else {
            if (version<5) {
                if (fontSize == 22) {
                    TEXT_WIDTH -= 30;
                    TEXT_HEIGHT -= 60;
                }
                else {
                    TEXT_WIDTH -= 15;
                    TEXT_HEIGHT -= 60;
                }

            }else {
                if(fontSize == 20)
                {
                    TEXT_WIDTH -= 20;
                    TEXT_HEIGHT -= 60;
                } else
                {
                    TEXT_HEIGHT -= 60;
                }
            }
        }
    }
    
    if ([[UIScreen mainScreen]bounds].size.height==568) {
        NSLog(@"--->>>iphone5");
        if (!bAD) {
            if (fontSize == 20) {
                TEXT_HEIGHT-= 40;
            }
        }
        else {
            if(fontSize == 20)
            {
                TEXT_WIDTH -= 20;
                TEXT_HEIGHT -= 60;
            }else
            {
                TEXT_HEIGHT -= 60;
            }
        }
    }
    
    if ([[UIScreen mainScreen]bounds].size.height==1024) {
        NSLog(@"--->>>ipad");
        if (!bAD) {
            if (version<5) {
               TEXT_WIDTH-= 30;
               TEXT_HEIGHT-= 30;
            }else {
               TEXT_HEIGHT-= 20;  
            }
        }else {
            if (version<5) {
                TEXT_WIDTH-= 30;
                TEXT_HEIGHT-= 90;
            } else {
                TEXT_HEIGHT-= 60;  
            }
        }
        
    }
    
    int count = 0;
    int location = 0;
    
    NSInteger length = 0;
    NSRange range;
    
    while (1) {
        CGMutablePathRef columnPath = CGPathCreateMutable();
        CGPathAddRect(columnPath, NULL, CGRectMake(count*TEXT_WIDTH, 0, TEXT_WIDTH,TEXT_HEIGHT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(location, 0),columnPath, NULL);
        
        length = CTFrameGetVisibleStringRange(frame).length;
        
        range.location = location;
        range.length = length;
        location += length;
        
        NSString *rangeStr = NSStringFromRange(range);
        [(NSMutableArray *)(*pages) addObject:rangeStr];
        
        if(frame)
            CFRelease(frame);
        if(columnPath)
            CGPathRelease(columnPath);
        
        if(location >= [string length])
            break;
        count++;
    }
    
    //NSLog(@"pagesArray = %@", (NSMutableArray *)(*pages));
    
	CFRelease(framesetter);
	CFRelease(helvetica);
    return [[NSMutableString alloc] initWithString:origin];
 */
    return nil;
}




@end
