//
//  CoreTextView.m
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "CoreTextView.h"
#import "NSString+BundleExtensions.h"

#define PADDING_LEFT 10.0
#define PADDING_TOP 10.0

@implementation CoreTextView
{
    CFMutableAttributedStringRef attrString;
    CGFloat fontSize;
    CFMutableArrayRef fontsMutable;
}
@synthesize fontSize;
@synthesize font;
@synthesize textColor;



- (void)loadMutableFonts {
	/* load all existing fonts */
	CTFontCollectionRef collection = CTFontCollectionCreateFromAvailableFonts(NULL);
	CFArrayRef fonts = CTFontCollectionCreateMatchingFontDescriptors(collection);
	CFIndex count = CFArrayGetCount(fonts);
	fontsMutable = CFArrayCreateMutable(kCFAllocatorDefault, count, NULL);
	
	for (int i = 0; i < count; i++)
	{
		CTFontDescriptorRef desc = (CTFontDescriptorRef)CFArrayGetValueAtIndex(fonts, i);
		CFStringRef fontName = CTFontDescriptorCopyAttribute(desc,kCTFontNameAttribute);
		CFArrayAppendValue(fontsMutable, fontName);
		CFRelease(fontName);
	}
	
    CFArraySortValues(fontsMutable, CFRangeMake(0, count), (CFComparatorFunction)CFStringCompare, NULL);
	CFRelease(fonts);
}

- (void)buildTextWithString:(NSString *)string {
	if(attrString) {
		CFRelease(attrString);
	}
	NSMutableString *mString;
	attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    mString = [string mutableCopy];
    
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)mString);
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CTFontRef myFont = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
    CFRange range = CFRangeMake(0, CFStringGetLength((CFStringRef)mString));
    CFAttributedStringSetAttribute(attrString, range, kCTFontAttributeName, myFont);
    
    CGColorRef color = textColor.CGColor;
    CFAttributedStringSetAttribute(attrString, range,
                                   kCTForegroundColorAttributeName, color);
    
//    CTParagraphStyleSetting lineBreakMode;
//    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
//    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
//    lineBreakMode.value = &lineBreak;
//    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //行间距
    CTParagraphStyleSetting LineSpacing;
    CGFloat spacing = 10.0;  //指定间距
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &spacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {LineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);   //第二个参数为settings的长度
    
    CFAttributedStringSetAttribute(attrString, range,
                                   kCTParagraphStyleAttributeName, paragraphStyle);
}

- (void) drawRect:(CGRect)rect {
	if(!attrString) {
		[self buildTextWithString:@""];
	}
	/* get the context */
	CGContextRef context = UIGraphicsGetCurrentContext();
	/* flip the coordinate system */
	float viewHeight = self.bounds.size.height;
    CGContextTranslateCTM(context, 0, viewHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, 1.0));
	/* generate the path for the text */
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect bounds = CGRectMake(8, 0, self.bounds.size.width-8, self.bounds.size.height);
	CGPathAddRect(path, NULL, bounds);
    
	/* draw the text */
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
												CFRangeMake(0, 0), path, NULL);
	CFRelease(framesetter);
	CFRelease(path);
	CTFrameDraw(frame, context);
}


@end
