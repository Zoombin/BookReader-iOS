//
//  BookReadMenuView.m
//  BookReader
//
//  Created by ZoomBin on 13-4-19.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BookReadMenuView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+BookReader.h"
#import "AppDelegate.h"


@implementation BookReadMenuView {
    UIView *topView;
    UIView *fontView;//字体
    UIView *backgroundView;//背景色
    UIView *brightView;//亮度
    UIView *navigationView;//导航
    
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
    UIButton *northFontButton;
    UISlider *brightSlider;
    
    NSMutableArray *bottomViewBtns;
    NSMutableArray *backgroundBtns;
    
    UIImageView *markImageViewOne;
    UIImageView *markImageViewTwo;
    UIImageView *markImageViewSelect;
    
    UIPageControl *pageControl;
    
    UIView *bottomView;
    UITapGestureRecognizer *tapGestureReconizer;
    CGRect tapRect;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bottomViewBtns = [[NSMutableArray alloc] init];
        backgroundBtns = [[NSMutableArray alloc] init];
        [self initTopView];
        [self initBottomView];
        [self initFontView];
        [self initBackgroundView];
        [self initBrightView];
        [self initNavigationView];
        tapRect = CGRectMake(0, CGRectGetMaxY(topView.frame), self.bounds.size.width, CGRectGetMinY(bottomView.frame) - topView.frame.size.height);
         tapGestureReconizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tapGestureReconizer];
        
    }
    return self;
}

