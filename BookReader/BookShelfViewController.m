//
//  BookShelfViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BookShelfViewController.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "CoreTextViewController.h"
#import "BookCell.h"
#import "BRBooksView.h"
#import "BRBookCell.h"
#import "BookDetailsViewController.h"
#import "Reachability.h"
#import "BRNotification.h"
#import "BRContextManager.h"
#import "BRShelfCategoryView.h"
#import "BRBottomView.h"

const NSUInteger minNumberOfStandView = 3;
const NSUInteger numberOfBooksPerRow = 3;

@interface BookShelfViewController () <BRShelfCategoryViewDelegate ,BookShelfHeaderViewDelegate,UIAlertViewDelegate, BRBooksViewDelegate, BRNotificationViewDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, PSTCollectionViewDelegateFlowLayout>

@property (readwrite) NSArray *booksForDisplay;
@property (readwrite) NSMutableArray *books;
@property (readwrite) NSMutableArray *chapters;
@property (readwrite) BRBooksView *booksView;
@property (readwrite) BOOL editing;
@property (readwrite) NSMutableArray *needRemoveFavoriteBooks;
@property (readwrite) UIAlertView *favAndAutoBuyAlert;
@property (readwrite) NSMutableArray *booksStandViews;
@property (readwrite)CGFloat standViewsDistance;
@property (readwrite) BRBookCell *needFavAndAutoBuyBookCell;
@property (readwrite) UIImage *standImage;
@property (readwrite) BRNotification *notification;
@property (readwrite) BRShelfCategoryView *shelfCategoryView;
@property (readwrite) BRBottomView *bottomView;

@end

@implementation BookShelfViewController

- (BOOL)isWifiAvailable
{
	Reachability *reachability = [Reachability reachabilityForLocalWiFi];
	return [reachability isReachableViaWiFi];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"书架";
	[self.headerView addButtons];
	[self.headerView setDelegate:self];
	self.hideKeyboardRecognzier.enabled = NO;
	_booksStandViews = [NSMutableArray array];
	CGSize fullSize = self.view.bounds.size;
	
	CGFloat startY = [BRHeaderView height];
    
//	shelfCategoryView = [[BRShelfCategoryView alloc] initWithFrame:CGRectMake(0, startY, fullSize.width, 60)];
//	shelfCategoryView.delegate = self;
//	[self.view addSubview:shelfCategoryView];
	
//	startY = CGRectGetMaxY(shelfCategoryView.frame);
	
	PSTCollectionViewFlowLayout *layout = [BRBooksView defaultLayout];
	_booksView = [[BRBooksView alloc] initWithFrame:CGRectMake(0, startY, fullSize.width,  fullSize.height - [BRHeaderView height] - [BRBottomView height]) collectionViewLayout:layout];
	_booksView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_booksView.delegate = self;
	_booksView.dataSource = self;
	_booksView.booksViewDelegate = self;
	[self.view addSubview:_booksView];
	
	_bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	_bottomView.bookshelfButton.selected = YES;
	[self.view addSubview:_bottomView];
	
	[self createStandViews:@(minNumberOfStandView)];
	
	[[NSNotificationCenter defaultCenter] addObserver:_bottomView selector:@selector(refresh) name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)createStandViews:(NSNumber *)number
{
	if (_booksStandViews.count == number.integerValue) {
		for (UIView *standView in _booksStandViews) {
			[_booksView sendSubviewToBack:standView];
		}
		return;
	}

	if (!_standImage) {
		_standImage = [UIImage imageNamed:@"bookshelf"];
	}
	for (UIImageView *standView in _booksStandViews) {
		[standView removeFromSuperview];
	}
	[_booksStandViews removeAllObjects];
	_standViewsDistance = 140;
	for (int i = 0; i < number.integerValue; i++) {
		UIImageView *standView = [[UIImageView alloc] initWithImage:_standImage];
		standView.frame = CGRectMake(0, _standViewsDistance * (i + 1) - _standImage.size.height, self.view.frame.size.width, _standImage.size.height);
		[_booksStandViews addObject:standView];
		[_booksView addSubview:standView];
		[_booksView sendSubviewToBack:standView];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (![ServiceManager showDialogs]) {
		[ServiceManager showDialogsSettingsByAppVersion:[NSString appVersion] withBlock:^(BOOL success, NSError *error) {
			[_bottomView refresh];
		}];
	} else {
		[_bottomView refresh];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	syncTimeInterval = SHORT_SYNC_INTERVAL;
	if (!_notification) {
		[self fetchNotification:^(void){
			[_booksView reloadData];
		}];
	}
	
	if (![ServiceManager hadLaunchedBefore]) {
		[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:HAD_LAUNCHED_BEFORE];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self recommendBooks:^(void) {
			[self refreshBooks];
			[self startSync];
		}];
    } else {
		[self refreshBooks];
		[self startSync];
	}
	
	[ShelfCategory createDefaultShelfCategoryWithCompletionBlock:^{
		_shelfCategoryView.shelfCategories = [ShelfCategory findAll];
	}];
}

- (void)viewWillDisappear:(BOOL)animated
{
	syncTimeInterval = LONG_SYNC_INTERVAL;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:_bottomView name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)startSync
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:NEED_REFRESH_BOOKSHELF]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:NEED_REFRESH_BOOKSHELF];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self syncBooks];
	}
}

