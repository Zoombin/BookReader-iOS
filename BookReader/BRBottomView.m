//
//  BRBottomView.m
//  BookReader
//
//  Created by zhangbin on 10/14/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRBottomView.h"

@implementation BRBottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [bgView setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
        [bgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:bgView];
		
		NSInteger countOfButtons = 3;
		CGSize buttonSize = CGSizeMake(frame.size.width / countOfButtons, [[self class] height]);
		
		CGFloat startX = 0;
		UIColor *selectedColor = [UIColor cyanColor];

		_bookshelfButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_bookshelfButton.frame = CGRectMake(startX, 0, buttonSize.width, buttonSize.height);
		_bookshelfButton.backgroundColor = [UIColor clearColor];
		[_bookshelfButton setTitle:@"书架" forState:UIControlStateNormal];
		_bookshelfButton.showsTouchWhenHighlighted = YES;
		_bookshelfButton.tag = kRootControllerIdentifierBookShelf;
		[_bookshelfButton setTitleColor:selectedColor forState:UIControlStateSelected];
		[_bookshelfButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_bookshelfButton];
		
		startX = CGRectGetMaxX(_bookshelfButton.frame);
		
		_bookstoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_bookstoreButton.frame = CGRectMake(startX, 0, buttonSize.width, buttonSize.height);
		_bookstoreButton.backgroundColor = [UIColor clearColor];
		[_bookstoreButton setTitle:@"书城" forState:UIControlStateNormal];
		_bookstoreButton.showsTouchWhenHighlighted = YES;
		_bookstoreButton.tag = kRootControllerIdentifierBookStore;
		[_bookstoreButton setTitleColor:selectedColor forState:UIControlStateSelected];
		[_bookstoreButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_bookstoreButton];

		startX = CGRectGetMaxX(_bookstoreButton.frame);
		
		_memberButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_memberButton.frame = CGRectMake(startX, 0, buttonSize.width, buttonSize.height);
		_memberButton.backgroundColor = [UIColor clearColor];
		[_memberButton setTitle:@"个人中心" forState:UIControlStateNormal];
		_memberButton.showsTouchWhenHighlighted = YES;
		_memberButton.tag = kRootControllerIdentifierMember;
		[_memberButton setTitleColor:selectedColor forState:UIControlStateSelected];
		[_memberButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_memberButton];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)sender
{
	[APP_DELEGATE gotoRootController:sender.tag];
}

+ (CGFloat)height
{
	return 44.0f;
}


@end