- (void)initTopView
{
	topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    [topView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6]];
    [topView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:topView];
    
    _titleLabel = [UILabel titleLableWithFrame:topView.bounds];
    [self addSubview:_titleLabel];
    
    static float buttonOffsetX = 10.0;
    static float buttonOffsetY = 0.0;
    
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame: CGRectMake(10, buttonOffsetY, 54, 40)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"read_backbtn"] forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [topView addSubview:backButton];
    
    UIButton *addBookMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBookMarkButton setFrame:CGRectMake(self.frame.size.width-buttonOffsetX-54, buttonOffsetY, 54, 40)];
    [addBookMarkButton setImage:[UIImage imageNamed:@"read_bookmark"] forState:UIControlStateNormal];
    [addBookMarkButton addTarget:self action:@selector(addBookMarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [addBookMarkButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [topView addSubview:addBookMarkButton];
    
    UIButton *nextChapterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextChapterButton setFrame:CGRectMake(CGRectGetMidX(topView.bounds)+20, buttonOffsetY, 48, 40)];
    [nextChapterButton setImage:[UIImage imageNamed:@"read_next"] forState:UIControlStateNormal];
    [nextChapterButton addTarget:self action:@selector(nextChapter) forControlEvents:UIControlEventTouchUpInside];
    [nextChapterButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [topView addSubview:nextChapterButton];
    
    UIButton *lastChapterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lastChapterButton setFrame:CGRectMake(CGRectGetMidX(topView.bounds)-68, buttonOffsetY, 48, 40)];
    [lastChapterButton setImage:[UIImage imageNamed:@"read_last"] forState:UIControlStateNormal];
    [lastChapterButton addTarget:self action:@selector(preChapter) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:lastChapterButton];
}

- (void)nextChapter
{
	if ([_delegate respondsToSelector:@selector(gotoNextChapter)]) {
		[_delegate gotoNextChapter];
	}
}

- (void)preChapter
{
	if ([_delegate respondsToSelector:@selector(gotoPreviousChapter)]) {
		[_delegate gotoPreviousChapter];
	}
}

- (void)messageShare
{
	if ([_delegate respondsToSelector:@selector(shareButtonClicked)]) {
		[_delegate shareButtonClicked];
	}
}

- (void)initBottomView
{
	bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-150, self.bounds.size.width, 150)];
    [bottomView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6]];
    
    NSInteger BUTTON_WIDTH = bottomView.frame.size.width/4;
    NSInteger BUTTON_HEIGHT = bottomView.frame.size.height/2;
    int k = 0;
    CGRect frame = CGRectMake(k * BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    chaptersListButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"目录.书签"];
    [chaptersListButton setImage:[UIImage imageNamed:@"read_chapterlist"] forState:UIControlStateNormal];
    [chaptersListButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:chaptersListButton];
    [bottomViewBtns addObject:chaptersListButton];
    
    k++;
	frame = CGRectMake(k * BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    shareButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"推荐"];
    [shareButton setImage:[UIImage imageNamed:@"read_recommend"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:shareButton];
    [bottomViewBtns addObject:shareButton];
    
    k ++;
     frame = CGRectMake(k * BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    commitButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"评论"];
    [commitButton setImage:[UIImage imageNamed:@"read_commit"] forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:commitButton];
    [bottomViewBtns addObject:commitButton];
    
    k ++;
    frame = CGRectMake(k * BUTTON_WIDTH, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    resetButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"导航"];
    [resetButton setImage:[UIImage imageNamed:@"read_navigation"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:resetButton];
    [bottomViewBtns addObject:resetButton];
    
    k = 0;
     frame = CGRectMake(k * BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
    brightButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"亮度调节"];
    [brightButton setImage:[UIImage imageNamed:@"read_bright"] forState:UIControlStateNormal];
    [brightButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:brightButton];
    [bottomViewBtns addObject:brightButton];
    
    k ++;
      frame = CGRectMake(k * BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
    backgroundButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"阅读背景"];
    [backgroundButton setImage:[UIImage imageNamed:@"read_background"] forState:UIControlStateNormal];
    [backgroundButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backgroundButton];
    [bottomViewBtns addObject:backgroundButton];
    
    k ++;
     frame = CGRectMake(k * BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
     fontSetButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"字体调节"];
    [fontSetButton setImage:[UIImage imageNamed:@"read_font"] forState:UIControlStateNormal];
    [fontSetButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:fontSetButton];
    [bottomViewBtns addObject:fontSetButton];
    
    k ++;
     frame = CGRectMake(k * BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT);
    horizontalButton = [UIButton bookMenuButtonWithFrame:frame andTitle:@"横屏"];
    [horizontalButton setImage:[UIImage imageNamed:@"read_hor"] forState:UIControlStateNormal];
    [horizontalButton addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:horizontalButton];
    [bottomViewBtns addObject:horizontalButton];
   
    [self addSubview:bottomView];
}

- (void) initFontView
{
    fontView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-200, self.bounds.size.width, 200)];
    [fontView setHidden:YES];
    [fontView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    [fontView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6]];
    [self addSubview:fontView];

    UILabel *setFontSize = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fontView.frame.size.width, 25)];
    [setFontSize setText:@"\t\t调整字号"];
    [setFontSize setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [setFontSize setTextColor:[UIColor grayColor]];
    [setFontSize setFont:[UIFont systemFontOfSize:14]];
    [setFontSize setBackgroundColor:[UIColor blackColor]];
    [fontView addSubview:setFontSize];
    
    UILabel *setFont = [[UILabel alloc] initWithFrame:CGRectMake(0, fontView.bounds.size.height/3, fontView.frame.size.width, 25)];
    [setFont setText:@"\t\t选择字体"];
    [setFont setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [setFont setFont:[UIFont systemFontOfSize:14]];
    [setFont setTextColor:[UIColor grayColor]];
    [setFont setBackgroundColor:[UIColor blackColor]];
    [fontView addSubview:setFont];
    
	_fontButonMin = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fontButonMin setFrame:CGRectMake(CGRectGetMidX(fontView.bounds)-120, CGRectGetMaxY(setFontSize.bounds) + 7, 120, 30)];
    [_fontButonMin addTarget:self action:@selector(fontChanged:) forControlEvents:UIControlEventTouchUpInside];
    [_fontButonMin setBackgroundImage:[UIImage imageNamed:@"read_fontsize_reduce"] forState:UIControlStateNormal];
    [_fontButonMin setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [_fontButonMin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_fontButonMin.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [_fontButonMin setTitle:@"T-" forState:UIControlStateNormal];
    [fontView addSubview:_fontButonMin];
    
    UIButton *fontButonMax = [UIButton buttonWithType:UIButtonTypeCustom];
    [fontButonMax setFrame:CGRectMake(CGRectGetMidX(fontView.bounds), CGRectGetMaxY(setFontSize.bounds) + 7, 120, 30)];
    [fontButonMax setBackgroundImage:[UIImage imageNamed:@"read_fontsize_add"] forState:UIControlStateNormal];
    [fontButonMax addTarget:self action:@selector(fontChanged:) forControlEvents:UIControlEventTouchUpInside];
    [fontButonMax setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [fontButonMax setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fontButonMax.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [fontButonMax setTitle:@"T+" forState:UIControlStateNormal];
    [fontView addSubview:fontButonMax];
    
    defaultFontButton = [UIButton fontButton:CGRectMake(0, CGRectGetMaxY(setFont.frame), fontView.bounds.size.width, 37.5)];
    [defaultFontButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [defaultFontButton addTarget:self action:@selector(systemFontChange) forControlEvents:UIControlEventTouchUpInside];
    [defaultFontButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin];
    [defaultFontButton setContentEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [defaultFontButton setTitle:@"系统字体" forState:UIControlStateNormal];
    [fontView addSubview:defaultFontButton];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(defaultFontButton.frame), CGRectGetMaxY(defaultFontButton.frame) - 1, defaultFontButton.frame.size.width, 1)];
    [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [line setBackgroundColor:[UIColor blackColor]];
    [fontView addSubview:line];
    
    foundFontButton = [UIButton fontButton:CGRectMake(0, CGRectGetMaxY(defaultFontButton.frame), fontView.bounds.size.width, 37.5)];
    [foundFontButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [foundFontButton addTarget:self action:@selector(foundFontChange) forControlEvents:UIControlEventTouchUpInside];
    [foundFontButton setContentEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [foundFontButton setTitle:@"方正兰亭黑" forState:UIControlStateNormal];
    [foundFontButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [fontView addSubview:foundFontButton];
    
    UIView *secondLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(foundFontButton.frame), CGRectGetMaxY(foundFontButton.frame) - 1, foundFontButton.frame.size.width, 1)];
    [secondLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [secondLine setBackgroundColor:[UIColor blackColor]];
    [fontView addSubview:secondLine];
    
     northFontButton = [UIButton fontButton:CGRectMake(0, CGRectGetMaxY(foundFontButton.frame), fontView.bounds.size.width, 37.5)];
    [northFontButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [northFontButton addTarget:self action:@selector(northFontChange) forControlEvents:UIControlEventTouchUpInside];
    [northFontButton setContentEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [northFontButton setTitle:@"方正北魏楷书" forState:UIControlStateNormal];
    [northFontButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth];
    [fontView addSubview:northFontButton];
    
    markImageViewOne = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, foundFontButton.frame.origin.y + 8, 20, 20)];
    [markImageViewOne setImage:[UIImage imageNamed:@"read_fontmark"]];
    [markImageViewOne setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [fontView addSubview:markImageViewOne];
    
    markImageViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, foundFontButton.frame.origin.y + 8, 20, 20)];
    [markImageViewTwo setImage:[UIImage imageNamed:@"read_fontmark"]];
    [markImageViewTwo setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [fontView addSubview:markImageViewTwo];
    
    markImageViewSelect = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, defaultFontButton.frame.origin.y + 8, 20, 20)];
    [markImageViewSelect setImage:[UIImage imageNamed:@"read_fontmark_select"]];
    [markImageViewSelect setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [fontView addSubview:markImageViewSelect];
    
    [self changePositionWithFontName:[NSUserDefaults brObjectForKey:UserDefaultKeyFontName]];
}

- (void)changePositionWithFontName:(NSString *)fontName
{
    [defaultFontButton setEnabled:YES];
    [foundFontButton setEnabled:YES];
    [northFontButton setEnabled:YES];
    if ([fontName isEqualToString:UserDefaultFoundFont]) {
        [markImageViewSelect setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, foundFontButton.frame.origin.y + 8, 20, 20)];
        [markImageViewOne setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, defaultFontButton.frame.origin.y + 8, 20, 20)];
        [markImageViewTwo setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, northFontButton.frame.origin.y + 8, 20, 20)];
        [foundFontButton setEnabled:NO];
    } else if([fontName isEqualToString:UserDefaultSystemFont]){
        [markImageViewSelect setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, defaultFontButton.frame.origin.y + 8, 20, 20)];
        [markImageViewOne setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, foundFontButton.frame.origin.y + 8, 20, 20)];
        [markImageViewTwo setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, northFontButton.frame.origin.y + 8, 20, 20)];
        [defaultFontButton setEnabled:NO];
    } else {
        [markImageViewSelect setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, northFontButton.frame.origin.y + 8, 20, 20)];
        [markImageViewOne setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, defaultFontButton.frame.origin.y + 8, 20, 20)];
        [markImageViewTwo setFrame:CGRectMake(CGRectGetMaxX(self.frame) - 50, foundFontButton.frame.origin.y + 8, 20, 20)];
        [northFontButton setEnabled:NO];
    }
}

