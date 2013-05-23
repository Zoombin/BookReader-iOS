//
//  HeaderView.m
//  BookReader
//
//  Created by 颜超 on 13-3-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookShelfHeaderView.h"
#import "UILabel+BookReader.h"
#import <QuartzCore/QuartzCore.h>

#define DURATION 0.3   // 动画持续时间(秒)

#define EDIT_BUTTON_FRAME                      CGRectMake(10, 4, 48, 32)
#define Finish_BUTTON_FRAME                    CGRectMake(10, 4, 48, 32)
#define DELETE_BUTTON_FRAME                    CGRectMake(self.bounds.size.width-60,4,48,32)
#define MYACCOUNT_BUTTON_FRAME                 CGRectMake(self.bounds.size.width-110,4,48,32)
#define BOOKSTORE_BUTTON_FRAME                 CGRectMake(self.bounds.size.width-60,4,48,32)

@implementation BookShelfHeaderView
@synthesize delegate;
@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        [backgroundImage setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
        [self addSubview:backgroundImage];
        [self addButtons];
        
        self.titleLabel = [UILabel titleLableWithFrame:frame];
        [titleLabel setText:@"我的收藏"];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)addButtons {
    headerViewOne = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:headerViewOne];
    
    NSArray *titles = @[@"书城", @""];
    NSArray *rectStrings = @[NSStringFromCGRect(BOOKSTORE_BUTTON_FRAME), NSStringFromCGRect(MYACCOUNT_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"bButtonClick", @"mButtonClick"];
    
#define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"nav_bookstorebtn"), UIIMAGE(@"nav_private"), ];
    NSArray *highlightedImages = @[UIIMAGE(@"nav_bookstorebtn"), UIIMAGE(@"nav_private")];
    
    NSAssert(titles.count == rectStrings.count && rectStrings.count == selectorStrings.count && selectorStrings.count == images.count && images.count == highlightedImages.count, @"titles.count, rectStrings.count, selectorStrings.count, images.count, highlightedImages.count can't match each other...");
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImages[i] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [headerViewOne addSubview:button];
    }
}

- (void)bButtonClick {
    [self invokeDelegateMethod:kHeaderViewButtonBookStore];
}

- (void)mButtonClick {
    [self invokeDelegateMethod:kHeaderViewButtonMember];
}

- (void)invokeDelegateMethod:(HeaderViewButtonType)type {
    if ([self.delegate respondsToSelector:@selector(headerButtonClicked:)]) {
        [self.delegate performSelector:@selector(headerButtonClicked:) withObject:@(type)];
    }
}

@end
