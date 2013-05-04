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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        font = [UIFont fontWithName:@"FZLTHJW--GB1-0" size:19];
        fontSize = 19;
    }
    return self;
}

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
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFStringGetLength((CFStringRef)mString)), kCTFontAttributeName, myFont);
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
	CGRect bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
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