- (void)hide
{
    CGPoint endPoint = [tapGestureReconizer locationInView:self];
    if (CGRectContainsPoint(tapRect, endPoint)) {
        self.hidden = YES;
        [self hidenAllMenu];
        tapRect = CGRectMake(0, CGRectGetMaxY(topView.frame), self.bounds.size.width, CGRectGetMinY(bottomView.frame) - topView.frame.size.height);
    }
}

- (void)initBrightView
{
    brightView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-80, self.bounds.size.width, 80)];
    [brightView setHidden:YES];
    [brightView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [brightView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6]];
    [self addSubview:brightView];
    
     brightSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 22, backgroundView.bounds.size.width-100, 30)];
    [brightSlider setMaximumTrackTintColor:[UIColor colorWithRed:176.0/255.0 green:131.0/255.0 blue:107.0/255.0 alpha:1.0]];
    [brightSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [brightSlider setThumbTintColor:[UIColor whiteColor]];
    [brightSlider setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [brightSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    if ([NSUserDefaults brObjectForKey:UserDefaultKeyBright]) {
        brightSlider.value = [[NSUserDefaults brObjectForKey:UserDefaultKeyBright] floatValue];
    } else {
        brightSlider.value = 1;
    }
    [brightSlider setMaximumValue:1];
    [brightSlider setMinimumValue:0.5];
    [brightView addSubview:brightSlider];
    
    UIImageView *brightLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(brightSlider.frame) - 32 - 10, 20, 32, 35)];
    [brightLeftImageView setImage:[UIImage imageNamed:@"read_light_reduce"]];
    [brightView addSubview:brightLeftImageView];
    
    UIImageView *brightRightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(brightSlider.frame) + 10, 20, 32, 35)];
    [brightRightImageView setImage:[UIImage imageNamed:@"read_light_increase"]];
    [brightRightImageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [brightView addSubview:brightRightImageView];
}

