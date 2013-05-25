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
#import "CustomProgressView.h"
#import "MKNumberBadgeView.h"
#import "Book+Setup.h"


@implementation BRBookCell {
	CustomProgressView *progressView;
	UIImageView *selectedMark;
	MKNumberBadgeView *badgeView;
	UIButton *autoBuyButton;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
        progressView = [[CustomProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds), self.bounds.size.width, 8)];
		progressView.hidden = YES;
        [self addSubview:progressView];
        
        selectedMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
		selectedMark.center = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
		[selectedMark setImage:[UIImage imageNamed:@"local_book_select.png"]];
		selectedMark.hidden = YES;
        [self addSubview:selectedMark];
        
        badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
		badgeView.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
        [badgeView setHideWhenZero:YES];
        [self addSubview:badgeView];
        
		autoBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
		autoBuyButton.backgroundColor = [UIColor grayColor];
		autoBuyButton.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 50, self.bounds.size.width, 30);
		autoBuyButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		autoBuyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
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
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:book.coverURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_book.cover = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
			[_book persistWithBlock:nil];
			self.backgroundView = [[UIImageView alloc] initWithImage:image];
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			
		}];
    }
    
    if (_book.progress) {
        [progressView setProgress:book.progress.floatValue];
    }
	
    if (_book.autoBuy) {
		self.autoBuy = _book.autoBuy.boolValue;
    }
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
	badgeView.hidden = _editing;
	autoBuyButton.hidden = !_editing;
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
	NSString *onOffString = onOrOff ? @"开" : @"关";
	[autoBuyButton setTitle:[NSString stringWithFormat:@"自动更新:%@", onOffString] forState:UIControlStateNormal];
	[autoBuyButton setTitleColor:onOrOff ? [UIColor greenColor] : [UIColor blackColor] forState:UIControlStateNormal];
}

@end
