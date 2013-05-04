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
#import "Book.h"
#import "ServiceManager.h"

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
    BOOL bOnline;
    
    ReadStatusView *statusView;
    BookReadMenuView *menuView;
    
    Chapter *chapter;
    Book *book;
    
    NSMutableArray *chaptersArray;
    
    NSNumber *userid;
    NSString *key;
}

- (id)initWithBook:(Book *)bookObj
           chapter:(Chapter *)chapterObj
     chaptersArray:(NSArray *)array
         andOnline:(BOOL)online;
 
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
        bOnline = online;
        
        chaptersArray = [[NSMutableArray alloc] initWithArray:array];
        userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userid"];
        
        key = [NSString stringWithFormat:@"04B6A5985B70DC641B0E98C0F8B221A6%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userid"]];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"userid"]==nil) {
            key = @"04B6A5985B70DC641B0E98C0F8B221A60";
        }
        [textString setString:[chapter.content XXSYDecodingWithKey:key]];
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
    
    statusView.title.text = chapter.name;
    
    coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 20, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-40)];
    [coreTextView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:coreTextView];
    
    menuView = [[BookReadMenuView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-20)];
    [menuView setDelegate:self];
    [menuView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:menuView];
    menuView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateContent];
}

- (void)updateContent {
    if ([pagesArray count]>0) {
        [pagesArray removeAllObjects];
    }
    [pagesArray addObjectsFromArray:[self pagesWithString:textString size:CGSizeMake(coreTextView.frame.size.width, coreTextView.frame.size.height) font:currentFont]];
    [mString setString:[textString substringWithRange:NSRangeFromString([pagesArray objectAtIndex:currentPage])]];
    [self updateStatusPercentage];
    statusView.title.text = chapter.name;
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
    if (!menuView.hidden) {
        menuView.hidden = YES;
        return;
    }
    currentPage++;
    if(currentPage >= [pagesArray count])
    {
        currentPage = [pagesArray count] - 1;
        [self nextChapter];
        NSLog(@"no more next!");
        return;
    }
    
    if (bFlipV) {
        [self performTransition:kCATransitionFromTop andType:@"pageCurl"];
    } else
        [self performTransition:kCATransitionFromRight andType:@"pageCurl"];
    
    [self updateContent];
}

- (void)nextChapter
{
    if ([chapter.index integerValue] == [chaptersArray count] - 1) {
        [self displayHUDError:@"" message:@"最后一章"];
    } else {
       [self downloadBookWithIndex:[chapter.index integerValue]+1];
    }
}

- (void)menu
{
    startPointX = NSIntegerMax;
    startPointY = NSIntegerMax;
    menuView.hidden = !menuView.hidden;
}

- (void)previousChapter
{
    if ([chapter.index integerValue] == 0) {
        [self displayHUDError:@"" message:@"此章是第一章"];
    }else {
        [self downloadBookWithIndex:[chapter.index integerValue]-1];
    }
}

- (void)previousPage
{
    if (!menuView.hidden) {
        menuView.hidden = YES;
        return;
    }
    currentPage--;
    if(currentPage < 0)
    {
        currentPage = 0;
        [self previousChapter];
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
    SubscribeViewController *childViewController = [[SubscribeViewController alloc] initWithBookId:book andOnline:YES];
    [self.navigationController pushViewController:childViewController animated:YES];
}

- (void)previousChapterButtonClick
{
    [self previousChapter];
}

- (void)nextChapterButtonClick
{
    [self nextChapter];
}

//订阅和下载
- (void)downloadBookWithIndex:(NSInteger)index
{
    [self displayHUD:@"获取内容中..."];
    Chapter *obj = [chaptersArray objectAtIndex:index];
    if (obj.content!=nil) {
        [textString setString:[obj.content XXSYDecodingWithKey:key]];
        currentPage = 0;
        chapter = obj;
        obj.bRead = [NSNumber numberWithBool:YES];
        [obj persistWithBlock:nil];
        [self updateContent];
        [self hideHUD:YES];
    }else {
        [ServiceManager bookCatalogue:obj.uid andUserid:userid withBlock:^(NSString *content,NSString *result,NSString *code, NSError *error) {
            if (error)
            {
                [self displayHUDError:nil message:NETWORKERROR];
            }
            else
            {
                if (![code isEqualToString:SUCCESS_FLAG])
                {
                    [self chapterSubscribeWithObj:obj];
                }
                else
                {
                    obj.content = content;
                    obj.bRead = [NSNumber numberWithBool:YES];
                    chapter = obj;
                    [obj persistWithBlock:nil];
                    [textString setString:[chapter.content XXSYDecodingWithKey:key]];
                    currentPage = 0;
                    [self updateContent];
                    [self hideHUD:YES];
                }
            }
        }];
    }
}

- (void)chapterSubscribeWithObj:(Chapter *)obj
{
    if (userid!=nil)
    {
        [ServiceManager chapterSubscribe:userid chapter:obj.uid book:book.uid author:book.authorID andPrice:@"0" withBlock:^(NSString *content,NSString *result,NSString *code,NSError *error) {
            if (error)
            {
                [self hideHUD:YES];
            }
            else
            {
                if ([code isEqualToString:SUCCESS_FLAG]) {
                    obj.bBuy = [NSNumber numberWithBool:YES];
                    obj.content = content;
                    obj.bRead = [NSNumber numberWithBool:YES];
                    chapter = obj;
                    [obj persistWithBlock:nil];
                    [textString setString:[chapter.content XXSYDecodingWithKey:key]];
                    currentPage = 0;
                    [self updateContent];
                    [self hideHUD:YES];
                } else {
                    [self displayHUDError:nil message:@"无法下载阅读"];
                }
            }
        }];
    }
    else
    {
        
    }
}

@end
