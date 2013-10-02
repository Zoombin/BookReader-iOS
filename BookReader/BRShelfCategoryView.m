//
//  ShelfCategoryView.m
//  BookReader
//
//  Created by zhangbin on 9/28/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRShelfCategoryView.h"
#import "UIColor+BookReader.h"
#import "UIButton+BookReader.h"

#define kHeightOfCategoryButton 30
#define kWidthOfCategoryButton 80
#define kMaxNumberOfCategories 7

@implementation BRShelfCategoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor semitransparentBackgroundColor];
    }
    return self;
}

- (void)setShelfCategories:(NSArray *)shelfCategories
{
	if (_shelfCategories == shelfCategories) return;
	_shelfCategories = shelfCategories;
	
	CGPoint point = CGPointZero;
	NSInteger countOfButtons = MIN(shelfCategories.count, kMaxNumberOfCategories);
	for (int i = 0; i < countOfButtons; i++) {
		ShelfCategory *shelfCategory = shelfCategories[i];
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button shelfCategoryButtonStyle];
		[button setTitle:shelfCategory.name forState:UIControlStateNormal];
		button.frame = CGRectMake(point.x, point.y, kWidthOfCategoryButton, kHeightOfCategoryButton);
		button.tag = i;
		[button addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:button];
		
		point.x += kWidthOfCategoryButton;
		if (i >= 3) {
			point.x = 0;
			point.y = kHeightOfCategoryButton;
		}
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button shelfCategoryButtonStyle];
	[button setTitle:@"分类管理" forState:UIControlStateNormal];
	button.frame = CGRectMake(point.x, point.y, 80, 30);
	[button addTarget:self action:@selector(editShelfCategories) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
	
	CGSize newSize = CGSizeMake(self.frame.size.width, countOfButtons > 4 ? kHeightOfCategoryButton : kHeightOfCategoryButton * 2);
	[self resize:newSize];
}

- (void)categoryButtonTapped:(UIButton *)sender
{
	[_delegate shelfCategoryTapped:_shelfCategories[sender.tag]];
}

- (void)editShelfCategories
{
	[_delegate editShelfCategories];
}

- (void)resize:(CGSize)newSize
{
	[_delegate shelfCategoryViewResize:newSize];
}

@end
