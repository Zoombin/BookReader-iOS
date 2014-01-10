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
@end

@implementation BookShelfViewController {
	NSArray *booksForDisplay;
    NSMutableArray *books;
	NSMutableArray *chapters;
	BRBooksView *booksView;
	BOOL editing;
	NSMutableArray *needRemoveFavoriteBooks;
	UIAlertView *favAndAutoBuyAlert;
	NSMutableArray *booksStandViews;
	CGFloat standViewsDistance;

	BRBookCell *needFavAndAutoBuyBookCell;
	UIImage *standImage;
	BRNotification *notification;
	BRShelfCategoryView *shelfCategoryView;
	BRBottomView *bottomView;
}

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
	booksStandViews = [NSMutableArray array];
	CGSize fullSize = self.view.bounds.size;
	
	CGFloat startY = [BRHeaderView height];
    
//	shelfCategoryView = [[BRShelfCategoryView alloc] initWithFrame:CGRectMake(0, startY, fullSize.width, 60)];
//	shelfCategoryView.delegate = self;
//	[self.view addSubview:shelfCategoryView];
	
//	startY = CGRectGetMaxY(shelfCategoryView.frame);
	
	PSTCollectionViewFlowLayout *layout = [BRBooksView defaultLayout];
	booksView = [[BRBooksView alloc] initWithFrame:CGRectMake(0, startY, fullSize.width,  fullSize.height - [BRHeaderView height] - [BRBottomView height]) collectionViewLayout:layout];
	booksView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	booksView.delegate = self;
	booksView.dataSource = self;
	booksView.booksViewDelegate = self;
	[self.view addSubview:booksView];
	
	bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	bottomView.bookshelfButton.selected = YES;
	[self.view addSubview:bottomView];
	
	[self createStandViews:@(minNumberOfStandView)];
}

- (void)createStandViews:(NSNumber *)number
{
	if (booksStandViews.count == number.integerValue) {
		for (UIView *standView in booksStandViews) {
			[booksView sendSubviewToBack:standView];
		}
		return;
	}

	if (!standImage) {
		standImage = [UIImage imageNamed:@"bookshelf"];
	}
	for (UIImageView *standView in booksStandViews) {
		[standView removeFromSuperview];
	}
	[booksStandViews removeAllObjects];
	standViewsDistance = 140;
	for (int i = 0; i < number.integerValue; i++) {
		UIImageView *standView = [[UIImageView alloc] initWithImage:standImage];
		standView.frame = CGRectMake(0, standViewsDistance * (i + 1) - standImage.size.height, self.view.frame.size.width, standImage.size.height);
		[booksStandViews addObject:standView];
		[booksView addSubview:standView];
		[booksView sendSubviewToBack:standView];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[bottomView refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	syncTimeInterval = SHORT_SYNC_INTERVAL;
	if (!notification) {
		[self fetchNotification:^(void){
			[booksView reloadData];
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
		shelfCategoryView.shelfCategories = [ShelfCategory findAll];
	}];
}

- (void)viewWillDisappear:(BOOL)animated
{
	syncTimeInterval = LONG_SYNC_INTERVAL;
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
                notification = [[BRNotification alloc] init];
                notification.books = resultArray;
                notification.content = content;
            }
			if (block) block();
		}
    }];
}

- (void)recommendBooks:(dispatch_block_t)block
{
    [ServiceManager recommandDefaultBookwithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
		if (success) {
			books = [resultArray mutableCopy];
			[Book persist:books withBlock:^(void) {
				if (block) block();
			}];
		} else {
			if (block) block();
		}
    }];
}

- (void)refreshBooks
{
	booksForDisplay = [Book allBooksOfUser:[ServiceManager userID]];
	[booksView reloadData];
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
					books = [resultArray mutableCopy];
					[Book persist:books withBlock:^(void) {
						books = [[Book allBooksOfUser:[ServiceManager userID]] mutableCopy];
						[self refreshBooks];
					}];
				}];
			}
		}];
	} else {
		books = [[Book allBooksOfUser:[ServiceManager userID]] mutableCopy];
		[self refreshBooks];
	}
}

