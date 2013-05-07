//
//  ReadViewController.m
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ReadViewController.h"
#import "UserDefaultsManager.h"
#import "AppDelegate.h"
#import "ReadMenuBookMarkViewController.h"
#import "ReadMoreViewController.h"
#import "BookManager.h"
#import "PurchaseManager.h"
#import "BookReader.h"
#import "UIViewController+HUD.h"

@implementation ReadViewController


@synthesize readView;
@synthesize menuView;
@synthesize statusView;
@synthesize readField;
@synthesize currentFontSize;
@synthesize text;
@synthesize textTitle;
@synthesize bFlipV;
@synthesize currentTextSize;
@synthesize newtext;
@synthesize isBuy;


#define FONT_NAME @"STHeitiSC-Light"


- (id)initWithBookUID:(NSString *)uid andShouldMoveToNew:(BOOL)shouldMove andMoveIndex:(NSString *)index andNewText:(NSString *)ntext{
    self = [super init];
    if(self) {
        chapterIndexArray = [[NSMutableArray alloc] init];
        currentBookId = uid;
        shouldReload = shouldMove;
        moveIndexs = index;
        canRead = YES;
        isBuy = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(receiveResult:)
                                                    name:@"receiveResult"
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(failResult)
                                                    name:@"failResult"
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(cancelResult)
                                                    name:@"cancelResult"
                                                  object:nil];
    }
    return  self;
}

- (void)failResult {
    [self.view setUserInteractionEnabled:YES];
}

- (void)cancelResult {
    [self.view setUserInteractionEnabled:YES];
}

-(void) receiveResult:(NSNotification*)notification {
    [self.view setUserInteractionEnabled:YES];
    canRead = YES;
    isBuy = YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置当前字体的默认大小
    currentTextSize = 80;
    currentPage = 0;
    currentFontSize = (int)[[UserDefaultsManager objectForKey:UserDefaultsKeyFontSize] floatValue];
    [self updateFontSize:currentFontSize];
    
    hasAd = NO;
    
    // CGRect readViewRect = {0-8, 20-8, 320+8+8, 440+10};
    CGRect readViewRect = {0-8, 20-8, MAIN_SCREEN.size.width+8+8, MAIN_SCREEN.size.height-30};
    
    readView = [[ReadView alloc] initWithFrame:readViewRect];
    [readView setBackgroundColor:[UIColor clearColor]];
    [readView setTextColor: [UIColor blackColor]];
    [readView setEditable:NO];
    [readView setScrollEnabled:NO];
    [readView setTextAlignment:UITextAlignmentLeft];
    readView.showsHorizontalScrollIndicator = NO;
    readView.showsVerticalScrollIndicator = NO;
    readView.delegate = self;
    [readView setFont:[UIFont fontWithName:FONT_NAME size:currentFontSize]];
    [self.view addSubview:readView];
    
    
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    if([udid isEqualToString:UDID_1]) {
        ;//donothiing, not load adview
    }
    else
        [self loadAdView];
    
    statusView = [[ReadStatusView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 20)];
    [statusView setBackgroundColor:[UIColor clearColor]];
    
    self.textTitle = [[BookManager sharedInstance]getBookNameByBookId:currentBookId];
    
    
    [self.view addSubview:statusView];
    
    statusView.title.text = [NSString stringWithString:textTitle];
    
    //flip mode
    NSString *flipStr = [UserDefaultsManager objectForKey:UserDefaultsKeyFlipMode];
    if([flipStr isEqualToString:UserDefaultsValueFlipModeVertical])
        bFlipV = YES;
    else
        bFlipV = NO;
    
    menuView = [[ReadMenuView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-20)];
    [menuView setDelegate:self];
    menuView.articleTitleLabel.text = [NSString stringWithString:textTitle];
    menuView.articleTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:menuView];
    menuView.hidden = YES;
    
    bFirstAppeared = YES;
    [self loadText];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!menuView.hidden) {
        [self menu];
    }
    [self updateBackgroundColorAndTextColor];
    
    NSString *flipStr = [UserDefaultsManager objectForKey:UserDefaultsKeyFlipMode];
    if([flipStr isEqualToString:UserDefaultsValueFlipModeVertical])
        bFlipV = YES;
    else
        bFlipV = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (bFirstAppeared) {
        NSLog(@"--------开始-----------");
        chapterArray = [[NSMutableArray alloc] initWithArray:[[BookManager sharedInstance]getchaptersByBookId:currentBookId]];
        chapterRealName = [[NSMutableArray alloc] initWithArray:[[BookManager sharedInstance]getchaptersArrayByBookId:currentBookId]];
        
        pagesArray = nil;
        pagesArray = [[NSMutableArray alloc] initWithCapacity:12];
        //[HandleGBString handleGBString:self.text withFontSize:currentFontSize andPages:&pagesArray andGBCode:YES andAD:NO];
        [self calculatePages];
        NSLog(@"--------结束-----------");
    }
    
    bFirstAppeared = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //离开此界面开始保存数据
    NSRange range = NSRangeFromString([pagesArray objectAtIndex:currentPage]);
    NSInteger idx = range.location;
    NSLog(@"after update idx = %d", idx);
    NSString *lastIdx = [NSString stringWithFormat:@"%d",idx];
    [[BookManager sharedInstance]saveValueWithBookId:currentBookId andKey:READ_PERCENT andValue:statusView.percentage.text];
    [[BookManager sharedInstance]saveValueWithBookId:currentBookId andKey:READ_POS_FLAG andValue:lastIdx];
    NSString *lastReadChapter = [NSString stringWithFormat:@"%@",[self getCurrentChapter:lastIdx]];
    if ([lastReadChapter length]>0) {
        [[BookManager sharedInstance]saveValueWithBookId:currentBookId andKey:BEFORE_READ_CHAPTER andValue:lastReadChapter];
    }
    //-------------------

    //TODO: should implement after tabBarVC
    //AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //[delegate.mainViewController reloadBookListTableView];
}

