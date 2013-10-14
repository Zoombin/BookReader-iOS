//
//  BRBookCell.m
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRBookCell.h"
#import "UIImageView+AFNetworking.h"
#import "ServiceManager.h"

@implementation BRBookCell {
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
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0, 100, 100)];
        deleteButton.center = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds) + 5);
		[deleteButton setImage:[UIImage imageNamed:@"localbook_filter_small_delete"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteBook:) forControlEvents:UIControlEventTouchUpInside];
		deleteButton.hidden = YES;
        [self.contentView addSubview:deleteButton];
        
         updateMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_update"]];
        [updateMark setFrame:CGRectMake(-2, - 5, 70, 70)];
        [self.contentView addSubview:updateMark];
        
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
    updateMark.hidden = _editing || self.bUpdate == NO;
    deleteButton.hidden = !_editing;
    if (!editing) {
        [self setCellSelected:NO];
    }
	self.alpha = _editing ? 0.5 : 1.0;
    nameLabel.hidden = _editing;
	
	if (_editing) {
		finishMark.hidden = YES;
	}
}

- (void)setCellSelected:(BOOL)selected
{
	_cellSelected = selected;
}

- (void)setBUpdate:(BOOL)bUpdate
{
    _bUpdate = bUpdate;
    updateMark.hidden = !_bUpdate;
}

- (void)deleteBook:(id)sender
{
	[_bookCellDelegate deleteBook:self];
}

@end