- (void)fetchNotification:(dispatch_block_t)block
{
    [ServiceManager systemNotifyWithBlock:^(BOOL success, NSError *error, NSArray *resultArray, NSString *content) {
		if (success) {
            if ([resultArray count]!= 0||[content length] >0) {
                _notification = [[BRNotification alloc] init];
                _notification.books = resultArray;
                _notification.content = content;
            }
			if (block) block();
		}
    }];
}

- (void)recommendBooks:(dispatch_block_t)block
{
    [ServiceManager recommandDefaultBookwithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
		if (success) {
			_books = [resultArray mutableCopy];
			[Book persist:_books withBlock:^(void) {
				if (block) block();
			}];
		} else {
			if (block) block();
		}
    }];
}

- (void)refreshBooks
{
	_booksForDisplay = [Book allBooksOfUser:[ServiceManager userID]];
	[_booksView reloadData];
}

- (void)syncBooks
{
	if (stopAllSync) return;
	if ([ServiceManager isSessionValid]) {
		NSLog(@"start snyc books");
		[ServiceManager userBooksWithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
			if (success) {
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext  *localContext) {
					NSArray *allBooks = [Book findAllInContext:localContext];//把当前数据库中的书籍全部设置成bFav = NO;
					for (Book *b in allBooks) {
						b.bFav = NO;
					}
				} completion:^(BOOL success, NSError *error) {
					_books = [resultArray mutableCopy];
					[Book persist:_books withBlock:^(void) {
						_books = [[Book allBooksOfUser:[ServiceManager userID]] mutableCopy];
						[self refreshBooks];
					}];
				}];
			}
		}];
	} else {
		_books = [[Book allBooksOfUser:[ServiceManager userID]] mutableCopy];
		[self refreshBooks];
	}
}