- (void)initBackgroundView
{
    float screenWidth = self.bounds.size.width;
    float screenHeight = self.bounds.size.height;
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - (screenWidth > 320 ? 2.2 : 1) * 200, screenWidth, (screenWidth > 320 ? 2.2 : 1) * 200)];
    [backgroundView setHidden:YES];
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6]];
    [self addSubview:backgroundView];
    
    CGFloat offSetX = 20;
    CGFloat offSetY = 20;
    CGFloat width = (backgroundView.frame.size.width - (5 * offSetX))/4;
    CGFloat height = width+20;
    CGRect frame = CGRectMake(offSetX, 20, width, height);
    
    NSArray *names = @[@"羊皮纸", @"水墨江南", @"护眼模式", @"华灯初上", @"粉红回忆", @"白色磨砂", @"咖啡时光", @"天空之城"];
    
    for (int i=0; i<8; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i%4!=0) {
            frame = CGRectMake(CGRectGetMaxX(frame)+offSetX, frame.origin.y, width, height);
        }
        if (i%4==0&&i!=0) {
            frame = CGRectMake(offSetX, CGRectGetMaxY(frame)+offSetY, width, height);
        }
        [button.layer setCornerRadius:5];
        [button.layer setBorderColor:[UIColor clearColor].CGColor];
        [button.layer setBorderWidth:2];
        [button setFrame:CGRectMake(frame.origin.x, frame.origin.y, width, height-20)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x, CGRectGetMaxY(button.frame), frame.size.width, 20)];
        [label setText:names[i]];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:[UIColor whiteColor]];
        [backgroundView addSubview:label];
        
        
        [button setTag:i];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [button setBackgroundColor:[NSUserDefaults brBackgroundColorWithIndex:i]];
        [button addTarget:self action:@selector(backgroundChanged:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:button];
        [backgroundBtns addObject:button];
    }
    int index = [[NSUserDefaults brObjectForKey:UserDefaultKeyBackground] integerValue];
    [[(UIButton *)backgroundBtns[index] layer] setBorderColor:[UIColor colorWithRed:235.0/255.0 green:162.0/255.0 blue:13.0/255.0 alpha:1.0].CGColor];
}

