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
    UIImageView *topBarImage;
    UIButton *deleteButton;
}
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
         topBarImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [topBarImage setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
        [self addSubview:topBarImage];
        
        _backButton = [UIButton navigationBackButton];
        [_backButton setFrame:CGRectMake(10, 3, 50, 32)];
        [self addSubview:_backButton];
        
        _titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        [_titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)addButtons {
    CGRect BOOKSTORE_BUTTON_FRAME = CGRectMake(self.bounds.size.width-10-50,3,50,32);
    CGRect MYACCOUNT_BUTTON_FRAME = CGRectMake(BOOKSTORE_BUTTON_FRAME.origin.x-50,3,50,32);
    
    CGRect EDIT_BUTTON_FRAME = CGRectMake(10, 3, 50, 32);
    CGRect UPDATE_BUTTON_FRAME = CGRectMake(EDIT_BUTTON_FRAME.origin.x+50, 3, 50, 32);
    CGRect FINISH_BUTTON_FRAME = EDIT_BUTTON_FRAME;
    CGRect DELETE_BUTTON_FRAME = BOOKSTORE_BUTTON_FRAME;
    
    headerViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:headerViewOne];
    
    headerViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:headerViewTwo];
    [headerViewTwo setHidden:YES];
    
    [_backButton setHidden:YES];
    [self bringSubviewToFront:_titleLabel];
    
    NSArray *titles = @[@"书城", @"", @"编辑", @"",@"完成",@"删除"];//会员 更新
    NSArray *rectStrings = @[NSStringFromCGRect(BOOKSTORE_BUTTON_FRAME), NSStringFromCGRect(MYACCOUNT_BUTTON_FRAME),NSStringFromCGRect(EDIT_BUTTON_FRAME),NSStringFromCGRect(UPDATE_BUTTON_FRAME),NSStringFromCGRect(FINISH_BUTTON_FRAME),NSStringFromCGRect(DELETE_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"bButtonClick", @"mButtonClick",@"eButtonClick",@"uButtonClick",@"fButtonClick",@"dButtonClick"];
    
    #define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *styles = @[@(BookReaderButtonStyleRight),@(BookReaderButtonStyleLeft),@(BookReaderButtonStyleLeft),@(BookReaderButtonStyleRight),@(BookReaderButtonStyleNormal),@(BookReaderButtonStyleNormal)];
    for (int i = 0; i < [rectStrings count]; i++) {
        UIButton *button = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[i]) andStyle:[styles[i] intValue]];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        if (i == 1) {
            [button setImage:[UIImage imageNamed:@"shelf_member_btn"] forState:UIControlStateNormal];
        }else if (i == 3) {
            [button setImage:[UIImage imageNamed:@"refresh_btn"] forState:UIControlStateNormal];
        }
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [i < 4 ? headerViewOne : headerViewTwo addSubview:button];
        if (i == 5) {
            [button setUserInteractionEnabled:NO];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            deleteButton = button;
        }
    }
}

- (void)deleteButtonEnable:(BOOL)enable
{
    [deleteButton setUserInteractionEnabled:enable];
    [deleteButton setTitleColor:enable ? [UIColor whiteColor] : [UIColor grayColor] forState:UIControlStateNormal];
}

- (void)bButtonClick
{
    [self invokeDelegateMethod:kHeaderViewButtonBookStore];
}

- (void)mButtonClick
{
    [self invokeDelegateMethod:kHeaderViewButtonMember];
}

- (void)eButtonClick
{
    [headerViewOne setHidden:YES];
    [headerViewTwo setHidden:NO];
    [self invokeDelegateMethod:kHeaderViewButtonEdit];
}

- (void)uButtonClick
{
    [self invokeDelegateMethod:kHeaderViewButtonRefresh];
}

- (void)fButtonClick
{
    [headerViewOne setHidden:NO];
    [headerViewTwo setHidden:YES];
    [self invokeDelegateMethod:kHeaderViewButtonFinishEditing];
}

- (void)dButtonClick
{
    [self invokeDelegateMethod:kHeaderViewButtonDelete];
}

- (void)invokeDelegateMethod:(HeaderViewButtonType)type
{
    if ([self.delegate respondsToSelector:@selector(headerButtonClicked:)]) {
        [self.delegate performSelector:@selector(headerButtonClicked:) withObject:@(type)];
    }
}



@end