- (void)syncRemoveFav
{
	if (!_needRemoveFavoriteBooks.count) {
		NSLog(@"no more book need to remove favorite...");
		[self hideHUD:YES];
		[self refreshBooks];
		return;
	}

	Book *needRemoveBook = _needRemoveFavoriteBooks[0];
	needRemoveBook = [Book findFirstByAttribute:@"uid" withValue:needRemoveBook.uid];
	[self displayHUD:@"正在删除..."];
	if (needRemoveBook.bFav) {
		[ServiceManager addFavoriteWithBookID:needRemoveBook.uid On:NO withBlock:^(BOOL success, NSError *error, NSString *message) {
			if (success) {
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					Book *b = [Book findFirstByAttribute:@"uid" withValue:needRemoveBook.uid inContext:localContext];
					if (b) {
						[b deleteInContext:localContext];
					}
				} completion:^(BOOL success, NSError *error) {
					[_needRemoveFavoriteBooks removeObject:needRemoveBook];
					[self syncRemoveFav];
				}];
			} else {
				[_needRemoveFavoriteBooks removeObject:needRemoveBook];
				[self syncRemoveFav];
			}
		}];
	} else {
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Book *b = [Book findFirstByAttribute:@"uid" withValue:needRemoveBook.uid inContext:localContext];
			if (b) {
				[b deleteInContext:localContext];
			}
		} completion:^(BOOL success, NSError *error) {
			[_needRemoveFavoriteBooks removeObject:needRemoveBook];
			[self syncRemoveFav];
		}];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == _favAndAutoBuyAlert && buttonIndex != alertView.cancelButtonIndex) {
		if (_needFavAndAutoBuyBookCell) {
			[self displayHUD:@"收藏..."];
			[ServiceManager addFavoriteWithBookID:_needFavAndAutoBuyBookCell.book.uid On:YES withBlock:^(BOOL success, NSError *error, NSString *message) {
				if (success) {
					[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
						Book *b = [Book findFirstByAttribute:@"uid" withValue:_needFavAndAutoBuyBookCell.book.uid inContext:localContext];
						if (b) {
							b.bFav = @(YES);
						}
					}];
					NSLog(@"bookuid: %@", _needFavAndAutoBuyBookCell.book.uid);
					[ServiceManager autoSubscribeWithBookID:_needFavAndAutoBuyBookCell.book.uid On:YES withBlock:^(BOOL success, NSError *error) {
						[self hideHUD:YES];
						if (success) {
							[MagicalRecord saveWithBlock:^(NSManagedObjectContext  *localContext) {
								Book *b = [Book findFirstByAttribute:@"uid" withValue:_needFavAndAutoBuyBookCell.book.uid inContext:localContext];
								if (b) {
									b.autoBuy = @(YES);
								}
							} completion:^(BOOL success, NSError *error) {
								[self refreshBooks];
							}];
						} else {
							[self refreshBooks];
						}
					}];
				} else {
					[self hideHUD:YES];
					[self displayHUDTitle:@"错误" message:message];
				}
			}];
		}
	}
}

#pragma mark - BRHeaderViewDelegate

- (void)headerButtonClicked:(NSNumber *)type
{
    if (type.intValue == kHeaderViewButtonBookStore) {
        [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookStore];
    } else if (type.intValue == kHeaderViewButtonMember) {
        [APP_DELEGATE gotoRootController:kRootControllerIdentifierMember];
    } else if (type.intValue == kHeaderViewButtonEdit) {
		_editing = YES;
		[_booksView reloadData];
    } else if (type.intValue == kHeaderViewButtonDelete) {
		[self displayHUD:@"删除收藏..."];
		[self syncRemoveFav];
    } else if (type.intValue == kHeaderViewButtonFinishEditing) {
		_editing = NO;
		[_booksView reloadData];
    }
}

- (void)dismissHUD
{
	[self hideHUD:YES];
}

#pragma mark - BRBooksViewDelegate
- (void)booksView:(BRBooksView *)booksView tappedBookCell:(BRBookCell *)bookCell
{
	if (!_editing) {
		Chapter *chapter = [Chapter lastReadChapterOfBook:bookCell.book];
        bookCell.bUpdate = NO;
		if (chapter) {
			CoreTextViewController *controller = [[CoreTextViewController alloc] init];
			controller.previousViewController = self;
			controller.chapter = chapter;
			[self.navigationController pushViewController:controller animated:YES];
		} else {
			[self displayHUD:@"获取章节目录..."];
			[ServiceManager getDownChapterList:bookCell.book.uid andUserid:[[ServiceManager userID] stringValue] withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
				if (success) {
					[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
						Book *b = [Book findFirstByAttribute:@"uid" withValue:bookCell.book.uid inContext:localContext];
						if (b) {
							if (forbidden) {
								[b deleteInContext:localContext];
							} else {
								b.nextUpdateTime = nextUpdateTime;
								NSUInteger newChaptersCount = resultArray.count;
								NSUInteger allUnreaderChaptersCount = newChaptersCount + b.numberOfUnreadChapters.integerValue;
								b.numberOfUnreadChapters = @(allUnreaderChaptersCount);
							}
						}
					} completion:^(BOOL success, NSError *error) {
						[Chapter persist:resultArray withBlock:^(void) {
							[self hideHUD:YES];
							CoreTextViewController *controller = [[CoreTextViewController alloc] init];
							controller.chapter = [Chapter lastReadChapterOfBook:bookCell.book];
							controller.chapters = resultArray;
							controller.previousViewController = self;
							[self.navigationController pushViewController:controller animated:YES];
						}];
					}];
				} else {
					[self displayHUDTitle:@"无法阅读" message:@"获取章节目录错误"];
				}
			}];
		}
	}
}

