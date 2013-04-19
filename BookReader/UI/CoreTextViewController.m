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
#import "ReadStatusView.h"
#import "BookReadMenuView.h"
#import "SubscribeViewController.h"
#import "NSString+XXSYDecoding.h"

@interface CoreTextViewController ()

@end

@implementation CoreTextViewController {
    CoreTextView *coreTextView;
    NSMutableArray *pagesArray;
    NSMutableString *mString;
    NSMutableString *textString;
    UIFont *currentFont;
    CGFloat currentFontSize;
    int currentPage;
    
    ReadStatusView *statusView;
    BookReadMenuView *menuView;
    
    Chapter *chapter;
    Book *book;
    
    NSString *userid;
}

- (id)initWithBook:(Book *)bookObj
        andChapter:(Chapter *)chapterObj
{
    self = [super init];
    if (self)
    {
        book = bookObj;
        chapter = chapterObj;
        currentPage = 0;
        bFlipV = NO;
        mString = [@"" mutableCopy];
        textString = [@"" mutableCopy];
        
        userid = [NSString stringWithFormat:@"04B6A5985B70DC641B0E98C0F8B221A6%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userid"]];
        if (userid==nil) {
            userid = @"0";
        }
        [textString setString:[chapter.text XXSYDecodingWithKey:userid]];
        currentFontSize = 17;
        currentFont = [UIFont fontWithName:@"FZLTHJW--GB1-0" size:currentFontSize];
        pagesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 20)];
    [statusView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:statusView];
    
    statusView.title.text = book.name;
    
    coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 20, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-40)];
    [coreTextView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:coreTextView];
    
    menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-20)];
    [menuView setDelegate:self];
    [menuView setBackgroundColor:[UIColor clearColor]];
    
    menuView.titleLabel.text = book.name;
    [self.view addSubview:menuView];
    menuView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateContent];
}

- (void)updateContent {
    if ([pagesArray count]==0) {
        [pagesArray addObjectsFromArray:[self pagesWithString:textString size:CGSizeMake(coreTextView.frame.size.width, coreTextView.frame.size.height) font:currentFont]];
    }
    [mString setString:[textString substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPage])]];
    [self updateStatusPercentage];
    coreTextView.fontSize = currentFontSize;
    coreTextView.font =currentFont;
	[coreTextView buildTextWithString:mString];
	[coreTextView setNeedsDisplay];
}

- (void)updateStatusPercentage
{
    if (!statusView)
    {
        return;
    }
    statusView.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self readPercentage]];
    if ([pagesArray count]==1)
    {
        statusView.percentage.text = @"100.00%";
    }
}

- (float)readPercentage
{
    if (![pagesArray count])
    {
        return 0.0;
    }
    float percentage = (float)( (float)(currentPage + 1) / (float)([pagesArray count]) );
    if (currentPage == 0) {
        percentage = 0.0;
    }
    return percentage * 100.0f;
}


- (void)nextPage
{
    currentPage++;
    if(currentPage >= [pagesArray count])
    {
        currentPage = [pagesArray count] - 1;
        [self displayHUDError:@"" message:NSLocalizedString(@"finel page", nil)];
        NSLog(@"no more next!");
        return;
    }
    
    if (bFlipV) {
        [self performTransition:kCATransitionFromTop andType:@"pageCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageCurl"];
    
    [self updateContent];
}

- (void)menu
{
    startPointX = NSIntegerMax;
    startPointY = NSIntegerMax;
    menuView.hidden = !menuView.hidden;
}

- (void)previousPage
{
    currentPage--;
    if(currentPage < 0)
    {
        currentPage = 0;
        [self displayHUDError:@"" message:NSLocalizedString(@"first page", nil)];
        NSLog(@"no more previous!");
        return;
    }
    if (bFlipV) {
        [self performTransition:kCATransitionFromBottom andType:@"pageUnCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageUnCurl"];
    [self updateContent];
}

- (BOOL)pointInMenuTouchX:(float)x andY:(float)y
{
	float pageOffset = 0*coreTextView.bounds.size.width;
    if (x >= pageOffset+MAIN_SCREEN.size.width/3 && x <= pageOffset+MAIN_SCREEN.size.width/3*2 && y >= MAIN_SCREEN.size.height/3 && y <= MAIN_SCREEN.size.height/3*2) {
        return YES;
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *start = [[event allTouches] anyObject];
    CGPoint startPoint = [start locationInView:self.view];
    
    startPointX = startPoint.x;
    startPointY = startPoint.y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *end = [[event allTouches] anyObject];
    CGPoint endPoint = [end locationInView:self.view];
    float endPointX = endPoint.x;
    float endPointY = endPoint.y;
    
    //NSLog(@"end ponts x : %f y : %f", endPoint.x, endPoint.y);
    
    if (startPointX == NSIntegerMax || startPointY == NSIntegerMax) {
        return;
    }
    
    if (bFlipV) {
        if (fabs(endPointY - startPointY) >= 9)
        {
            if (endPointY > startPointY) {
                [self previousPage];
            } else {
                [self nextPage];
            }
            return;
        }
        
        if ([self pointInMenuTouchX:endPointX andY:endPointY])
        {
            [self menu];
            return;
        }
        
        if (endPointY >= MAIN_SCREEN.size.height/2)
        {
            [self nextPage];
            return;
        }
        else {
            [self previousPage];
            return;
        }
    } else {
        if (fabsf(endPointX - startPointX) >= 9)
        {
            if (endPointX > startPointX ) {
                [self previousPage];
            }else {
                [self nextPage];
            }
            return;
        }
        
        if ([self pointInMenuTouchX:endPointX andY:endPointY])
        {
            [self menu];
            return;
        }
        
        if(endPointX >= MAIN_SCREEN.size.width/2)
        {
            [self nextPage];
            return;
        }
        else
        {
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

#pragma mark -
#pragma mark BookReadMenuDelegate
- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBookMarkButtonPressed
{
    NSLog(@"添加书签成功");
}

- (void)chapterButtonClick
{
    SubscribeViewController *childViewController = [[SubscribeViewController alloc] initWithBookId:book];
    [self.navigationController pushViewController:childViewController animated:YES];
}

@end
