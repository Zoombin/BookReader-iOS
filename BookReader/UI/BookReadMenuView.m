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
    UIView *fontView;
    UIView *backgroundView;
    NSArray *textcolorNames;
    NSArray *textcolorArray;
    
    UIButton *chaptersListButton;
    UIButton *lastChapterButton;
    UIButton *nextChapterButton;
    UIButton *fontButton;
    UIButton *backgroundSettingButton;
    
    NSMutableArray *bottomViewBtns;
    
    UIImageView *markImageView;
}
@synthesize titleLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        bottomViewBtns = [[NSMutableArray alloc] init];
        textcolorNames = @[@"黑色",@"蓝色",@"棕色",@"绿色",@"红色"];
        textcolorArray = @[UserDefaultTextColorBlack,UserDefaultTextColorBlue,UserDefaultTextColorBrown,UserDefaultTextColorGreen,UserDefaultTextColorRed];
        [self initTopView];
        [self initBottomView];
        [self initFontView];
        [self initBackgroundView];
        UITapGestureRecognizer *tapGestureReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tapGestureReconizer];

    }
    return self;
}

- (void)initTopView
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,40)];
    [topView setAlpha:0.9];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[topView bounds]];
    [imageView setImage:[UIImage imageNamed:@"read_bar_top"]];
    [topView addSubview:imageView];
    [self addSubview:topView];
    
    titleLabel = [UILabel titleLableWithFrame:topView.bounds];
    [titleLabel setText:@"正文"];
    [self addSubview:titleLabel];
    
    static float buttonOffsetX = 10.0;
    static float buttonOffsetY = 4.0;
    
	UIButton *backButton = [UIButton navigationBackButton];
    [backButton setFrame: CGRectMake(10, buttonOffsetY, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    UIButton *addBookMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBookMarkButton setFrame:CGRectMake(self.bounds.size.width-buttonOffsetX-48, buttonOffsetY, 48, 32)];
    [addBookMarkButton setTitle:@"书签" forState:UIControlStateNormal];
    [addBookMarkButton addTarget:self action:@selector(addBookMarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addBookMarkButton];
}

- (void)initBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-50, self.bounds.size.width, 50)];
    [bottomView setAlpha:0.9];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[bottomView bounds]];
    [imageView setImage:[UIImage imageNamed:@"read_bar"]];
    [bottomView addSubview:imageView];
    
    NSInteger BUTTON_WIDTH = 55;
    NSInteger BUTTON_HEIGHT = 40;
    NSInteger BUTTON_NUMBER = 5;
    NSInteger WIDTH = ((self.bounds.size.width)/BUTTON_NUMBER);
    
    CGRect BUTTON_FRAME_ONE =  CGRectMake(0*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect BUTTON_FRAME_TWO =  CGRectMake(1*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect BUTTON_FRAME_THREE = CGRectMake(2*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect BUTTON_FRAME_FOUR = CGRectMake(3*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    CGRect BUTTON_FRAME_FIVE = CGRectMake(4*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    
    NSString *BUTTON_FRAME_ONE_STR =  NSStringFromCGRect(BUTTON_FRAME_ONE);
    NSString *BUTTON_FRAME_TWO_STR =  NSStringFromCGRect(BUTTON_FRAME_TWO);
    NSString *BUTTON_FRAME_THREE_STR = NSStringFromCGRect(BUTTON_FRAME_THREE);
    NSString *BUTTON_FRAME_FOUR_STR = NSStringFromCGRect(BUTTON_FRAME_FOUR);
    NSString *BUTTON_FRAME_FIVE_STR = NSStringFromCGRect(BUTTON_FRAME_FIVE);
    
    NSArray *rectArrays = @[BUTTON_FRAME_ONE_STR,BUTTON_FRAME_TWO_STR,BUTTON_FRAME_THREE_STR,BUTTON_FRAME_FOUR_STR,BUTTON_FRAME_FIVE_STR];
    NSArray *imagesArray = @[@"read_chapterlist", @"read_prechapter", @"read_font", @"read_nextchapter", @"read_background"];
    for (int i = 0; i <[rectArrays count]; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectFromString([rectArrays objectAtIndex:i])];
        [imageView setImage:[UIImage imageNamed:@"read_box"]];
        [bottomView addSubview:imageView];
        
        UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(imageView.frame.origin.x+5, imageView.frame.origin.y+5, 45, 30)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:imagesArray[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
        [bottomViewBtns addObject:button];
    }
    chaptersListButton = bottomViewBtns[0];
    lastChapterButton = bottomViewBtns[1];
    fontButton = bottomViewBtns[2];
    nextChapterButton = bottomViewBtns[3];
    backgroundSettingButton = bottomViewBtns[4];
    [self addSubview:bottomView];
}

- (void) initFontView
{
    NSLog(@"显示FontView");
    fontView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-190, self.bounds.size.width, 150)];
    [fontView setHidden:YES];
    [fontView setAlpha:0.9];
    [fontView setBackgroundColor:[UIColor colorWithRed:99.0/255.0 green:48.0/255.0 blue:20.0/255.0 alpha:1.0]];
    [self addSubview:fontView];
    
	_fontButonMin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_fontButonMin setFrame:CGRectMake(0, 0, fontView.bounds.size.width/2, 30)];
    [_fontButonMin setTitle:@"A-" forState:UIControlStateNormal];
    [fontView addSubview:_fontButonMin];
    
    UIButton *fontButonMax = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fontButonMax setFrame:CGRectMake(fontView.bounds.size.width/2, 0, fontView.bounds.size.width/2, 30)];
    [fontButonMax addTarget:self action:@selector(fontChanged:) forControlEvents:UIControlEventTouchUpInside];
    [fontButonMax setTitle:@"A+" forState:UIControlStateNormal];
    [fontView addSubview:fontButonMax];
    
    UIButton *defaultFontButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [defaultFontButton setFrame:CGRectMake(0, 30, fontView.bounds.size.width, 30)];
    [defaultFontButton addTarget:self action:@selector(systemFontChange) forControlEvents:UIControlEventTouchUpInside];
    [defaultFontButton setTitle:@"系统默认字体" forState:UIControlStateNormal];
    [fontView addSubview:defaultFontButton];
    
    UIButton *foundFontButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [foundFontButton setFrame:CGRectMake(0, 60, fontView.bounds.size.width, 30)];
    [foundFontButton addTarget:self action:@selector(foundFontChange) forControlEvents:UIControlEventTouchUpInside];
    [foundFontButton setTitle:@"方正兰亭黑" forState:UIControlStateNormal];
    [fontView addSubview:foundFontButton];
    
    CGRect frame = CGRectMake(0+fontView.bounds.size.width/[textcolorArray count]*0, 100, fontView.bounds.size.width/[textcolorArray count], 30);
    
    for (int i =0 ; i < [textcolorArray count]; i++) {
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if (i!=0) {
            frame = CGRectMake(CGRectGetMaxX(frame), 100, frame.size.width, frame.size.height);
        }
        [colorButton setFrame:frame];
        [colorButton addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventTouchUpInside];
        [colorButton setTag:i];
        [colorButton setTitle:textcolorNames[i] forState:UIControlStateNormal];
        [fontView addSubview:colorButton];
    }	
}