- (void)menu {
    startPointX = NSIntegerMax;
    startPointY = NSIntegerMax;
    menuView.hidden = !menuView.hidden;
}

- (BOOL)isValue:(float)fValue biggerThan:(float)min andSmallerThan:(float)max {
    if (fValue >= min && fValue <= max) {
        return YES;
    }
    return NO;
}

- (void)updateFontSize:(float)newSize {
    float minFontSize = [UserDefaultsValueFontSizeMin floatValue];//15.0
    NSInteger iNewSize = NSIntegerMax;
    for (int i = 0; i < 10; ++i) {//最小字体是15，最大字体是19，分成5个档次15，16，17，18，19
        float min = (minFontSize + 0.5*i);
        if ([self isValue:newSize biggerThan:min andSmallerThan:(min+0.5)]) {
            if (i % 2 == 0) {
                iNewSize = (int)(min);
            }
            else {
                iNewSize = (int)(min + 0.5);
            }
            break;
        }
    }
    currentFontSize = iNewSize;
    if (currentFontSize == 15)
        lengthPerPage = 435-15;
    else if(currentFontSize == 16)
        lengthPerPage = 395-15;
    else if(currentFontSize == 17)
        lengthPerPage = 335-15;
    else if(currentFontSize == 18)
        lengthPerPage = 300-15;
    else if(currentFontSize == 19)
        lengthPerPage = 270-15;
    NSLog(@"after font size! current = %d, lengthPerPage = %d", currentFontSize, lengthPerPage);
}

