//
//  BRBooksView.m
//  BookReader
//
//  Created by zhangbin on 5/4/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "BRBooksView.h"
#import "BRBookCell.h"
#import "Book.h"

#define CELL_REUSE_IDENTIFIER @"BOOK"

@interface BRBooksView () <PSUICollectionViewDelegate, BRBookCellDelegate>

@end

@implementation BRBooksView
{
	PSUICollectionViewFlowLayout *listLayout;
	PSUICollectionViewFlowLayout *gridLayout;
}

- (id)initWithFrame:(CGRect)frame
{	
	PSUICollectionViewFlowLayout *_listLayout = [[PSUICollectionViewFlowLayout alloc] init];
	_listLayout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	_listLayout.itemSize = CGSizeMake(self.bounds.size.width, 100);
	_listLayout.minimumInteritemSpacing = 0;
	_listLayout.minimumLineSpacing = 1;
	_listLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
	
	PSUICollectionViewFlowLayout *_gridLayout = [[PSUICollectionViewFlowLayout alloc] init];
	_gridLayout.scrollDirection = PSTCollectionViewScrollDirectionVertical;
	_gridLayout.itemSize = CGSizeMake(70, 89);
	_gridLayout.minimumInteritemSpacing = 11;
	_gridLayout.minimumLineSpacing = 20;
	_gridLayout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 30);
	
    self = [super initWithFrame:frame collectionViewLayout:_gridLayout];
    if (self) {
		_gridStyle = YES;
		listLayout = _listLayout;
		gridLayout = _gridLayout;
		self.showsVerticalScrollIndicator = NO;
		self.backgroundColor = [UIColor clearColor];
		[self registerClass:[BRBookCell class] forCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER];
		self.delegate = self;
		self.allowsSelection = NO;
		UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		[self addGestureRecognizer:tapRecognizer];
	}
	return self;
}

- (void)setGridStyle:(BOOL)gridStyle
{
	if (_gridStyle == gridStyle) return;
	_gridStyle = gridStyle;
	PSUICollectionViewFlowLayout *layout = _gridStyle ? gridLayout : listLayout;
	[self setCollectionViewLayout:layout animated:YES];
}

- (BRBookCell *)bookCell:(Book *)book atIndexPath:(NSIndexPath *)indexPath
{
	BRBookCell *cell = [self dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
	cell.bookCellDelegate = self;
	[cell setBook:book];
	return cell;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded) {
		CGPoint initialPinchPoint = [gesture locationInView:self];
		NSIndexPath *indexPath = [self indexPathForItemAtPoint:initialPinchPoint];
		if (indexPath) {
			BRBookCell *cell = (BRBookCell *)[self cellForItemAtIndexPath:indexPath];
			[self.booksViewDelegate booksView:self tappedBookCell:cell];
		}
	}
}

#pragma mark - BRBookCellDelegate
- (void)changedValueBookCell:(BRBookCell *)bookCell
{
	[self.booksViewDelegate booksView:self changedValueBookCell:bookCell];
}

@end
