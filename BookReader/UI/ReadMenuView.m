//
//  ReadMenuView.m
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ReadMenuView.h"
#import "ReadMenuDirectoryViewController.h"
#import "ReadMenuBookMarkViewController.h"
#import "UserDefaultsManager.h"

#define BACKGROUND_IMAGE [UIImage imageNamed:@"read_menu_brightness_view_background.png"]
#define MIN_TRACK_IMAGE [UIImage imageNamed:@"read_menu_brightness_slider_min_track_image.png"]
#define MAX_TRACK_IMAGE [UIImage imageNamed:@"read_menu_brightness_slider_max_track_image.png"]
#define THUMB_IMAGE [UIImage imageNamed:@"read_menu_brightness_slider_thumb_image.png"]
#define MIN_VIEW_IMAGE [UIImage imageNamed:@"read_menu_brightness_min_image.png"]
#define MAX_VIEW_IMAGE [UIImage imageNamed:@"read_menu_brightness_max_image.png"]

#define MIN_TRACK_IMAGE [UIImage imageNamed:@"read_menu_brightness_slider_min_track_image.png"]
#define MAX_TRACK_IMAGE [UIImage imageNamed:@"read_menu_brightness_slider_max_track_image.png"]
#define THUMB_IMAGE [UIImage imageNamed:@"read_menu_brightness_slider_thumb_image.png"]


@implementation ReadMenuView

@synthesize delegate;
@synthesize articleTitleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTopView];
        [self initBottomView];
    }
    return self;
}

- (void)initTopView
{
    #define READ_MENU_TOP_VIEW_RECT (CGRectMake(0, 0, self.bounds.size.width, 40))
    UIView *topView = [[UIView alloc] initWithFrame:READ_MENU_TOP_VIEW_RECT];
    [topView setAlpha:0.9];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[topView bounds]];
    [imageView setImage:[UIImage imageNamed:@"read_top_bar.png"]];
    [topView addSubview:imageView];
    [self addSubview:topView];
    
    booknameScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(70, 5, self.bounds.size.width-120, 30)];
    [booknameScroll setShowsHorizontalScrollIndicator:NO];
    [booknameScroll setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:booknameScroll];
    
    articleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width-120, 25)];
    articleTitleLabel.textAlignment = NSTextAlignmentCenter;
    articleTitleLabel.textColor = [UIColor whiteColor];
    articleTitleLabel.backgroundColor = [UIColor clearColor];
    [booknameScroll addSubview:articleTitleLabel];
    
    static float buttonOffsetX = 10.0;
    static float buttonOffsetY = 7.0;
    
    UIImage *image = [UIImage imageNamed:@"read_menu_top_view_back_button.png"];
    UIImage *imageHighlighted = [UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(buttonOffsetX, buttonOffsetY, image.size.width/2, image.size.height/2)];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [topView addSubview:backButton];
    
    
    image = [UIImage imageNamed:@"read_menu_top_view_add_bookmark_button.png"];
    imageHighlighted = [UIImage imageNamed:@"read_menu_top_view_add_bookmark_button_highlighted.png"];
    UIButton *addBookMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBookMarkButton setImage:image forState:UIControlStateNormal];
    [addBookMarkButton setImage:imageHighlighted forState:UIControlStateHighlighted];
    [addBookMarkButton setFrame:CGRectMake(self.bounds.size.width-buttonOffsetX-image.size.width/2, buttonOffsetY, image.size.width/2, image.size.height/2)];
    [addBookMarkButton addTarget:self action:@selector(addBookMarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addBookMarkButton];
    
}