- (void)syncRemoveFav
{
	if (!needRemoveFavoriteBooks.count) {
		NSLog(@"no more book need to remove favorite...");
		[self hideHUD:YES];
		[self refreshBooks];
		return;
	}

	Book *needRemoveBook = needRemoveFavoriteBooks[0];
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
					[needRemoveFavoriteBooks removeObject:needRemoveBook];
					[self syncRemoveFav];
				}];
			} else {
				[needRemoveFavoriteBooks removeObject:needRemoveBook];
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
			[needRemoveFavoriteBooks removeObject:needRemoveBook];
			[self syncRemoveFav];
		}];
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == favAndAutoBuyAlert && buttonIndex != alertView.cancelButtonIndex) {
		if (needFavAndAutoBuyBookCell) {
			[self displayHUD:@"收藏..."];
			[ServiceManager addFavoriteWithBookID:needFavAndAutoBuyBookCell.book.uid On:YES withBlock:^(BOOL success, NSError *error, NSString *message) {
				if (success) {
					[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
						Book *b = [Book findFirstByAttribute:@"uid" withValue:needFavAndAutoBuyBookCell.book.uid inContext:localContext];
						if (b) {
							b.bFav = @(YES);
						}
					}];
					NSLog(@"bookuid: %@", needFavAndAutoBuyBookCell.book.uid);
					[ServiceManager autoSubscribeWithBookID:needFavAndAutoBuyBookCell.book.uid On:YES withBlock:^(BOOL success, NSError *error) {
						[self hideHUD:YES];
						if (success) {
							[MagicalRecord saveWithBlock:^(NSManagedObjectContext  *localContext) {
								Book *b = [Book findFirstByAttribute:@"uid" withValue:needFavAndAutoBuyBookCell.book.uid inContext:localContext];
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
		editing = YES;
		[booksView reloadData];
    } else if (type.intValue == kHeaderViewButtonDelete) {
		[self displayHUD:@"删除收藏..."];
		[self syncRemoveFav];
    } else if (type.intValue == kHeaderViewButtonFinishEditing) {
		editing = NO;
		[booksView reloadData];
    }
}

- (void)dismissHUD
{
	[self hideHUD:YES];
}

#pragma mark - BRBooksViewDelegate
- (void)booksView:(BRBooksView *)booksView tappedBookCell:(BRBookCell *)bookCell
{
	if (!editing) {
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
	if (!needRemoveFavoriteBooks) needRemoveFavoriteBooks = [NSMutableArray array];
	[needRemoveFavoriteBooks addObject:bookCell.book];
	[self syncRemoveFav];
}

- (NSNumber *)numberOfRows
{
	NSUInteger numberOfRows = (int)ceil((CGFloat)booksForDisplay.count / numberOfBooksPerRow);
	numberOfRows += [notification shouldDisplay] ? 1 : 0;
	numberOfRows = MAX(minNumberOfStandView, numberOfRows);
	return @(numberOfRows);
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return booksForDisplay.count;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = booksForDisplay[indexPath.row];
	BRBookCell *cell = [booksView bookCell:book atIndexPath:indexPath];
	cell.editing = editing;
	
	if (indexPath.row == booksForDisplay.count - 1) {
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
		if (notification) {
			notificationView.notification = notification;
		}
	}
    return supplementaryView;
}

- (CGSize)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (notification && [notification shouldDisplay]) {
		return CGSizeMake(booksView.frame.size.width, 120);
	}
	return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	CGFloat top = 30;
	if (notification && [notification shouldDisplay]) {
		top = 50;
	}
	if ([self numberOfRows].integerValue <= minNumberOfStandView) {
		NSUInteger numberOfRows = (int)ceil((CGFloat)booksForDisplay.count / numberOfBooksPerRow);
		CGFloat bottom = 245 - standViewsDistance * (numberOfRows - 1);
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
	[booksView reloadData];
}

- (void)willClose
{
	[booksView reloadData];
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
