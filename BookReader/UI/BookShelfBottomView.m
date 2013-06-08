//
//  BookShelfBottomView.m
//  BookReader
//
//  Created by 颜超 on 13-4-18.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookShelfBottomView.h"
#import "UILabel+BookReader.h"
#import <QuartzCore/QuartzCore.h>

#define DURATION 0.3   // 动画持续时间(秒)

@implementation BookShelfBottomView {
    NSMutableArray *buttonArray;
	UIView *bottomViewOne;
    UIView *bottomViewTwo;
	
	UIButton *editButton;
	UIButton *refreshButton;
	UIButton *historyButton;
	UIButton *favButton;
}
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        [backgroundImage setImage:[UIImage imageNamed:@"nav_header"]];
        [self addSubview:backgroundImage];
        [self addButtons];
        
        UILabel *titleLabel = [UILabel titleLableWithFrame:frame];
        [titleLabel setText:@"我的收藏"];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)addButtons {
    float BUTTON_WIDTH = (self.frame.size.width-10)/3;
    CGRect Finish_BUTTON_FRAME = CGRectMake(self.bounds.size.width-BUTTON_WIDTH-5, 2, BUTTON_WIDTH, 40);
    CGRect DELETE_BUTTON_FRAME = CGRectMake(5,2,BUTTON_WIDTH,40);
    CGRect REFRESH_BUTTON_FRAME = CGRectMake(5,2,BUTTON_WIDTH,40);
    CGRect EDIT_BUTTON_FRAME = CGRectMake(CGRectGetMaxX(REFRESH_BUTTON_FRAME), 2, BUTTON_WIDTH, 40);
    CGRect HISTORY_BUTTON_FRAME = CGRectMake(self.bounds.size.width-BUTTON_WIDTH-5,2,BUTTON_WIDTH,40);
    
    bottomViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:bottomViewOne];
    
    bottomViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:bottomViewTwo];
    [bottomViewTwo setHidden:YES];
    
    NSArray *rectStrings = @[NSStringFromCGRect(EDIT_BUTTON_FRAME), NSStringFromCGRect(REFRESH_BUTTON_FRAME),NSStringFromCGRect(HISTORY_BUTTON_FRAME),NSStringFromCGRect(HISTORY_BUTTON_FRAME), NSStringFromCGRect(DELETE_BUTTON_FRAME), NSStringFromCGRect(Finish_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"editButtonClick", @"refreshButtonClick", @"historyButtonClick", @"shelfButtonClick", @"deleteButtonClick", @"finishButtonClick"];
    
    #define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"edit_btn"), UIIMAGE(@"update_btn"), UIIMAGE(@"history_btn"), UIIMAGE(@"fav_btn"),UIIMAGE(@"delete_btn"), UIIMAGE(@"finish_btn")];
    NSArray *highlightedImages = @[UIIMAGE(@"edit_btn_hl"), UIIMAGE(@"update_btn_hl"), UIIMAGE(@"history_btn_hl"), UIIMAGE(@"fav_btn_hl"), UIIMAGE(@"delete_btn_hl"), UIIMAGE(@"finish_btn_hl")];
    
	buttonArray = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImages[i] forState:UIControlStateHighlighted];
        [button setTag:i];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        if (i==4||i==5) {
            [bottomViewTwo addSubview:button];
        } else {
            [bottomViewOne addSubview:button];
        }
        if (i==3) {
            [button setHidden:YES];
        }
        [buttonArray addObject:button];
    }
	
	editButton = buttonArray[0];
	refreshButton = buttonArray[1];
	historyButton = buttonArray[2];
	favButton = buttonArray[3];
}


- (void)finishButtonClick {
    [bottomViewOne setHidden:NO];
    [bottomViewTwo setHidden:YES];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = DURATION;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";
    animation.subtype = kCATransitionFromBottom;
    NSUInteger green = [[self subviews] indexOfObject:bottomViewOne];
    NSUInteger blue = [[self subviews] indexOfObject:bottomViewTwo];
    [self exchangeSubviewAtIndex:green withSubviewAtIndex:blue];
    [[self layer] addAnimation:animation forKey:@"animation"];
    
    [self invokeDelegateMethod:kBottomViewButtonFinishEditing];
}

- (void)editButtonClick {
    [bottomViewOne setHidden:YES];
    [bottomViewTwo setHidden:NO];
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = DURATION;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";
    animation.subtype = kCATransitionFromTop;
    NSUInteger green = [[self subviews] indexOfObject:bottomViewOne];
    NSUInteger blue = [[self subviews] indexOfObject:bottomViewTwo];
    [self exchangeSubviewAtIndex:green withSubviewAtIndex:blue];
    [[self layer] addAnimation:animation forKey:@"animation"];
    
    [self invokeDelegateMethod:kBottomViewButtonEdit];
}

- (void)setEditButtonHidden:(BOOL)hiden
{
	editButton.hidden = hiden;
}

- (void)deleteButtonClick {
    [self invokeDelegateMethod:kBottomViewButtonDelete];
}

- (void)historyButtonClick {
	historyButton.hidden = YES;
	favButton.hidden = NO;
	editButton.hidden = YES;
	refreshButton.hidden = YES;
    [self invokeDelegateMethod:kBottomViewButtonBookHistoroy];
}

- (void)refreshButtonClick {
    [self invokeDelegateMethod:kBottomViewButtonRefresh];
}

- (void)shelfButtonClick {
	editButton.hidden = NO;
	refreshButton.hidden = NO;
	historyButton.hidden = NO;
	favButton.hidden = YES;
    [self invokeDelegateMethod:kBottomViewButtonShelf];
}

- (void)invokeDelegateMethod:(BottomViewButtonType)type {
    if ([self.delegate respondsToSelector:@selector(bottomButtonClicked:)]) {
        [self.delegate performSelector:@selector(bottomButtonClicked:) withObject:@(type)];
    }
}

@end