- (void)initBottomView
{
#define BUTTON_WIDTH 80
#define BUTTON_HEIGHT 45
    
#define BUTTON_NUMBER 5
    
#define WIDTH  ((self.bounds.size.width)/BUTTON_NUMBER)
    
#define BUTTON_TITLE_1 @"亮度"
#define BUTTON_TITLE_2 @"模式"
#define BUTTON_TITLE_3 @"字体"
#define BUTTON_TITLE_4 @"选择"
#define BUTTON_TITLE_5 @"书签"
#define BUTTON_TITLE_6 @"更多"
    
#define BUTTON_RECT_1 CGRectMake(0*WIDTH+(WIDTH-BUTTON_WIDTH)/2, -5, BUTTON_WIDTH, BUTTON_HEIGHT)
#define BUTTON_RECT_2 CGRectMake(1*BUTTON_WIDTH+3*(WIDTH-BUTTON_WIDTH)/2, -5, BUTTON_WIDTH, BUTTON_HEIGHT)
#define BUTTON_RECT_3 CGRectMake(2*BUTTON_WIDTH+5*(WIDTH-BUTTON_WIDTH)/2, -5, BUTTON_WIDTH, BUTTON_HEIGHT)
#define BUTTON_RECT_4 CGRectMake(BUTTON_WIDTH*3, 0, BUTTON_WIDTH, BUTTON_HEIGHT)
#define BUTTON_RECT_5 CGRectMake(3*BUTTON_WIDTH+7*(WIDTH-BUTTON_WIDTH)/2, -5, BUTTON_WIDTH, BUTTON_HEIGHT)
#define BUTTON_RECT_6 CGRectMake(4*BUTTON_WIDTH+9*(WIDTH-BUTTON_WIDTH)/2, -5, BUTTON_WIDTH, BUTTON_HEIGHT)
    
#define BUTTON_RECT_STR_1 NSStringFromCGRect(BUTTON_RECT_1)
#define BUTTON_RECT_STR_2 NSStringFromCGRect(BUTTON_RECT_2)
#define BUTTON_RECT_STR_3 NSStringFromCGRect(BUTTON_RECT_3)
#define BUTTON_RECT_STR_4 NSStringFromCGRect(BUTTON_RECT_4)
#define BUTTON_RECT_STR_5 NSStringFromCGRect(BUTTON_RECT_5)
#define BUTTON_RECT_STR_6 NSStringFromCGRect(BUTTON_RECT_6)
    
#define BUTTON_IMAGE_1 [UIImage imageNamed:@"read_menu_bottom_view_brightness.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_1 [UIImage imageNamed:@"read_menu_bottom_view_brightness_highlighted.png"]
    
#define BUTTON_IMAGE_2 [UIImage imageNamed:@"read_menu_bottom_view_mode_day.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_2 [UIImage imageNamed:@"read_menu_bottom_view_mode_day_highlighted.png"]
    
#define BUTTON_IMAGE_3 [UIImage imageNamed:@"read_menu_bottom_view_font.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_3 [UIImage imageNamed:@"read_menu_bottom_view_font_highlighted.png"]
    
#define BUTTON_IMAGE_4 [UIImage imageNamed:@"read_menu_bottom_view_select.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_4 [UIImage imageNamed:@"read_menu_bottom_view_select_highlighted.png"]
    
#define BUTTON_IMAGE_5 [UIImage imageNamed:@"read_menu_bottom_view_bookmark.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_5 [UIImage imageNamed:@"read_menu_bottom_view_bookmark_highlighted.png"]
    
#define BUTTON_IMAGE_6 [UIImage imageNamed:@"read_menu_bottom_view_more.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_6 [UIImage imageNamed:@"read_menu_bottom_view_more_highlighted.png"]
    
#define BUTTON_IMAGE_NIGHT [UIImage imageNamed:@"read_menu_bottom_view_mode_night.png"]
#define BUTTON_HIGHLIGHTED_IMAGE_NIGHT [UIImage imageNamed:@"read_menu_bottom_view_mode_night_highlighted.png"]
    
#define READ_MENU_BOTTOM_VIEW_RECT (CGRectMake(0, self.bounds.size.height-20-40, self.bounds.size.width+20, 40))
    UIView *bottomView = [[UIView alloc] initWithFrame:READ_MENU_BOTTOM_VIEW_RECT];
    [bottomView setAlpha:0.9];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[bottomView bounds]];
    [imageView setImage:[UIImage imageNamed:@"read_top_bar.png"]];
    [bottomView addSubview:imageView];
    
    NSArray *buttonsTitleArray = [NSArray arrayWithObjects:BUTTON_TITLE_1, BUTTON_TITLE_2, BUTTON_TITLE_3, BUTTON_TITLE_5, BUTTON_TITLE_6, nil];
    NSArray *buttonsRectArray = [NSArray arrayWithObjects:BUTTON_RECT_STR_1, BUTTON_RECT_STR_2, BUTTON_RECT_STR_3, BUTTON_RECT_STR_5, BUTTON_RECT_STR_6, nil];
    NSArray *buttonsImageArray = [NSArray arrayWithObjects:BUTTON_IMAGE_1, BUTTON_IMAGE_2, BUTTON_IMAGE_3, BUTTON_IMAGE_5, BUTTON_IMAGE_6, nil];
    NSArray *buttonsHighlightedImageArray = [NSArray arrayWithObjects:BUTTON_HIGHLIGHTED_IMAGE_1, BUTTON_HIGHLIGHTED_IMAGE_2, BUTTON_HIGHLIGHTED_IMAGE_3, BUTTON_HIGHLIGHTED_IMAGE_5, BUTTON_HIGHLIGHTED_IMAGE_6, nil];
    
    for(int i = 0; i < [buttonsTitleArray count]; ++i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectFromString([buttonsRectArray objectAtIndex:i])];
        [button addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
        if(i == 1) {
            modeButton = button;
        }
        [button setTag:i+1];
        [button setBackgroundImage:[buttonsImageArray objectAtIndex:i] forState:UIControlStateNormal];
        [button setBackgroundImage:[buttonsHighlightedImageArray objectAtIndex:i] forState:UIControlStateHighlighted];
        [bottomView addSubview:button];
    }
    
    [self addSubview:bottomView];
    [self checkModeButton];
}

