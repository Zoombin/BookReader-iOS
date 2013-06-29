//
//  BookReadMenuView.m
//  BookReader
//
//  Created by 颜超 on 13-4-19.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookReadMenuView.h"
#import <QuartzCore/QuartzCore.h>
#import "BookReaderDefaultsManager.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"


@implementation BookReadMenuView {
    UIView *topView;
    UIView *fontView;//字体
    UIView *backgroundView;//背景色
    UIView *brightView;//亮度
    NSArray *textcolorArray;
    
    UIButton *chaptersListButton;
    UIButton *shareButton;
    UIButton *commitButton;
    UIButton *horizontalButton;
    UIButton *brightButton;
    UIButton *backgroundButton;
    UIButton *fontSetButton;
    UIButton *resetButton;
    
    UIButton *fontButton;
    UIButton *backgroundSettingButton;
    
    UIButton *defaultFontButton;
    UIButton *foundFontButton;
    
    NSMutableArray *bottomViewBtns;
    
    UIImageView *markImageView;
    UIImageView *textColorMarkImageView;
    
    UIPageControl *pageControl;
    
    UIView *bottomView;
}
@synthesize titleLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bottomViewBtns = [[NSMutableArray alloc] init];
        textcolorArray = @[UserDefaultTextColorBlack,UserDefaultTextColorBlue,UserDefaultTextColorBrown,UserDefaultTextColorGreen,UserDefaultTextColorWhite];
        [self initTopView];
        [self initBottomView];
        [self initFontView];
        [self initBackgroundView];
        [self initBrightView];
        UITapGestureRecognizer *tapGestureReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tapGestureReconizer];
        
    }
    return self;
}

- (void)initTopView
{
     topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,40)];
//    [topView setAlpha:0.7];
    [topView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]];
    [self addSubview:topView];
    
    titleLabel = [UILabel titleLableWithFrame:topView.bounds];
//    [titleLabel setText:@"正文"];
    [self addSubview:titleLabel];
    
    static float buttonOffsetX = 10.0;
    static float buttonOffsetY = 3.0;
    
	UIButton *backButton = [UIButton navigationBackButton];
    [backButton setFrame: CGRectMake(10, buttonOffsetY, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_backbtn"] forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [topView addSubview:backButton];
    
    UIButton *addBookMarkButton = [UIButton addButtonWithFrame:CGRectMake(self.bounds.size.width-buttonOffsetX-40, buttonOffsetY, 40, 35) andStyle:BookReaderButtonStyleNormal];
    [addBookMarkButton setBackgroundImage:[UIImage imageNamed:@"read_bookmark"] forState:UIControlStateNormal];
    [addBookMarkButton addTarget:self action:@selector(addBookMarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addBookMarkButton];
    
    UIButton *nextChapterButton = [UIButton addButtonWithFrame:CGRectMake(CGRectGetMidX(topView.bounds)+20, buttonOffsetY, 48, 32) andStyle:BookReaderButtonStyleNormal];
    [nextChapterButton setBackgroundImage:[UIImage imageNamed:@"read_next"] forState:UIControlStateNormal];
    [nextChapterButton addTarget:self action:@selector(nextChapter) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:nextChapterButton];
    
    UIButton *lastChapterButton = [UIButton addButtonWithFrame:CGRectMake(CGRectGetMidX(topView.bounds)-68, buttonOffsetY, 48, 32) andStyle:BookReaderButtonStyleNormal];
    [lastChapterButton setBackgroundImage:[UIImage imageNamed:@"read_last"] forState:UIControlStateNormal];
    [lastChapterButton addTarget:self action:@selector(preChapter) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:lastChapterButton];
}

- (void)nextChapter
{
    if ([self.delegate respondsToSelector:@selector(nextChapterButtonClick)]) {
        [self.delegate nextChapterButtonClick];
    }
}

- (void)preChapter
{
    if ([self.delegate respondsToSelector:@selector(previousChapterButtonClick)]) {
        [self.delegate previousChapterButtonClick];
    }
}

- (void)messageShare
{
    if ([self.delegate respondsToSelector:@selector(shareButtonClicked)]) {
        [self.delegate shareButtonClicked];
    }
}

- (void)initBottomView
{
     bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-150, self.bounds.size.width, 150)];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]];
    
    NSInteger BUTTON_WIDTH = bottomView.frame.size.width/4;
    NSInteger BUTTON_HEIGHT = bottomView.frame.size.height/2;
    NSArray *imageNames = @[@"read_chapterlist", @"read_recommend", @"read_commit", @"read_hor", @"read_bright", @"read_font", @"read_background", @"read_reset"];
    NSArray *buttonNames = @[@"目录.书签", @"推荐", @"评论", @"横屏", @"亮度调节", @"字体调整", @"阅读背景", @"恢复默认"];
    int k = 0;
    for (int i = 0; i < 8; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(k * BUTTON_WIDTH, 0 +  i < 4 ? 0 : BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 20, 10);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -30, 5, 10);
        [button.layer setBorderColor:[UIColor blackColor].CGColor];
        [button.layer setBorderWidth:0.5];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        [button addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        [bottomViewBtns addObject:button];
        k ++;
        if (i==3) {
            k = 0;
        }
    }
    chaptersListButton = bottomViewBtns[0];
    shareButton = bottomViewBtns[1];
    commitButton = bottomViewBtns[2];
    horizontalButton = bottomViewBtns[3];
    brightButton = bottomViewBtns[4];
    fontSetButton = bottomViewBtns[5];
    backgroundButton = bottomViewBtns[6];
    resetButton = bottomViewBtns[7];
    [self addSubview:bottomView];
}