- (void)hide
{
	self.hidden = YES;
}

-(void)initBackgroundView
{
    NSLog(@"显示BackgroundView");
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-190, self.bounds.size.width, 150)];
    [backgroundView setHidden:YES];
    [backgroundView setAlpha:0.9];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:99.0/255.0 green:48.0/255.0 blue:20.0/255.0 alpha:1.0]];
    [self addSubview:backgroundView];
    
    UIImageView *brightLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 50, 35)];
    [brightLeftImageView setImage:[UIImage imageNamed:@"read_light_reduce"]];
     [backgroundView addSubview:brightLeftImageView];
    
    UIImageView *brightRightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(backgroundView.bounds.size.width-50, 20, 50, 35)];
    [brightRightImageView setImage:[UIImage imageNamed:@"read_light_increase"]];
    [backgroundView addSubview:brightRightImageView];
    
    UISlider *brightSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 20, backgroundView.bounds.size.width-100, 30)];
    [brightSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    if ([BookReaderDefaultsManager objectForKey:UserDefaultKeyBright]) {
       brightSlider.value = [[BookReaderDefaultsManager objectForKey:UserDefaultKeyBright] floatValue];
    } else {
       brightSlider.value = 1;
    }
    [brightSlider setMaximumValue:1];
    [brightSlider setMinimumValue:0.5];
    [backgroundView addSubview:brightSlider];
    
    UIImageView *backgroundColorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 90, 50, 35)];
    [backgroundColorImageView setImage:[UIImage imageNamed:@"read_photo_box"]];
    [backgroundView addSubview:backgroundColorImageView];
    
    UIScrollView *scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 80, backgroundView.bounds.size.width-50, 70)];
    [scrollerView setBackgroundColor:[UIColor clearColor]];
    [scrollerView setContentSize:CGSizeMake(backgroundView.bounds.size.width*4, 70)];
    [backgroundView addSubview:scrollerView];
    
    markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [markImageView setImage:[UIImage imageNamed:@"read_mark"]];
    
    CGRect frame = CGRectMake(0, 0, backgroundView.bounds.size.width/16*3, backgroundView.bounds.size.width/16*3);
    
    for (int i=0; i<16; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i!=0) {
            frame = CGRectMake(CGRectGetMaxX(frame)+20, 0, frame.size.width, frame.size.height);
        }
        [button setFrame:frame];
        [button setTag:i];
        [button.layer setBorderWidth:2];
        if ([[BookReaderDefaultsManager objectForKey:UserDefaultKeyBackground] integerValue] == i) {
            [markImageView setFrame:CGRectMake(button.frame.origin.x + button.frame.size.width - markImageView.frame.size.width, button.frame.origin.y, markImageView.frame.size.width, markImageView.frame.size.height)];
        }
        [button.layer setBorderColor:[UIColor brownColor].CGColor];
        [button setBackgroundColor:[BookReaderDefaultsManager backgroundColorWithIndex:i]];
        [button addTarget:self action:@selector(backgroundChanged:) forControlEvents:UIControlEventTouchUpInside];
        [scrollerView addSubview:button];
    }
    [scrollerView addSubview:markImageView];
}

