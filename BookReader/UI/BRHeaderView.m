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
    UIImageView *topBarImage;
    UIButton *deleteButton;
    UIButton *refreshButton;
    UIButton *bookStoreBtn;
    UIButton *memberBtn;
    UIButton *editBtn;
    UIButton *finishBtn;
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
		_backButton.showsTouchWhenHighlighted = YES;
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
    
    [_backButton setHidden:YES];
    [self bringSubviewToFront:_titleLabel];
    
     bookStoreBtn = [UIButton addButtonWithFrame:BOOKSTORE_BUTTON_FRAME andStyle:BookReaderButtonStyleRight];
    [bookStoreBtn setTitle:@"书城" forState:UIControlStateNormal];
    [bookStoreBtn addTarget:self action:@selector(bButtonClick) forControlEvents:UIControlEventTouchUpInside];
	bookStoreBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:bookStoreBtn];
    
     memberBtn = [UIButton addButtonWithFrame:MYACCOUNT_BUTTON_FRAME andStyle:BookReaderButtonStyleLeft];
    [memberBtn setImage:[UIImage imageNamed:@"shelf_member_btn"] forState:UIControlStateNormal];
    [memberBtn addTarget:self action:@selector(mButtonClick) forControlEvents:UIControlEventTouchUpInside];
	memberBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:memberBtn];
    
     editBtn = [UIButton addButtonWithFrame:EDIT_BUTTON_FRAME andStyle:BookReaderButtonStyleLeft];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(eButtonClick) forControlEvents:UIControlEventTouchUpInside];
	editBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:editBtn];
    
    refreshButton = [UIButton addButtonWithFrame:UPDATE_BUTTON_FRAME andStyle:BookReaderButtonStyleRight];
    [refreshButton setImage:[UIImage imageNamed:@"refresh_btn"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(uButtonClick) forControlEvents:UIControlEventTouchUpInside];
	refreshButton.showsTouchWhenHighlighted = YES;
    [self addSubview:refreshButton];
    
     finishBtn = [UIButton addButtonWithFrame:FINISH_BUTTON_FRAME andStyle:BookReaderButtonStyleNormal];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(fButtonClick) forControlEvents:UIControlEventTouchUpInside];
	finishBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:finishBtn];
    
    deleteButton = [UIButton addButtonWithFrame:DELETE_BUTTON_FRAME andStyle:BookReaderButtonStyleNormal];
    [deleteButton setUserInteractionEnabled:NO];
    [deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(dButtonClick) forControlEvents:UIControlEventTouchUpInside];
	deleteButton.showsTouchWhenHighlighted = YES;
    [self addSubview:deleteButton];
    
    [finishBtn setHidden:YES];
    [deleteButton setHidden:YES];
    [bookStoreBtn setHidden:NO];
    [refreshButton setHidden:NO];
    [memberBtn setHidden:NO];
    [editBtn setHidden:NO];
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
    [finishBtn setHidden:NO];
    [deleteButton setHidden:NO];
    [bookStoreBtn setHidden:YES];
    [refreshButton setHidden:YES];
    [memberBtn setHidden:YES];
    [editBtn setHidden:YES];
    [self invokeDelegateMethod:kHeaderViewButtonEdit];
}

- (void)uButtonClick
{
    [self invokeDelegateMethod:kHeaderViewButtonRefresh];
}

- (void)fButtonClick
{
    [finishBtn setHidden:YES];
    [deleteButton setHidden:YES];
    [bookStoreBtn setHidden:NO];
    [refreshButton setHidden:NO];
    [memberBtn setHidden:NO];
    [editBtn setHidden:NO];
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