- (void)reloadPage {
    NSRange range = NSRangeFromString([pagesArray objectAtIndex:currentPage]);
    NSString *rangeStr = [newtext substringWithRange:range];
    NSRange newLineRange = [rangeStr rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    
    if(newLineRange.length > 0 && newLineRange.location == 0 ) {
        [readView setText:[newtext substringWithRange:NSMakeRange(range.location+1, range.length-1)]];
    }
    else {
        [readView setText:[newtext substringWithRange:range]];
    }
    
//    [self getCurrentChapterRealName];
    [self updateStatusPercentage];
    
    if (shouldReload) {
        NSLog(@"reload");
        shouldReload = NO;
        NSString *rangeStr = [self checkhasContainWithChapter:moveIndexs];
        currentPage = [pagesArray indexOfObject:rangeStr];
        NSRange range = NSRangeFromString(rangeStr);
        NSInteger bookmarkIdx = range.location;
        [self gotoIndex:bookmarkIdx];
    }
}

- (NSString *)checkhasContainWithChapter:(NSString *)chapter {
    for (int i=0; i<[pagesArray count]; i++) {
        NSRange range = NSRangeFromString([pagesArray objectAtIndex:i]);
        NSString *tempStr = [text substringWithRange:range];
        if ([tempStr rangeOfString:chapter].location!=NSNotFound) {
            return [pagesArray objectAtIndex:i];
        }
    }
    return nil;
}

//- (void)loadChapterIndexArray {
//    if ([chapterIndexArray count]>0) {
//        [chapterIndexArray removeAllObjects];
//    }
//    NSLog(@"--------开始-----------");
//    int i = 0;
//    while (i<[chapterArray count]) {
//        NSString *mIndex = [chapterArray objectAtIndex:i];
//        NSString *rangeStr = [NSString stringWithFormat:@"%@",[self checkhasContainWithChapter:mIndex]];
//        NSRange range = NSRangeFromString(rangeStr);
//        NSInteger bookmarkIdx = range.location;
//        [chapterIndexArray addObject:[NSNumber numberWithInteger:bookmarkIdx]];
//        i++;
//    }
//    NSLog(@"--------结束-----------");
//}
//
//- (void)getCurrentChapterRealName {
//    NSString *rangeStr = [pagesArray objectAtIndex:currentPage];
//    NSRange range = NSRangeFromString(rangeStr);
//    NSInteger bookmarkIdx = range.location;
//    for (int i = 0; i<[chapterIndexArray count]; i++) {
//        if (i!=[chapterIndexArray count]-1) {
//            NSInteger first = [[chapterIndexArray objectAtIndex:i] integerValue];
//            NSInteger second = [[chapterIndexArray objectAtIndex:i+1] integerValue];
//            if (bookmarkIdx>=first&&bookmarkIdx<=second) {
//                [self checkHasBuy:i];
//                [self.statusView.title setText:[NSString stringWithFormat:@"%@   %@",textTitle,[chapterRealName objectAtIndex:i]]];
//                return;
//            }
//        }else {
//            [self checkHasBuy:i];
//           [self.statusView.title setText:[NSString stringWithFormat:@"%@   %@",textTitle,[chapterRealName objectAtIndex:i]]];
//        }
//    }
//}

- (void)checkHasBuy:(int)i {
    if (i>=19&&isBuy==NO) {
        canRead = NO;
    }else {
        canRead = YES;
    }
}

- (void)nextPage {
    if (canRead==NO&&isBuy==NO) {
        [self.view setUserInteractionEnabled:NO];
        NSInteger bookindex = [[BookManager sharedInstance] getIndex:currentBookId];
        NSString *productId = [NSString stringWithFormat:@"%@",[[PurchaseManager sharedInstance]getProductIdByIndex:bookindex]];
        return;
    }
    currentPage++;
    if(currentPage >= [pagesArray count]) {
        currentPage = [pagesArray count] - 1;
        [self displayHUDError:@"" message:NSLocalizedString(@"finel page", nil)];
        NSLog(@"no more next!");
        return;
    }
    if (bFlipV) {
        [self performTransition:kCATransitionFromTop];
    } else
        [self performTransition:kCATransitionFromRight];
    
    [self reloadPage];
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
        [self performTransition:kCATransitionFromBottom];
    } else
        [self performTransition:kCATransitionFromLeft];
    
    [self reloadPage];
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
        
        if (endPointY >= 480.0f/2) {
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
        
        if(endPointX >= 320.0f/2) {
            [self nextPage];
            return;
        }
        else {
            [self previousPage];
            return;
        }
    }
}


- (void)loadText {
    text = [[NSMutableString alloc] initWithString:[[BookManager sharedInstance]getTextWithBookId:currentBookId]];
    newtext = [[NSMutableString alloc] initWithString:[[BookManager sharedInstance]getTextWithBookId:currentBookId]];
    for (int i = 0;i<[chapterArray count];i++) {
        NSRange range = [self.newtext rangeOfString:[chapterArray objectAtIndex:i]];
        NSString *oldChapter = [chapterArray objectAtIndex:i];
        NSString *newChapter = [chapterRealName objectAtIndex:i];
        NSInteger length = [oldChapter length] - [newChapter length];
        for (int i =0; i<length; i++) {
            newChapter = [@" " stringByAppendingString:newChapter];
        }
        [self.newtext deleteCharactersInRange:range];
        [self.newtext insertString:newChapter atIndex:range.location];
    }
}