- (void)initBrightnessView
{
    brightnessView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width-320)/2, self.bounds.size.height-80, 320, 48)];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:BACKGROUND_IMAGE];
    [brightnessView setBackgroundColor:backgroundColor];
    
    
    UIImage *minTrackImage = [MIN_TRACK_IMAGE stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage *maxTrackImage = [MAX_TRACK_IMAGE stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, brightnessView.frame.size.width/2, brightnessView.frame.size.height/2)];
    [slider setCenter:CGPointMake(brightnessView.frame.size.width/2, brightnessView.frame.size.height/2)];
    slider.minimumValue = [UserDefaultsValueBrightnessMin floatValue];
    slider.maximumValue = [UserDefaultsValueBrightnessMax floatValue];
    slider.value = [[UserDefaultsManager objectForKey:UserDefaultsKeyBrightness] floatValue];
    [slider addTarget:self action:@selector(brightnessChanging:) forControlEvents:UIControlEventValueChanged];
    
    
    [slider setThumbImage:THUMB_IMAGE forState:UIControlStateNormal];
    [slider setThumbImage:THUMB_IMAGE forState:UIControlStateHighlighted];
    
    [slider setMinimumTrackImage:minTrackImage forState:UIControlStateNormal];
    [slider setMaximumTrackImage:maxTrackImage forState:UIControlStateNormal];
    
    [brightnessView addSubview:slider];
    
    static float imageOffsetX = 40.0;
    
    UIImageView *minView = [[UIImageView alloc] initWithImage:MIN_VIEW_IMAGE];
    [minView setFrame:CGRectMake(imageOffsetX, brightnessView.bounds.size.height/5-5,36,36)];
    [brightnessView addSubview:minView];
    
    UIImageView *maxView = [[UIImageView alloc] initWithImage:MAX_VIEW_IMAGE];
    [maxView setFrame:CGRectMake(280-imageOffsetX, brightnessView.bounds.size.height/5-5,36,36)];
    [brightnessView addSubview:maxView];
    
    [self addSubview:brightnessView];
}

