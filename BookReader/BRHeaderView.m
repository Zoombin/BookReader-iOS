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

#define kGap 10

@implementation BRHeaderView {
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
		
		UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [bgView setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
        [bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:bgView];
        
        _backButton = [UIButton navigationBackButton];
        [_backButton setFrame:CGRectMake(kGap, 3, 50, 32)];
		_backButton.showsTouchWhenHighlighted = YES;
        [self addSubview:_backButton];
        
		_titleLabel = [UILabel titleLableWithFrame:CGRectMake(80, 0, self.bounds.size.width - 160, [BRHeaderView height])];
		[_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)addButtons
{
	CGSize buttonSize = CGSizeMake(50, 32);
	
	[_backButton setHidden:YES];
    [self bringSubviewToFront:_titleLabel];
	
//    CGRect MYACCOUNT_BUTTON_FRAME = CGRectMake(BOOKSTORE_BUTTON_FRAME.origin.x - buttonSize.width, 3, buttonSize.width, buttonSize.height);
    //CGRect EDIT_BUTTON_FRAME = CGRectMake(kGap, 3, buttonSize.width, buttonSize.height);
//    CGRect UPDATE_BUTTON_FRAME = CGRectMake(EDIT_BUTTON_FRAME.origin.x + buttonSize.width, 3, buttonSize.width, buttonSize.height);
    
//     bookStoreBtn = [UIButton addButtonWithFrame:CGRectMake(self.bounds.size.width - kGap - 50, 3, 50, 32) andStyle:BookReaderButtonStyleRight];
//    [bookStoreBtn setTitle:@"书城" forState:UIControlStateNormal];
//    [bookStoreBtn addTarget:self action:@selector(bButtonClick) forControlEvents:UIControlEventTouchUpInside];
//	bookStoreBtn.showsTouchWhenHighlighted = YES;
//    [self addSubview:bookStoreBtn];
//    
//     memberBtn = [UIButton addButtonWithFrame:MYACCOUNT_BUTTON_FRAME andStyle:BookReaderButtonStyleLeft];
//    [memberBtn setImage:[UIImage imageNamed:@"shelf_member_btn"] forState:UIControlStateNormal];
//    [memberBtn addTarget:self action:@selector(mButtonClick) forControlEvents:UIControlEventTouchUpInside];
//	memberBtn.showsTouchWhenHighlighted = YES;
//    [self addSubview:memberBtn];
    
     editBtn = [UIButton addButtonWithFrame:CGRectMake(kGap, 3, buttonSize.width, buttonSize.height) andStyle:BookReaderButtonStyleLeft];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(eButtonClick) forControlEvents:UIControlEventTouchUpInside];
	editBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:editBtn];
    
//    refreshButton = [UIButton addButtonWithFrame:UPDATE_BUTTON_FRAME andStyle:BookReaderButtonStyleRight];
//    [refreshButton setImage:[UIImage imageNamed:@"refresh_btn"] forState:UIControlStateNormal];
//    [refreshButton addTarget:self action:@selector(uButtonClick) forControlEvents:UIControlEventTouchUpInside];
//	refreshButton.showsTouchWhenHighlighted = YES;
//	refreshButton.hidden = YES;
//    [self addSubview:refreshButton];
    
     finishBtn = [UIButton addButtonWithFrame:editBtn.frame andStyle:BookReaderButtonStyleNormal];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(fButtonClick) forControlEvents:UIControlEventTouchUpInside];
	finishBtn.showsTouchWhenHighlighted = YES;
    [self addSubview:finishBtn];
    
    [finishBtn setHidden:YES];
    [bookStoreBtn setHidden:NO];
    [refreshButton setHidden:YES];
    [memberBtn setHidden:NO];
    [editBtn setHidden:NO];
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
    [bookStoreBtn setHidden:NO];
    [refreshButton setHidden:YES];
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
