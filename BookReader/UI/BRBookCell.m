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
    UIImageView *autoBuyMark;
	MKNumberBadgeView *badgeView;
	UIButton *autoBuyButton;
    UILabel *nameLabel;
	UIImageView *cover;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_placeholder"]];
		cover.frame = CGRectMake(0, 0, 70, 89);
		[self.contentView addSubview:cover];
		
        selectedMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        selectedMark.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
		[selectedMark setImage:[UIImage imageNamed:@"book_checkmark"]];
		selectedMark.hidden = YES;
        [self.contentView addSubview:selectedMark];
        
        badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
		badgeView.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
        [badgeView setHideWhenZero:YES];
        [self.contentView addSubview:badgeView];
        
        autoBuyMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        autoBuyMark.center = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds) + 5);
        [autoBuyMark setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:autoBuyMark];
        
		autoBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		autoBuyButton.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 26, self.bounds.size.width, 30);
        [autoBuyButton setBackgroundImage:[UIImage imageNamed:@"autobuy_off"] forState:UIControlStateNormal];
		[autoBuyButton addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:autoBuyButton];
        
        nameLabel = [[UILabel alloc] initWithFrame:autoBuyButton.frame];
        [nameLabel setBackgroundColor:[UIColor colorWithRed:78.0/255.0 green:129.0/255.0 blue:172.0/255.0 alpha:1.0]];
        [nameLabel setAlpha:0.8];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentView addSubview:nameLabel];
				
		self.autoBuy = NO;
		self.badge = 0;
	}
	return self;
}

- (void)setBook:(Book *)book
{
	_book = book;
    if (_book.cover) {
		cover.image = [UIImage imageWithData:_book.cover];
    } else {
		UIImageView *imageView = [[UIImageView alloc] init];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:book.coverURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				_book.cover = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
			}];
			cover.image = image;
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			
		}];
    }

    nameLabel.text = [_book.name length]>=4 ? [_book.name substringToIndex:4] : _book.name;
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
	self.alpha = _editing ? 0.5 : 1.0;
    nameLabel.hidden = _editing ? YES : NO;
    autoBuyMark.hidden = _editing ? YES : NO;
//	self.backgroundView.alpha = _editing ? 0.5 : 1.0;
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
    [autoBuyMark setImage:onOrOff ? [UIImage imageNamed:@"refresh_mark"] : nil];
    [autoBuyButton setBackgroundImage:[UIImage imageNamed:onOrOff ? @"autobuy_on" : @"autobuy_off"] forState:UIControlStateNormal];
}

@end