- (void)initFontView
{
    fontView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width-320)/2, self.bounds.size.height-80, 320, 48)];
    
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:BACKGROUND_IMAGE];
    [fontView setBackgroundColor:backgroundColor];
    
    
    UIImage *minTrackImage = [MIN_TRACK_IMAGE stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage *maxTrackImage = [MAX_TRACK_IMAGE stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, fontView.frame.size.width/2, fontView.frame.size.height/2)];
    [slider setCenter:CGPointMake(fontView.frame.size.width/2, fontView.frame.size.height/2)];
    
    slider.minimumValue = [UserDefaultsValueFontSizeMin floatValue];
    slider.maximumValue = [UserDefaultsValueFontSizeMax floatValue];
    slider.value = [[UserDefaultsManager objectForKey:UserDefaultsKeyFontSize] floatValue];
    [slider addTarget:self action:@selector(fontSizeChanged:) forControlEvents:UIControlEventValueChanged];
    [slider setContinuous:NO];
    
    [slider setThumbImage:THUMB_IMAGE forState:UIControlStateNormal];
    [slider setThumbImage:THUMB_IMAGE forState:UIControlStateHighlighted];
    
    [slider setMinimumTrackImage:minTrackImage forState:UIControlStateNormal];
    [slider setMaximumTrackImage:maxTrackImage forState:UIControlStateNormal];
    
    [fontView addSubview:slider];
    
    static float imageOffsetX = 50.0;
    
    UIImageView *fontSizeMinView = [[UIImageView alloc] initWithImage:MIN_VIEW_IMAGE];
    [fontSizeMinView setFrame:CGRectMake(imageOffsetX, fontView.bounds.size.height/3-5,33,22)];
    [fontView addSubview:fontSizeMinView];
    
    UIImageView *fontSizeMaxView = [[UIImageView alloc] initWithImage:MAX_VIEW_IMAGE];
    [fontSizeMaxView setFrame:CGRectMake(290-imageOffsetX, fontView.bounds.size.height/3-5,33,22)];
    [fontView addSubview:fontSizeMaxView];
    
    [self addSubview:fontView];
}

- (void)backButtonPressed:(id)sender
{
    [self perform:@selector(backButtonPressed)];
}


- (void)addBookMarkButtonPressed:(id)sender
{
    [self perform:@selector(addBookMarkButtonPressed)];
}

- (void)brightnessChanging:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    [self perform:@selector(brightnessChanging:) withValue:[NSNumber numberWithFloat:[slider value]]];
}

- (void)fontSizeChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    [self perform:@selector(fontSizeChanged:) withValue:[NSNumber numberWithFloat:[slider value]]];
}

- (void)bottomButtonsPressed:(id)sender {
    if(![sender isKindOfClass:[UIButton class]])
        return;
    NSInteger tag = [sender tag];
    if(tag == 1) {//brightness
        if (!brightnessView) {
            [self initBrightnessView];
        }
        else {
            brightnessView.hidden = !brightnessView.hidden;
        }
        
        if (fontView) {
            fontView.hidden = YES;
        }
    }
    else if(tag == 2) {//dayAndNight
        if([[UserDefaultsManager objectForKey:UserDefaultsKeyBackground] isEqualToString:UserDefaultsValueBackgroundDay]) {
            [UserDefaultsManager setObject:UserDefaultsValueBackgroundNight forKey:UserDefaultsKeyBackground];
        }
        else {
            [UserDefaultsManager setObject:UserDefaultsValueBackgroundDay forKey:UserDefaultsKeyBackground];
        }
        [self checkModeButton];
        [self perform:@selector(modeButtonPressed)];
    }
    else if(tag == 3) {//font
        if (!fontView) {
            [self initFontView];
        }
        else {
            fontView.hidden = !fontView.hidden;
        }
        
        if (brightnessView) {
            brightnessView.hidden = YES;
        }
    }
    else if(tag == 4) {//bookmark
        [self perform:@selector(bookmarkButtonPressed)];
    }
    else if(tag == 5) {//more
        [self perform:@selector(moreButtonPressed)];
    }
}

- (void)checkModeButton {
    if([[UserDefaultsManager objectForKey:UserDefaultsKeyBackground] isEqualToString:UserDefaultsValueBackgroundDay]) {
        [modeButton setBackgroundImage:BUTTON_IMAGE_NIGHT forState:UIControlStateNormal];
        [modeButton setBackgroundImage:BUTTON_HIGHLIGHTED_IMAGE_NIGHT forState:UIControlStateHighlighted];
    }
    else {
        [modeButton setBackgroundImage:BUTTON_IMAGE_2 forState:UIControlStateNormal];
        [modeButton setBackgroundImage:BUTTON_HIGHLIGHTED_IMAGE_2 forState:UIControlStateHighlighted];
    }
}


- (void)perform:(SEL)aSelector
{
    if(delegate) {
        if([delegate respondsToSelector:aSelector]) {
            [delegate performSelector:aSelector];
        }
    }
}

- (void)perform:(SEL)aSelector withValue:(NSNumber *)number
{
    if(delegate) {
        if ([delegate respondsToSelector:aSelector]) {
            [delegate performSelector:aSelector withObject:number];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setHidden:YES];
    [fontView setHidden:YES];
    [brightnessView setHidden:YES];
}




@end
