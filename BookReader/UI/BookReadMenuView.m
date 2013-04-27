//
//  BookReadMenuView.m
//  BookReader
//
//  Created by 颜超 on 13-4-19.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookReadMenuView.h"
#import "UIDefines.h"

@implementation BookReadMenuView
@synthesize titleLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initTopView];
        [self initBottomView];
    }
    return self;
}

- (void)initTopView
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width,40)];
    [topView setAlpha:0.9];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[topView bounds]];
    [imageView setImage:[UIImage imageNamed:@"read_top_bar.png"]];
    [topView addSubview:imageView];
    [self addSubview:topView];
    
    titleLabel = [[UILabel alloc] initWithFrame:topView.bounds];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:titleLabel];
    
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
    [addBookMarkButton setFrame:CGRectMake(MAIN_SCREEN.size.width-buttonOffsetX-image.size.width/2, buttonOffsetY, image.size.width/2, image.size.height/2)];
    [addBookMarkButton addTarget:self action:@selector(addBookMarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addBookMarkButton];
}

- (void)initBottomView
{
    #define READ_MENU_BOTTOM_VIEW_RECT (CGRectMake(0, MAIN_SCREEN.size.height-20-40, MAIN_SCREEN.size.width, 40))
    UIView *bottomView = [[UIView alloc] initWithFrame:READ_MENU_BOTTOM_VIEW_RECT];
    [bottomView setAlpha:0.9];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:[bottomView bounds]];
    [imageView setImage:[UIImage imageNamed:@"read_top_bar.png"]];
    [bottomView addSubview:imageView];
    
    #define BUTTON_WIDTH  48
    #define BUTTON_HEIGHT 32
    #define BUTTON_NUMBER 5
    
    #define WIDTH  ((MAIN_SCREEN.size.width)/BUTTON_NUMBER)
    
    #define BUTTON_FRAME_ONE    CGRectMake(0*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 4, BUTTON_WIDTH, BUTTON_HEIGHT)
    #define BUTTON_FRAME_TWO    CGRectMake(1*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 4, BUTTON_WIDTH, BUTTON_HEIGHT)
    #define BUTTON_FRAME_THREE  CGRectMake(2*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 4, BUTTON_WIDTH, BUTTON_HEIGHT)
    #define BUTTON_FRAME_FOUR  CGRectMake(3*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 4, BUTTON_WIDTH, BUTTON_HEIGHT)
    #define BUTTON_FRAME_FIVE  CGRectMake(4*WIDTH+(WIDTH-BUTTON_WIDTH)/4, 4, BUTTON_WIDTH, BUTTON_HEIGHT)
    
    #define BUTTON_FRAME_ONE_STR    NSStringFromCGRect(BUTTON_FRAME_ONE)
    #define BUTTON_FRAME_TWO_STR    NSStringFromCGRect(BUTTON_FRAME_TWO)
    #define BUTTON_FRAME_THREE_STR  NSStringFromCGRect(BUTTON_FRAME_THREE)
    #define BUTTON_FRAME_FOUR_STR  NSStringFromCGRect(BUTTON_FRAME_FOUR)
    #define BUTTON_FRAME_FIVE_STR  NSStringFromCGRect(BUTTON_FRAME_FIVE)
    
    #define BUTTON_IMAGE [UIImage imageNamed:@"search_btn"]
    #define BUTTON_HIGHLIGHTED_IMAGE [UIImage imageNamed:@"search_btn_hl"]
    
    NSArray *titleArrays = @[@"目录", @"上一章", @"字体", @"下一章", @"背景"];
    NSArray *rectArrays = @[BUTTON_FRAME_ONE_STR,BUTTON_FRAME_TWO_STR,BUTTON_FRAME_THREE_STR,BUTTON_FRAME_FOUR_STR,BUTTON_FRAME_FIVE_STR];
    for (int i = 0; i <[rectArrays count]; i++) {
        UIButton *button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setFrame:CGRectFromString([rectArrays objectAtIndex:i])];
        [button setTag:i];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImage:BUTTON_IMAGE forState:UIControlStateNormal];
        [button setBackgroundImage:BUTTON_HIGHLIGHTED_IMAGE forState:UIControlStateHighlighted];
        [button setTitle:titleArrays[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bottomButtonsPressed:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:button];
    }
    
    
    
    
    [self addSubview:bottomView];
}

- (void) initFontView
{
    
}

- (void)bottomButtonsPressed:(id)sender
{
    if ([sender tag] ==0 ) {
        if ([self.delegate respondsToSelector:@selector(chapterButtonClick)]) {
            [self.delegate performSelector:@selector(chapterButtonClick)];
        }
    } else if ([sender tag] == 1) {
        if ([self.delegate respondsToSelector:@selector(previousChapterButtonClick)]) {
            [self.delegate performSelector:@selector(previousChapterButtonClick)];
        }
    } else if ([sender tag] == 2) {
        
    } else if ([sender tag] == 3) {
        if ([self.delegate respondsToSelector:@selector(nextChapterButtonClick)]) {
            [self.delegate performSelector:@selector(nextChapterButtonClick)];
        }
    } else if ([sender tag] == 4) {
        
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