- (void)backgroundChanged:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [markImageView setFrame:CGRectMake(button.frame.origin.x + button.frame.size.width - markImageView.frame.size.width, button.frame.origin.y, markImageView.frame.size.width, markImageView.frame.size.height)];
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
	[self.delegate fontChanged:[sender.titleLabel.text isEqualToString:@"A-"] ? YES : NO];
}


- (void)systemFontChange
{
    if ([self.delegate respondsToSelector:@selector(systemFont)]) {
        [self.delegate systemFont];
    }
}

- (void)foundFontChange
{
    if ([self.delegate respondsToSelector:@selector(foundFont)]) {
        [self.delegate foundFont];
    }
}

- (void)bottomButtonsPressed:(UIButton *)sender
{
    if (sender == chaptersListButton) {
        if ([self.delegate respondsToSelector:@selector(chaptersButtonClicked)]) {
            [self.delegate performSelector:@selector(chaptersButtonClicked)];
        }
    } else if (sender == lastChapterButton) {
        if ([self.delegate respondsToSelector:@selector(previousChapterButtonClick)]) {
            [self.delegate performSelector:@selector(previousChapterButtonClick)];
        }
    } else if (sender == fontButton) {
        backgroundView.hidden = YES;
        fontView.hidden = !fontView.hidden;
        
    } else if (sender == nextChapterButton) {
        if ([self.delegate respondsToSelector:@selector(nextChapterButtonClick)]) {
            [self.delegate performSelector:@selector(nextChapterButtonClick)];
        }
    } else if (sender == backgroundSettingButton) {
        backgroundView.hidden = !backgroundView.hidden;
        fontView.hidden = YES;
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

@end
