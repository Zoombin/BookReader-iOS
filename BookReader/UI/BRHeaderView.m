//
//  BRHeaderView.m
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BRHeaderView.h"
#import "UIButton+BookReader.h"
#import "ServiceManager.h"

@implementation BRHeaderView {
    UIView *headerViewOne;
    UIView *headerViewTwo;
    UIImageView *topBarImage;
    UIButton *deleteButton;
    UIButton *refreshButton;
}

+ (CGFloat)height
{
	return 44.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		
		topBarImage = [[UIImageView alloc] initWithFrame:self.bounds];
        [topBarImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [topBarImage setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
        [topBarImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:topBarImage];
        
        _backButton = [UIButton navigationBackButton];
        [_backButton setFrame:CGRectMake(10, 3, 50, 32)];
        [self addSubview:_backButton];
        
		_titleLabel = [UILabel titleLableWithFrame:CGRectMake(80, 0, self.bounds.size.width - 160, BRHeaderView.height)];
		[_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_titleLabel setAdjustsLetterSpacingToFitWidth:YES];
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
    
    headerViewOne = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:headerViewOne];
    
    headerViewTwo = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:headerViewTwo];
    [headerViewTwo setHidden:YES];
    
    [_backButton setHidden:YES];
    [self bringSubviewToFront:_titleLabel];
    
    NSArray *titles = @[@"书城", @"", @"编辑", @"",@"完成",@"删除"];//会员 更新
    NSArray *rectStrings = @[NSStringFromCGRect(BOOKSTORE_BUTTON_FRAME), NSStringFromCGRect(MYACCOUNT_BUTTON_FRAME),NSStringFromCGRect(EDIT_BUTTON_FRAME),NSStringFromCGRect(UPDATE_BUTTON_FRAME),NSStringFromCGRect(FINISH_BUTTON_FRAME),NSStringFromCGRect(DELETE_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"bButtonClick", @"mButtonClick",@"eButtonClick",@"uButtonClick",@"fButtonClick",@"dButtonClick"];
    
    #define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *styles = @[@(BookReaderButtonStyleRight),@(BookReaderButtonStyleLeft),@(BookReaderButtonStyleLeft),@(BookReaderButtonStyleRight),@(BookReaderButtonStyleNormal),@(BookReaderButtonStyleNormal)];
    
    UIButton *bookStoreBtn = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[0]) andStyle:[styles[0] intValue]];
    [bookStoreBtn setTitle:titles[0] forState:UIControlStateNormal];
    [bookStoreBtn addTarget:self action:NSSelectorFromString(selectorStrings[0]) forControlEvents:UIControlEventTouchUpInside];
    [headerViewOne addSubview:bookStoreBtn];
    
    UIButton *memberBtn = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[1]) andStyle:[styles[1] intValue]];
    [memberBtn setImage:[UIImage imageNamed:@"shelf_member_btn"] forState:UIControlStateNormal];
    [memberBtn setTitle:titles[1] forState:UIControlStateNormal];
    [memberBtn addTarget:self action:NSSelectorFromString(selectorStrings[1]) forControlEvents:UIControlEventTouchUpInside];
    [headerViewOne addSubview:memberBtn];
    
    UIButton *editBtn = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[2]) andStyle:[styles[2] intValue]];
    [editBtn setTitle:titles[2] forState:UIControlStateNormal];
    [editBtn addTarget:self action:NSSelectorFromString(selectorStrings[2]) forControlEvents:UIControlEventTouchUpInside];
    [headerViewOne addSubview:editBtn];
    
    refreshButton = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[3]) andStyle:[styles[3] intValue]];
    [refreshButton setImage:[UIImage imageNamed:@"refresh_btn"] forState:UIControlStateNormal];
    [refreshButton setTitle:titles[3] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:NSSelectorFromString(selectorStrings[3]) forControlEvents:UIControlEventTouchUpInside];
    [headerViewOne addSubview:refreshButton];
    
    UIButton *finishBtn = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[4]) andStyle:[styles[4] intValue]];
    [finishBtn setTitle:titles[4] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:NSSelectorFromString(selectorStrings[4]) forControlEvents:UIControlEventTouchUpInside];
    [headerViewTwo addSubview:finishBtn];
    
    deleteButton = [UIButton addButtonWithFrame:CGRectFromString(rectStrings[5]) andStyle:[styles[5] intValue]];
    [deleteButton setUserInteractionEnabled:NO];
    [deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [deleteButton setTitle:titles[5] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:NSSelectorFromString(selectorStrings[5]) forControlEvents:UIControlEventTouchUpInside];
    [headerViewTwo addSubview:deleteButton];
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
	[_delegate performSelector:@selector(headerButtonClicked:) withObject:@(type)];
}



@end
