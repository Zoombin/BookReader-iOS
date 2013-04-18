//
//  CoreTextViewController.m
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "CoreTextViewController.h"
#import "CoreTextView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+HUD.h"
#import "UIDefines.h"


@interface CoreTextViewController ()

@end

@implementation CoreTextViewController {
    CoreTextView *coreTextView;
    NSMutableArray *pagesArray;
    NSMutableString *mString;
    NSMutableString *textString;
    int currentPage;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPage = 0;
    bFlipV = NO;
     mString = [@"" mutableCopy];
    textString = [@"" mutableCopy];
    
    pagesArray = [[NSMutableArray alloc] init];
    coreTextView = [[CoreTextView alloc] initWithFrame:self.view.bounds];
    [coreTextView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:coreTextView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displayHUD:@"加载中..."];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:@"test_book" ofType:@"txt"];
    NSString *str = [[NSString alloc] initWithContentsOfFile:documentDir encoding:NSUTF8StringEncoding error:nil];
    [textString setString:str];
    if ([pagesArray count]==0) {
    [pagesArray addObjectsFromArray:[self pagesWithString:str size:CGSizeMake(coreTextView.frame.size.width, coreTextView.frame.size.height) font:[UIFont fontWithName:@"Helvetica" size:20]]];
    }
    [mString setString:[str substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPage])]];
    [self updateContent];
    [self hideHUD:YES];
}

- (void)updateContent {
	[coreTextView buildTextWithString:mString];
	[coreTextView setNeedsDisplay];
}


- (void)nextPage {
    currentPage++;
    if(currentPage >= [pagesArray count]) {
        currentPage = [pagesArray count] - 1;
        [self displayHUDError:@"" message:NSLocalizedString(@"finel page", nil)];
        NSLog(@"no more next!");
        return;
    }
    if (bFlipV) {
        [self performTransition:kCATransitionFromTop andType:@"pageCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageCurl"];
    [mString setString:[textString substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPage])]];
    [self updateContent];
}

- (void)menu
{
    
}

- (void)previousPage {
    currentPage--;
    if(currentPage < 0) {
        currentPage = 0;
        [self displayHUDError:@"" message:NSLocalizedString(@"first page", nil)];
        NSLog(@"no more previous!");
        return;
    }
    if (bFlipV) {
        [self performTransition:kCATransitionFromBottom andType:@"pageUnCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageUnCurl"];
    [mString setString:[textString substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPage])]];
    [self updateContent];
}

- (BOOL)pointInMenuTouchX:(float)x andY:(float)y {
	float pageOffset = 0*coreTextView.bounds.size.width;
    if (x >= pageOffset+MAIN_SCREEN.size.width/3 && x <= pageOffset+MAIN_SCREEN.size.width/3*2 && y >= MAIN_SCREEN.size.height/3 && y <= MAIN_SCREEN.size.height/3*2) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *start = [[event allTouches] anyObject];
    CGPoint startPoint = [start locationInView:self.view];
    
    startPointX = startPoint.x;
    startPointY = startPoint.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended!");
    UITouch *end = [[event allTouches] anyObject];
    CGPoint endPoint = [end locationInView:self.view];
    float endPointX = endPoint.x;
    float endPointY = endPoint.y;
    
    //NSLog(@"end ponts x : %f y : %f", endPoint.x, endPoint.y);
    
    if (startPointX == NSIntegerMax || startPointY == NSIntegerMax) {
        return;
    }
    
    if (bFlipV) {
        if (fabs(endPointY - startPointY) >= 9) {
            if (endPointY > startPointY) {
                [self previousPage];
            } else {
                [self nextPage];
            }
            return;
        }
        
        if ([self pointInMenuTouchX:endPointX andY:endPointY]) {
            [self menu];
            return;
        }
        
        if (endPointY >= MAIN_SCREEN.size.height/2) {
            [self nextPage];
            return;
        }
        else {
            [self previousPage];
            return;
        }
    } else {
        if (fabsf(endPointX - startPointX) >= 9) {
            if (endPointX > startPointX ) {
                [self previousPage];
            }else {
                [self nextPage];
            }
            return;
        }
        
        if ([self pointInMenuTouchX:endPointX andY:endPointY]) {
            [self menu];
            return;
        }
        
        if(endPointX >= MAIN_SCREEN.size.width/2) {
            [self nextPage];
            return;
        }
        else {
            [self previousPage];
            return;
        }
    }
}


- (NSArray*) pagesWithString:(NSString*)string size:(CGSize)size font:(UIFont*)font;
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:32];
    CTFontRef fnt = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize,NULL);
    CFAttributedStringRef str = CFAttributedStringCreate(kCFAllocatorDefault,
                                                         (CFStringRef)string,
                                                         (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fnt,kCTFontAttributeName,nil]);
    CTFramesetterRef fs = CTFramesetterCreateWithAttributedString(str);
    CFRange r = {0,0};
    CFRange res = {0,0};
    NSInteger str_len = [string length];
    do {
        CTFramesetterSuggestFrameSizeWithConstraints(fs,r, NULL, size, &res);
        r.location += res.length;
        NSRange range = NSMakeRange(res.location, res.length);
        [result addObject:[NSString stringWithFormat:@"(%d,%d)",range.location,range.length]];
    } while(r.location < str_len);
    
    CFRelease(fs);
    CFRelease(str);
    CFRelease(fnt);
    return result;
}

//翻页动画
-(void)performTransition:(NSString *)transitionType andType:(NSString *)type
{
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.75;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    transition.subtype = transitionType;
	transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
}

@end