- (BOOL)pointInMenuTouchX:(float)x andY:(float)y {
	float pageOffset = currentPageInSpineIndex*readView.bounds.size.width;
    if (x >= pageOffset+MAIN_SCREEN.size.width/3 && x <= pageOffset+MAIN_SCREEN.size.width/3*2 && y >= MAIN_SCREEN.size.height/3 && y <= MAIN_SCREEN.size.height/3*2) {
        return YES;
    }
    return NO;
}

- (void)updateBackgroundColorAndTextColor {
    [self.view setAlpha: [[UserDefaultsManager objectForKey:UserDefaultsKeyBrightness] floatValue]];
    UIColor *currentBackgroundColor = nil;
    UIColor *currentTextColor = nil;
    NSString *currentTextColorStr = nil;
    NSString *backgroundStr = [UserDefaultsManager objectForKey:UserDefaultsKeyBackground];
    if([backgroundStr isEqualToString:UserDefaultsValueBackgroundDay]) {
        currentBackgroundColor = ReadBackgroundColorDay;
        currentTextColor = ReadTextColorDay;
        currentTextColorStr = [NSString stringWithFormat:@"%@", ReadTextColorRGBDayStr];
        [UserDefaultsManager setObject:@"blackColor" forKey:UserDefaultsKeyFontColor];
    }
    else if([backgroundStr isEqualToString:UserDefaultsValueBackgroundNight]) {
        currentBackgroundColor = ReadBackgroundColorNight;
        currentTextColor = ReadTextColorNight;
        [UserDefaultsManager setObject:@"whiteColor" forKey:UserDefaultsKeyFontColor];
        currentTextColorStr = [NSString stringWithFormat:@"%@", ReadTextColorRGBNightStr];
    }
    else if([backgroundStr isEqualToString:UserDefaultsValueBackgroundOld]) {
        currentBackgroundColor = ReadBackgroundColorOld;
        currentTextColor = ReadTextColorOld;
        currentTextColorStr = [NSString stringWithFormat:@"%@", ReadTextColorRGBOldStr];
    }
    else if([backgroundStr isEqualToString:UserDefaultsValueBackgroundSafe]) {
        currentBackgroundColor = ReadBackgroundColorSafe;
        currentTextColor = ReadTextColorSafe;
        currentTextColorStr = [NSString stringWithFormat:@"%@", ReadTextColorRGBSafeStr];
    }
    else if([backgroundStr isEqualToString:UserDefaultsValueBackgroundDream]) {
        currentBackgroundColor = ReadBackgroundColorDream;
        currentTextColor = ReadTextColorDream;
        currentTextColorStr = [NSString stringWithFormat:@"%@", ReadTextColorRGBDreamStr];
    }else {
        NSString *colorStr = nil;
        NSString *backgroundColor = nil;
        colorStr = [UserDefaultsManager objectForKey:UserDefaultsKeyFontColor];
        backgroundColor = [UserDefaultsManager objectForKey:UserDefaultsKeyBackgroundColor];
        SEL textcolorselector = NSSelectorFromString(colorStr);
        SEL backgroundrselector = NSSelectorFromString(backgroundColor);
        currentBackgroundColor = [UIColor performSelector:backgroundrselector];
        currentTextColor = [UIColor performSelector:textcolorselector];
        currentTextColorStr = [NSString stringWithFormat:@"%@",currentTextColor];
    }
    
    if(currentBackgroundColor && currentTextColor && currentTextColorStr) {
        [self.view setBackgroundColor:currentBackgroundColor];
        NSString *textcolorStr = [UserDefaultsManager objectForKey:UserDefaultsKeyFontColor];
        SEL textcolorselector = NSSelectorFromString(textcolorStr);
        currentTextColor = [UIColor performSelector:textcolorselector];
        readView.textColor = currentTextColor;
        statusView.title.textColor = currentTextColor;
        statusView.percentage.textColor = currentTextColor;
    }
}