- (void) initFontView
{
    fontView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-150, self.bounds.size.width, 150)];
    [fontView setHidden:YES];
    [fontView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]];
    [self addSubview:fontView];

    UILabel *setFontSize = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fontView.frame.size.width, 25)];
    [setFontSize setText:@"\t\t调整字号"];
    [setFontSize setTextColor:[UIColor grayColor]];
    [setFontSize setBackgroundColor:[UIColor blackColor]];
    [fontView addSubview:setFontSize];
    
    UILabel *setFont = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(fontView.bounds), fontView.frame.size.width, 25)];
    [setFont setText:@"\t\t选择字体"];
    [setFont setTextColor:[UIColor grayColor]];
    [setFont setBackgroundColor:[UIColor blackColor]];
    [fontView addSubview:setFont];
    
	_fontButonMin = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fontButonMin setFrame:CGRectMake(CGRectGetMidX(fontView.bounds)-120, CGRectGetMaxY(setFontSize.bounds)+10, 120, 30)];
    [_fontButonMin addTarget:self action:@selector(fontChanged:) forControlEvents:UIControlEventTouchUpInside];

    [_fontButonMin setImage:[UIImage imageNamed:@"read_fontsize_reduce"] forState:UIControlStateNormal];
    [_fontButonMin setTitle:@"T-" forState:UIControlStateNormal];
    [fontView addSubview:_fontButonMin];
    
    UIButton *fontButonMax = [UIButton buttonWithType:UIButtonTypeCustom];
    [fontButonMax setFrame:CGRectMake(CGRectGetMidX(fontView.bounds), CGRectGetMaxY(setFontSize.bounds)+10, 120, 30)];
    [fontButonMax setImage:[UIImage imageNamed:@"read_fontsize_add"] forState:UIControlStateNormal];
    [fontButonMax addTarget:self action:@selector(fontChanged:) forControlEvents:UIControlEventTouchUpInside];
    [fontButonMax setTitle:@"T+" forState:UIControlStateNormal];
    [fontView addSubview:fontButonMax];
    
    defaultFontButton = [UIButton fontButton:CGRectMake(0, CGRectGetMaxY(setFont.frame), fontView.bounds.size.width/2, 25)];
    [defaultFontButton addTarget:self action:@selector(systemFontChange) forControlEvents:UIControlEventTouchUpInside];
    [defaultFontButton setTitle:@"系统字体" forState:UIControlStateNormal];
    [fontView addSubview:defaultFontButton];
    
    foundFontButton = [UIButton fontButton:CGRectMake(0, CGRectGetMaxY(defaultFontButton.frame), fontView.bounds.size.width/2, 25)];
    [foundFontButton addTarget:self action:@selector(foundFontChange) forControlEvents:UIControlEventTouchUpInside];
    [foundFontButton setTitle:@"方正兰亭黑" forState:UIControlStateNormal];
    [fontView addSubview:foundFontButton];
    
    markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(foundFontButton.frame)+80, foundFontButton.frame.origin.y, 20, 20)];
    [markImageView setImage:[UIImage imageNamed:@"read_fontmark_select"]];
    [fontView addSubview:markImageView];
    
    if ([[BookReaderDefaultsManager objectForKey:UserDefaultKeyFontName] isEqualToString:UserDefaultFoundFont]) {
        [markImageView setFrame:CGRectMake(CGRectGetMaxX(foundFontButton.frame)+80, foundFontButton.frame.origin.y, 20, 20)];
        [foundFontButton setEnabled:NO];
    } else {
        [markImageView setFrame:CGRectMake(CGRectGetMaxX(defaultFontButton.frame)+80, defaultFontButton.frame.origin.y, 20, 20)];
        [defaultFontButton setEnabled:NO];
    }
}

- (void)hide
{
	self.hidden = YES;
    [self hidenAllMenu];
}

