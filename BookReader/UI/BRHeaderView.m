//
//  BRHeaderView.m
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BRHeaderView.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"

@implementation BRHeaderView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *topBarImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [topBarImage setImage:[UIImage imageNamed:@"nav_header"]];
        [self addSubview:topBarImage];
        
        _backButton = [UIButton navigationBackButton];
        [_backButton setFrame:CGRectMake(10, 6, 50, 32)];
        [self addSubview:_backButton];
        
        _titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)addButtons {
    CGRect MYACCOUNT_BUTTON_FRAME = CGRectMake(10,5,50,32);
    CGRect BOOKSTORE_BUTTON_FRAME = CGRectMake(self.bounds.size.width-10-50,5,50,32);
    
    [_backButton setHidden:YES];
    
    [_titleLabel setText:@"我的收藏"];
    [self bringSubviewToFront:_titleLabel];
    
    NSArray *titles = @[@"书城", @"会员"];
    NSArray *rectStrings = @[NSStringFromCGRect(BOOKSTORE_BUTTON_FRAME), NSStringFromCGRect(MYACCOUNT_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"bButtonClick", @"mButtonClick"];
    
    #define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"bookreader_universal_btn"), UIIMAGE(@"bookreader_universal_btn"), ];

    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
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