- (float)readPercentage {
    if (![pagesArray count]) {
        return 0.0;
    }
    float percentage = (float)( (float)(currentPage + 1) / (float)([pagesArray count]) );
    if (currentPage == 0) {
        percentage = 0.0;
    }
    return percentage * 100.0f;
}

//for uitextview
- (void)updateStatusPercentage {
    if (!statusView) {
        return;
    }
    
    statusView.percentage.text = [NSString stringWithFormat:@"%.2f%%", [self readPercentage]];
    if ([pagesArray count]==1) {
        statusView.percentage.text = @"100.00%";
    }
}

- (NSString *)getCurrentChapter:(NSString *)currentIdx {
    //-----------保存看到第几章---------------
    for (int i=0; i<[chapterArray count]; i++) {
        if (i==[chapterArray count]-1) {
            return nil;
        }
        NSString *currentContainTitle = [self checkCurrentTextContainChapterTitle];
        if (![currentContainTitle isEqualToString:@"-1"]) {
            return currentContainTitle;
        }
        NSString *rangeStr1 = [self checkhasContainWithChapter:[chapterArray objectAtIndex:i]];
        NSString *rangeStr2 = [self checkhasContainWithChapter:[chapterArray objectAtIndex:i+1]];
        
        NSRange range1 = NSRangeFromString(rangeStr1);
        NSRange range2 = NSRangeFromString(rangeStr2);
        
        NSInteger bookmarkIdx1 = range1.location;
        NSInteger bookmarkIdx2 = range2.location;
        if ([currentIdx integerValue]>=bookmarkIdx1&&[currentIdx integerValue]<=bookmarkIdx2) {
            return [NSString stringWithFormat:@"%d",i];
        }
    }
    return nil;
}

- (NSString *)checkCurrentTextContainChapterTitle {
    for (int i=0; i<[chapterArray count]; i++) {
        NSString *chapter = [chapterArray objectAtIndex:i];
        NSRange range = NSRangeFromString([pagesArray objectAtIndex:currentPage]);
        NSString *tempStr = [text substringWithRange:range];
        if ([tempStr rangeOfString:chapter].location!=NSNotFound) {
            return [NSString stringWithFormat:@"%d",i];
        }
    }
    return @"-1";
}

- (void)gotoPage:(int)pageIdx {
    if (pageIdx >= [pagesArray count]) {
        return;
    } else {
        currentPage = pageIdx;
        [self reloadPage];
    }
}

- (void)gotoIndex:(int)idx {
    NSLog(@"goto index %d", idx);
    
    int page = NSIntegerMax;
    for (int i = 0; i < [pagesArray count]; ++i) {
        NSRange range = NSRangeFromString([pagesArray objectAtIndex:i]);
        if (idx >= range.location && idx < range.location + range.length) {
            page = i;
            break;
        }
    }
    if (page != NSIntegerMax) {
        [self gotoPage:page];
    }
}

- (void)calculatePages {
    NSString *bookidx = [[[BookManager sharedInstance]getBookInfoById:currentBookId]objectForKey:READ_POS_FLAG];
    
    NSInteger idx = 0;
    idx = [bookidx integerValue];
    //    currentPage = 0;
    //    NSLog(@"calcul idx = %d", idx);
    for(int i = 0; i < [pagesArray count]; ++i) {
        NSRange tmpRange = NSRangeFromString([pagesArray objectAtIndex:i]);
        if(tmpRange.location <= idx && (tmpRange.location + tmpRange.length) > idx) {
            currentPage = i;
        }
    }
    
    if ([[[[BookManager sharedInstance]getBookInfoById:currentBookId] objectForKey:BEFORE_READ_CHAPTER] isEqualToString:[self getCurrentChapter:bookidx]]) {
        shouldReload = NO;
    }
//    [self loadChapterIndexArray];
    NSLog(@"idx = %d and currentPage = %d, totalPage = %d", idx, currentPage, [pagesArray count]);
    [self reloadPage];
}

//翻页动画
-(void)performTransition:(NSString *)transitionType
{
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
	//NSString *subtypes[4] = {kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};
	//int rnd = random() % 4;
    int rnd = 0;
	transition.type = types[rnd];
	if(rnd < 3) // if we didn't pick the fade transition, then we need to set a subtype too
	{
		//transition.subtype = subtypes[random() % 2];
        transition.subtype = transitionType;
	}
	transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
}


