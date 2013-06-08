//
//  BRBookCell.m
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "BRBookCell.h"
#import "Book.h"
#import "UIImageView+AFNetworking.h"
#import "MKNumberBadgeView.h"
#import "Book+Setup.h"


@implementation BRBookCell {
	UIImageView *selectedMark;
	MKNumberBadgeView *badgeView;
	UIButton *autoBuyButton;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
        selectedMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[selectedMark setImage:[UIImage imageNamed:@"book_checkmark"]];
		selectedMark.hidden = YES;
        [self addSubview:selectedMark];
        
        badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
		badgeView.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
        [badgeView setHideWhenZero:YES];
        [self addSubview:badgeView];
        
		autoBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		autoBuyButton.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 30, self.bounds.size.width, 30);
        [autoBuyButton setBackgroundImage:[UIImage imageNamed:@"autobuy_off"] forState:UIControlStateNormal];
		[autoBuyButton addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:autoBuyButton];
		
		self.autoBuy = NO;
		self.badge = 0;
	}
	return self;
}

- (void)setBook:(Book *)book
{
	_book = book;
    if (_book.cover) {
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:_book.cover]];
    } else {
		UIImageView *imageView = [[UIImageView alloc] init];
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_placeholder"]];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:book.coverURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				_book.cover = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
			}];
			[(UIImageView *)self.backgroundView setImage:image];
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			
		}];
    }

    if (_book.autoBuy) {
		self.autoBuy = _book.autoBuy.boolValue;
    }
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
	badgeView.hidden = editing;
	autoBuyButton.hidden = !_editing;
    if (!editing) {
        [self setCellSelected:NO];
    }
	self.backgroundView.alpha = _editing ? 0.5 : 1.0;
}

- (void)setCellSelected:(BOOL)selected
{
	_cellSelected = selected;
	selectedMark.hidden = !_cellSelected;
}

- (void)setBadge:(NSInteger)badge
{
	_badge = badge;
    badgeView.value = _badge;
}

- (void)valueChanged:(id)sender {
	[_bookCellDelegate changedValueBookCell:self];
}

- (void)setAutoBuy:(BOOL)onOrOff
{
	_autoBuy = onOrOff;
    [autoBuyButton setBackgroundImage:[UIImage imageNamed:onOrOff ? @"autobuy_on" : @"autobuy_off"] forState:UIControlStateNormal];
}

@end
