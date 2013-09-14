//
//  BRBookCell.m
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRBookCell.h"
#import "UIImageView+AFNetworking.h"
#import "MKNumberBadgeView.h"
#import "ServiceManager.h"

@implementation BRBookCell {
//	UIImageView *selectedMark;
//    UIImageView *autoBuyMark;
//	MKNumberBadgeView *badgeView;
//	UIButton *autoBuyButton;
    UIButton *deleteButton;
    UIImageView *updateMark;
    UIButton *nameLabel;
	UIImageView *cover;
	UIImageView *finishMark;
}

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
		cover = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_placeholder"]];
		cover.frame = CGRectMake(0, 0, 70, 89);
		[self.contentView addSubview:cover];
		
//        selectedMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//        selectedMark.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
//		[selectedMark setImage:[UIImage imageNamed:@"book_checkmark"]];
//		selectedMark.hidden = YES;
//        [self.contentView addSubview:selectedMark];
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0, 100, 100)];
        deleteButton.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
		[deleteButton setImage:[UIImage imageNamed:@"localbook_filter_small_delete"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteBook:) forControlEvents:UIControlEventTouchUpInside];
		deleteButton.hidden = YES;
        [self.contentView addSubview:deleteButton];
        
        
        
//        badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
//		badgeView.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
//        //[badgeView setHideWhenZero:YES];
//        [self.contentView addSubview:badgeView];
        
         updateMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_update"]];
        [updateMark setFrame:CGRectMake(-2, - 5, 70, 70)];
        [self.contentView addSubview:updateMark];
        
        
        
//        autoBuyMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        autoBuyMark.center = CGPointMake(CGRectGetMinX(self.bounds) + 10, CGRectGetMinY(self.bounds) + 10);
//        [autoBuyMark setBackgroundColor:[UIColor clearColor]];
//        [self.contentView addSubview:autoBuyMark];
        
//		autoBuyButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		autoBuyButton.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 26, self.bounds.size.width, 30);
//        [autoBuyButton setBackgroundImage:[UIImage imageNamed:@"autobuy_off"] forState:UIControlStateNormal];
//		[autoBuyButton addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventTouchUpInside];
//		[self.contentView addSubview:autoBuyButton];
        
        nameLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameLabel setFrame:CGRectMake( - 10, CGRectGetMaxY(self.bounds) - 26, self.bounds.size.width + 20, 30)];
        [nameLabel setBackgroundImage:[UIImage imageNamed:@"bookname_background"] forState:UIControlStateNormal];
        [nameLabel setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 3, 0)];
        [nameLabel.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [nameLabel setUserInteractionEnabled:NO];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setAlpha:0.9];
        [self.contentView addSubview:nameLabel];
		
		finishMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
		finishMark.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
		[finishMark setImage:[UIImage imageNamed:@"finish_mark"]];
		finishMark.hidden = YES;
		[self.contentView addSubview:finishMark];
				
//		self.autoBuy = NO;
//		self.badge = 0;
        self.bUpdate = NO;
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
			_book.cover = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Book *book = [Book findFirstByAttribute:@"uid" withValue:_book.uid inContext:localContext];
				if (book) {
					book.cover = [[NSData alloc] initWithData:UIImagePNGRepresentation(image)];
				}
			}];
			cover.image = image;
		} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
			
		}];
    }

	if (_book.name) {
		[nameLabel setTitle:[_book.name substringToIndex:MIN(_book.name.length, 4)] forState:UIControlStateNormal];
	}
    if (_book.hasNewChapters) {
		self.bUpdate = _book.hasNewChapters;
    }
	
	if ([_book.bFinish isEqualToString:BOOK_FINISH_IDENTIFIER]) {
		finishMark.hidden = NO;
	}
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
//	badgeView.hidden = _editing || _badge == 0;
//	autoBuyButton.hidden = !_editing;
    updateMark.hidden = _editing || self.bUpdate == NO;
    deleteButton.hidden = !_editing;
    if (!editing) {
        [self setCellSelected:NO];
    }
	self.alpha = _editing ? 0.5 : 1.0;
    nameLabel.hidden = _editing;
    //autoBuyMark.hidden = _editing;
}

- (void)setCellSelected:(BOOL)selected
{
	_cellSelected = selected;
//	selectedMark.hidden = !_cellSelected;
}

- (void)setBUpdate:(BOOL)bUpdate
{
    _bUpdate = bUpdate;
    updateMark.hidden = !_bUpdate;
}

//- (void)setBadge:(NSInteger)badge
//{
//	_badge = badge;
//    badgeView.value = _badge;
//}

- (void)valueChanged:(id)sender {
	[_bookCellDelegate changedValueBookCell:self];
}


- (void)deleteBook:(id)sender
{
	[_bookCellDelegate deleteBook:self];
}

//- (void)setAutoBuy:(BOOL)onOrOff
//{
//	_autoBuy = onOrOff;
//    [autoBuyMark setImage:onOrOff ? [UIImage imageNamed:@"refresh_mark"] : nil];
//    [autoBuyButton setBackgroundImage:[UIImage imageNamed:onOrOff ? @"autobuy_on" : @"autobuy_off"] forState:UIControlStateNormal];
//}

@end