#pragma mark - AdWhirl methods and delegate
- (void)loadAdView
{
    AdWhirlView *adView = [AdWhirlView requestAdWhirlViewWithDelegate:self];
    [adView setFrame:CGRectMake(0, MAIN_SCREEN.size.height-50-20, MAIN_SCREEN.size.width, 50)];
	adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:adView];
}

- (NSString *)adWhirlApplicationKey
{
	return ADWHIRL_READING;
}

- (void)adWhirlDidReceiveAd:(AdWhirlView *)adWhirlView
{
    [adWhirlView setFrame:CGRectMake(0, MAIN_SCREEN.size.height-50-20, MAIN_SCREEN.size.width, 50)];
    CGRect readViewRect = {0-8, 20-8, MAIN_SCREEN.size.width+8+8, MAIN_SCREEN.size.height-80};
    [self.readView setFrame:readViewRect];
    if (hasAd!=YES) {
        hasAd = YES;
        pagesArray = nil;
        pagesArray = [[NSMutableArray alloc] initWithCapacity:12];
        //[HandleGBString handleGBString:self.text withFontSize:currentFontSize andPages:&pagesArray andGBCode:YES andAD:hasAd];
        [self reloadPage];
    }
}

- (void)adWhirlDidFailToReceiveAd:(AdWhirlView *)adWhirlView usingBackup:(BOOL)yesOrNo
{
    NSLog(@"获取失败");
    hasAd = NO;
}

- (UIViewController *)viewControllerForPresentingModalView
{
	return self;
}


#pragma mark - ReadMenuViewDelegate methods

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addBookMarkButtonPressed
{
    if (![pagesArray count]) {
        return;
    }
    NSString *rangeStr = [pagesArray objectAtIndex:currentPage];
    NSRange range = NSRangeFromString(rangeStr);
    NSInteger bookmarkIdx = range.location;
    NSRange bookMarkRange = {bookmarkIdx, 30};
    
    if (![[BookManager sharedInstance]checkHasExistWithBookId:currentBookId andBookIdx:[NSString stringWithFormat:@"%d",bookmarkIdx]]) {
        [[BookManager sharedInstance]saveBookMarkWithBookId:currentBookId
                                                 andContext:[NSString stringWithString:[text substringWithRange:bookMarkRange]]
                                             andBookMarkIdx:[NSString stringWithFormat:@"%d",bookmarkIdx]
                                      andBookMarkPercentage:[NSString stringWithFormat:@"%f",[self readPercentage]]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add BookMark Success", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Add BookMark failed", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)brightnessChanging:(NSNumber *)value
{
    self.view.alpha = [value floatValue];
    [UserDefaultsManager setObject:[NSNumber numberWithFloat:self.view.alpha] forKey:UserDefaultsKeyBrightness];
}

- (void)modeButtonPressed
{
    [self updateBackgroundColorAndTextColor];
}

- (void)fontSizeChanged:(NSNumber *)value
{
    [self updateFontSize:[value floatValue]];
    [UserDefaultsManager setObject:[NSNumber numberWithFloat:(float)currentFontSize] forKey:UserDefaultsKeyFontSize];
    pagesArray = nil;
    pagesArray = [[NSMutableArray alloc] initWithCapacity:12];
    //[HandleGBString handleGBString:self.text withFontSize:currentFontSize andPages:&pagesArray andGBCode:YES andAD:hasAd];
    [self calculatePages];
    [self reloadPage];
    [readView setFont:[UIFont fontWithName:FONT_NAME size:currentFontSize]];
}

- (void)bookmarkButtonPressed
{
    ReadMenuBookMarkViewController *bookMarkViewController = [[ReadMenuBookMarkViewController alloc] initBookWithUID:currentBookId andPageArray:pagesArray andText:text];
    bookMarkViewController.readViewController = self;
    [self presentModalViewController:bookMarkViewController animated:YES];
}

- (void)moreButtonPressed
{
    ReadMoreViewController *moreViewController = [[ReadMoreViewController alloc] init];
    [self.navigationController pushViewController:moreViewController animated:YES];
}


@end