- (void)booksView:(BRBooksView *)booksView deleteBookCell:(BRBookCell *)bookCell
{
	if (!_needRemoveFavoriteBooks) _needRemoveFavoriteBooks = [NSMutableArray array];
	[_needRemoveFavoriteBooks addObject:bookCell.book];
	[self syncRemoveFav];
}

- (NSNumber *)numberOfRows
{
	NSUInteger numberOfRows = (int)ceil((CGFloat)_booksForDisplay.count / numberOfBooksPerRow);
	numberOfRows += [_notification shouldDisplay] ? 1 : 0;
	numberOfRows = MAX(minNumberOfStandView, numberOfRows);
	return @(numberOfRows);
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _booksForDisplay.count;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = _booksForDisplay[indexPath.row];
	BRBookCell *cell = [_booksView bookCell:book atIndexPath:indexPath];
	cell.editing = _editing;
	
	if (indexPath.row == _booksForDisplay.count - 1) {
		[self createStandViews:[self numberOfRows]];
	}
	return cell;
}

- (PSTCollectionReusableView *)collectionView:(PSTCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = nil;
	
	if ([kind isEqualToString:PSTCollectionElementKindSectionHeader]) {
		identifier = collectionHeaderViewIdentifier;
	}

    PSTCollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
	if ([supplementaryView isKindOfClass:[BRNotificationView class]]) {
		BRNotificationView *notificationView = (BRNotificationView *)supplementaryView;
		notificationView.delegate = self;
		if (_notification) {
			notificationView.notification = _notification;
		}
	}
    return supplementaryView;
}

- (CGSize)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (_notification && [_notification shouldDisplay]) {
		return CGSizeMake(_booksView.frame.size.width, 120);
	}
	return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	CGFloat top = 30;
	if (_notification && [_notification shouldDisplay]) {
		top = 50;
	}
	if ([self numberOfRows].integerValue <= minNumberOfStandView) {
		NSUInteger numberOfRows = (int)ceil((CGFloat)_booksForDisplay.count / numberOfBooksPerRow);
		CGFloat bottom = 245 - _standViewsDistance * (numberOfRows - 1);
		if (top == 30) {
			bottom += 140;
		}
		if (![UIDevice is4Inch]) {
			bottom -= ( [UIDevice heightOf4Inch] - [UIDevice heightOf3dot5Inch] );
		}
		return UIEdgeInsetsMake(top, 25, bottom, 25);
	}
	return UIEdgeInsetsMake(top, 25, 20, 25);
}

#pragma mark - NotificationViewDelegate

- (void)willRead:(Book *)book
{
	BookDetailsViewController *bookDetailsViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
	[self.navigationController pushViewController:bookDetailsViewController animated:YES];
	[_booksView reloadData];
}

- (void)willClose
{
	[_booksView reloadData];
}

#pragma mark - BRShelfCategoryViewDelegate

- (void)shelfCategoryTapped:(ShelfCategory *)shelfCategory
{
	NSLog(@"shelfCategory: %@", shelfCategory);
}

- (void)editShelfCategories
{
	NSLog(@"editShelfCategories");
}

- (void)shelfCategoryViewResize:(CGSize)newSize
{
	//booksView = [[BRBooksView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(shelfCategoryView.frame), fullSize.width,  fullSize.height - CGRectGetMaxY(shelfCategoryView.frame)) collectionViewLayout:layout];
//	booksView.frame =
}

@end