- (void)initBrightView
{
    brightView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-80, self.bounds.size.width, 80)];
    [brightView setHidden:YES];
    [brightView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]];
    [self addSubview:brightView];
    
    UISlider *brightSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 22, backgroundView.bounds.size.width-100, 30)];
    [brightSlider setMaximumTrackTintColor:[UIColor colorWithRed:176.0/255.0 green:131.0/255.0 blue:107.0/255.0 alpha:1.0]];
    [brightSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [brightSlider setThumbTintColor:[UIColor whiteColor]];
    [brightSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyBright]) {
        brightSlider.value = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyBright] floatValue];
    } else {
        brightSlider.value = 1;
    }
    [brightSlider setMaximumValue:1];
    [brightSlider setMinimumValue:0];
    [brightView addSubview:brightSlider];
    
    UIImageView *brightLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(brightSlider.frame) - 32 - 10, 20, 32, 35)];
    [brightLeftImageView setImage:[UIImage imageNamed:@"read_light_reduce"]];
    [brightView addSubview:brightLeftImageView];
    
    UIImageView *brightRightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(brightSlider.frame) + 10, 20, 32, 35)];
    [brightRightImageView setImage:[UIImage imageNamed:@"read_light_increase"]];
    [brightView addSubview:brightRightImageView];
}

- (void)initBackgroundView
{
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-150, self.bounds.size.width, 150)];
    [backgroundView setHidden:YES];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]];
    [self addSubview:backgroundView];
    
    CGFloat offSetX = 20;
    CGFloat offSetY = 20;
    CGFloat width = (backgroundView.frame.size.width - (5 * offSetX))/4;
    CGFloat height = width;
    CGRect frame = CGRectMake(offSetX, 10, width, height);
    
    for (int i=0; i<8; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i%4!=0) {
            frame = CGRectMake(CGRectGetMaxX(frame)+offSetX, frame.origin.y, width, height);
        }
        if (i%4==0&&i!=0) {
            frame = CGRectMake(offSetX, CGRectGetMaxY(frame)+offSetY, width, height);
        }
        [button setFrame:frame];
        [button setTag:i];
        [button setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:i]];
        [button addTarget:self action:@selector(backgroundChanged:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:button];
    }
}

- (void)backgroundChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(backgroundColorChanged:)]) {
        [self.delegate backgroundColorChanged:[sender tag]];
    }
}

- (void)sliderValueChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(brightChanged:)]) {
        [self.delegate brightChanged:sender];
    }
}

- (void)colorChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeTextColor:)]) {
        [self.delegate changeTextColor:textcolorArray[[sender tag]]];
    }
}

- (void)fontChanged:(UIButton *)sender
{
	[self.delegate fontChanged:[sender.titleLabel.text isEqualToString:@"T-"]];
}


- (void)systemFontChange
{
    [markImageView setFrame:CGRectMake(CGRectGetMaxX(defaultFontButton.frame)+80, defaultFontButton.frame.origin.y, 20, 20)];
    [defaultFontButton setEnabled:NO];
    [foundFontButton setEnabled:YES];
    if ([self.delegate respondsToSelector:@selector(systemFont)]) {
        [self.delegate systemFont];
    }
}

- (void)foundFontChange
{
    [markImageView setFrame:CGRectMake(CGRectGetMaxX(foundFontButton.frame)+80, foundFontButton.frame.origin.y, 20, 20)];
    [defaultFontButton setEnabled:YES];
    [foundFontButton setEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(foundFont)]) {
        [self.delegate foundFont];
    }
}

- (void)bottomButtonsPressed:(UIButton *)sender
{
    bottomView.hidden = YES;
    topView.hidden = YES;
    if (sender == chaptersListButton) {
        if ([self.delegate respondsToSelector:@selector(chaptersButtonClicked)]) {
            [self.delegate performSelector:@selector(chaptersButtonClicked)];
        }
    } else if (sender == shareButton) {
        [self messageShare];
    } else if (sender == commitButton) {
        if ([self.delegate respondsToSelector:@selector(commitButtonClicked)]) {
            [self.delegate performSelector:@selector(commitButtonClicked)];
        }
    } else if (sender == horizontalButton) {
        if ([self.delegate respondsToSelector:@selector(horizontalButtonClicked)]) {
            [self.delegate performSelector:@selector(horizontalButtonClicked)];
        }
    } else if (sender == brightButton) {
        backgroundView.hidden = YES;
        fontView.hidden = YES;
        brightView.hidden = NO;
    } else if (sender == fontSetButton) {
        fontView.hidden = NO;
        brightView.hidden = YES;
        backgroundView.hidden = YES;
    } else if (sender == backgroundButton) {
        backgroundView.hidden = NO;
        fontView.hidden = YES;
        brightView.hidden = YES;
    } else if (sender == resetButton) {
        if ([self.delegate respondsToSelector:@selector(resetButtonClicked)]) {
            [self.delegate performSelector:@selector(resetButtonClicked)];
        }
    }
}

- (void)backButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(backButtonPressed)]) {
        [self.delegate performSelector:@selector(backButtonPressed)];
    }
}


- (void)addBookMarkButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addBookMarkButtonPressed)]) {
        [self.delegate performSelector:@selector(addBookMarkButtonPressed)];
    }
}

- (void)hidenAllMenu
{
    bottomView.hidden = NO;
    topView.hidden = NO;
    backgroundView.hidden = YES;
    fontView.hidden = YES;
    brightView.hidden = YES;
}

@end