- (void)initNavigationView
{
    float screenWidth = self.bounds.size.width;
    float screenHeight = self.bounds.size.height;
    navigationView = [[UIView alloc] initWithFrame:CGRectMake(bottomView.frame.size.width - screenWidth / 3, screenHeight - bottomView.frame.size.height - (screenWidth > 320 ? 2.2 : 1) * (screenWidth / 3), screenWidth / 3, (screenWidth > 320 ? 2.2 : 1) * (screenWidth / 3))];
    [navigationView setHidden:YES];
    [navigationView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
    [navigationView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.6]];
    [self addSubview:navigationView];
    
    UIButton *backToBookShelf = [UIButton buttonWithType:UIButtonTypeCustom];
    [backToBookShelf setTitle:@"返回书架" forState:UIControlStateNormal];
    [backToBookShelf setFrame:CGRectMake(5, 0, navigationView.frame.size.width - 10, navigationView.frame.size.height / 3)];
    [backToBookShelf addTarget:self action:@selector(bookShelfButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backToBookShelf setShowsTouchWhenHighlighted:YES];
    [backToBookShelf.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [backToBookShelf setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [navigationView addSubview:backToBookShelf];
    
    UIView *speateLine1 = [[UIView alloc] initWithFrame:CGRectMake(2, CGRectGetMaxY(backToBookShelf.frame) - 2, navigationView.bounds.size.width - 4, 1)];
    [speateLine1 setBackgroundColor:[UIColor whiteColor]];
    [navigationView addSubview:speateLine1];
    
    UIButton *backToBookStore = [UIButton buttonWithType:UIButtonTypeCustom];
    [backToBookStore setTitle:@"返回书城" forState:UIControlStateNormal];
    [backToBookStore setFrame:CGRectMake(5, 0 + (navigationView.frame.size.height/3) * 1, navigationView.frame.size.width - 10, navigationView.frame.size.height / 3)];
    [backToBookStore addTarget:self action:@selector(bookStoreButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backToBookStore setShowsTouchWhenHighlighted:YES];
    [backToBookStore.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [backToBookStore setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [navigationView addSubview:backToBookStore];
    
    UIView *speateLine2 = [[UIView alloc] initWithFrame:CGRectMake(2, CGRectGetMaxY(backToBookStore.frame) - 2, navigationView.bounds.size.width - 4, 1)];
    [speateLine2 setBackgroundColor:[UIColor whiteColor]];
    [navigationView addSubview:speateLine2];
    
    UIButton *backToBookDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    [backToBookDetail setTitle:@"返回书籍详情" forState:UIControlStateNormal];
    [backToBookDetail setFrame:CGRectMake(5, 0 + (navigationView.frame.size.height/3) * 2, navigationView.frame.size.width - 10, navigationView.frame.size.height / 3)];
    [backToBookDetail addTarget:self action:@selector(bookDetailButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [backToBookDetail setShowsTouchWhenHighlighted:YES];
    [backToBookDetail.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [backToBookDetail setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [navigationView addSubview:backToBookDetail];
    
}

- (void)bookShelfButtonClicked
{
    [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookShelf];
}

- (void)bookStoreButtonClicked
{
    [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookStore];
}

- (void)bookDetailButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(bookDetailButtonClick)]) {
        [self.delegate bookDetailButtonClick];
    }
}

- (void)backgroundChanged:(id)sender
{
    UIButton *currentBtn = (UIButton *)sender;
    for (int i = 0; i < backgroundBtns.count; i++) {
        UIButton *button = backgroundBtns[i];
        if (currentBtn == button) {
            [currentBtn.layer setBorderColor:[UIColor colorWithRed:235.0/255.0 green:162.0/255.0 blue:13.0/255.0 alpha:1.0].CGColor];
        } else {
            [button.layer setBorderColor:[UIColor clearColor].CGColor];
        }
    }
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

- (void)fontChanged:(UIButton *)sender
{
	[self.delegate fontChanged:[sender.titleLabel.text isEqualToString:@"T-"]];
}


- (void)systemFontChange
{
    [self changePositionWithFontName:UserDefaultSystemFont];
    if ([self.delegate respondsToSelector:@selector(systemFont)]) {
        [self.delegate systemFont];
    }
}

- (void)foundFontChange
{
    [self changePositionWithFontName:UserDefaultFoundFont];
    if ([self.delegate respondsToSelector:@selector(foundFont)]) {
        [self.delegate foundFont];
    }
}

- (void)northFontChange
{
    [self changePositionWithFontName:UserDefaultNorthFont];
    if ([self.delegate respondsToSelector:@selector(northFont)]) {
        [self.delegate northFont];
    }
}

- (void)bottomButtonsPressed:(UIButton *)sender
{
    bottomView.hidden = YES;
    topView.hidden = YES;
    if (sender == chaptersListButton) {
        bottomView.hidden = NO;
        topView.hidden = NO;
        navigationView.hidden = YES;
        self.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(chaptersButtonClicked)]) {
            [self.delegate performSelector:@selector(chaptersButtonClicked)];
        }
    } else if (sender == shareButton) {
        bottomView.hidden = NO;
        topView.hidden = NO;
        navigationView.hidden = YES;
        self.hidden = YES;
        [self messageShare];
    } else if (sender == commitButton) {
        bottomView.hidden = NO;
        topView.hidden = NO;
        navigationView.hidden = YES;
        self.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(commitButtonClicked)]) {
            [self.delegate performSelector:@selector(commitButtonClicked)];
        }
    } else if (sender == horizontalButton) {
        bottomView.hidden = NO;
        topView.hidden = NO;
        navigationView.hidden = YES;
         self.hidden = YES;
        UILabel *textLabel = [horizontalButton subviews][1];
        if([[NSUserDefaults brObjectForKey:UserDefaultKeyScreen] isEqualToString:UserDefaultScreenLandscape]) {
            [horizontalButton setImage:[UIImage imageNamed:@"read_hor"] forState:UIControlStateNormal];
            [textLabel setText:@"横屏"];
        } else {
            [horizontalButton setImage:[UIImage imageNamed:@"read_ver"] forState:UIControlStateNormal];
            [textLabel setText:@"竖屏"];
        }
        if ([self.delegate respondsToSelector:@selector(orientationButtonClicked)]) {
            [self.delegate performSelector:@selector(orientationButtonClicked)];
        }
    } else if (sender == brightButton) {
        tapRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - brightView.frame.size.height);
        backgroundView.hidden = YES;
        fontView.hidden = YES;
        brightView.hidden = NO;
        navigationView.hidden = YES;
    } else if (sender == fontSetButton) {
        tapRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - fontView.frame.size.height);
        fontView.hidden = NO;
        brightView.hidden = YES;
        backgroundView.hidden = YES;
        navigationView.hidden = YES;
    } else if (sender == backgroundButton) {
        tapRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - backgroundView.frame.size.height);
        backgroundView.hidden = NO;
        fontView.hidden = YES;
        brightView.hidden = YES;
        navigationView.hidden = YES;
    } else if (sender == resetButton) {
        bottomView.hidden = NO;
        topView.hidden = NO;
        navigationView.hidden = !navigationView.hidden;
    }
}

- (void)reloadView
{
    int index = [[NSUserDefaults brObjectForKey:UserDefaultKeyBackground] integerValue];
    for (int i = 0; i < backgroundBtns.count; i++) {
        UIButton *button = backgroundBtns[i];
        if (index == i) {
            [button.layer setBorderColor:[UIColor colorWithRed:235.0/255.0 green:162.0/255.0 blue:13.0/255.0 alpha:1.0].CGColor];
        } else {
            [button.layer setBorderColor:[UIColor clearColor].CGColor];
        }
    }
    
    if ([NSUserDefaults brObjectForKey:UserDefaultKeyBright]) {
        brightSlider.value = [[NSUserDefaults brObjectForKey:UserDefaultKeyBright] floatValue];
    } else {
        brightSlider.value = 1;
    }
    
    [self changePositionWithFontName:[NSUserDefaults brObjectForKey:UserDefaultKeyFontName]];
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
    navigationView.hidden = YES;
}

@end
