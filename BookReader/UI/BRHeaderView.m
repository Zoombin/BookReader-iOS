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

@implementation BRHeaderView {
    UIView *headerViewOne;
    UIView *headerViewTwo;
}
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
    CGRect BOOKSTORE_BUTTON_FRAME = CGRectMake(self.bounds.size.width-10-50,5,50,32);
    CGRect MYACCOUNT_BUTTON_FRAME = CGRectMake(BOOKSTORE_BUTTON_FRAME.origin.x-50,5,50,32);
    
    CGRect EDIT_BUTTON_FRAME = CGRectMake(10, 5, 50, 32);
    CGRect UPDATE_BUTTON_FRAME = CGRectMake(EDIT_BUTTON_FRAME.origin.x+50, 5, 50, 32);
    CGRect FINISH_BUTTON_FRAME = EDIT_BUTTON_FRAME;
    CGRect DELETE_BUTTON_FRAME = BOOKSTORE_BUTTON_FRAME;
    
    headerViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:headerViewOne];
    
    headerViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:headerViewTwo];
    [headerViewTwo setHidden:YES];
    
    [_backButton setHidden:YES];
    [_titleLabel setText:@"我的收藏"];
    [self bringSubviewToFront:_titleLabel];
    
    NSArray *titles = @[@"书城", @"会员", @"编辑", @"更新",@"完成",@"删除"];
    NSArray *rectStrings = @[NSStringFromCGRect(BOOKSTORE_BUTTON_FRAME), NSStringFromCGRect(MYACCOUNT_BUTTON_FRAME),NSStringFromCGRect(EDIT_BUTTON_FRAME),NSStringFromCGRect(UPDATE_BUTTON_FRAME),NSStringFromCGRect(FINISH_BUTTON_FRAME),NSStringFromCGRect(DELETE_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"bButtonClick", @"mButtonClick",@"eButtonClick",@"uButtonClick",@"fButtonClick",@"dButtonClick"];
    
    #define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"bookreader_universal_btn")];

    for (int i = 0; i < [rectStrings count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setBackgroundImage:images[0] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        if (i<4) {
           [headerViewOne addSubview:button];  
        } else {
           [headerViewTwo addSubview:button];
        }
    }
}

- (void)bButtonClick {
    [self invokeDelegateMethod:kHeaderViewButtonBookStore];
}

- (void)mButtonClick {
    [self invokeDelegateMethod:kHeaderViewButtonMember];
}

- (void)eButtonClick {
    [headerViewOne setHidden:YES];
    [headerViewTwo setHidden:NO];
    [self invokeDelegateMethod:kHeaderViewButtonEdit];
}

- (void)uButtonClick {
    [self invokeDelegateMethod:kHeaderViewButtonRefresh];
}

- (void)fButtonClick {
    [headerViewOne setHidden:NO];
    [headerViewTwo setHidden:YES];
    [self invokeDelegateMethod:kHeaderViewButtonFinishEditing];
}

- (void)dButtonClick {
    [self invokeDelegateMethod:kHeaderViewButtonDelete];
}

- (void)invokeDelegateMethod:(HeaderViewButtonType)type {
    if ([self.delegate respondsToSelector:@selector(headerButtonClicked:)]) {
        [self.delegate performSelector:@selector(headerButtonClicked:) withObject:@(type)];
    }
}



@end
