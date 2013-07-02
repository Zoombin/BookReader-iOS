//
//  BookShelfViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Book+Test.h"

#import "BookShelfViewController.h"
#import "Book.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "Chapter.h"
#import "Book.h"
//Local
#import "ReadViewController.h"
#import "ChapterViewController.h"
#import "UserDefaultsManager.h"
#import "PurchaseManager.h"
#import "BookReader.h"
#import "CoreTextViewController.h"
#import "BookCell.h"
#import "BRBooksView.h"
#import "BRBookCell.h"
#import "BookReaderDefaultsManager.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "Reachability.h"
#import "BookReader.h"
#import "BRHeaderView.h"


static NSString *kStartSyncChaptersNotification = @"start_sync_chapters";
static NSString *kStartSyncChaptersContentNotification = @"start_sync_chapters_content";
static NSString *kStartSyncAutoSubscribeNotification = @"start_sync_auto_subscribe";

@interface BookShelfViewController () <BookShelfHeaderViewDelegate,UIAlertViewDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, BRBooksViewDelegate>
@end

@implementation BookShelfViewController {
	NSMutableArray *booksForDisplay;
    NSMutableArray *books;
	NSMutableArray *chapters;
	BRBooksView *booksView;
	BOOL editing;
	NSMutableArray *needRemoveFavoriteBooks;
	UIAlertView *wifiAlert;
	BOOL syncing;
	NSMutableArray *booksStandViews;
	CGFloat startYOfStandView;
	CGFloat standViewsDistance;
//	UIImageView *backgroundImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self removeGestureRecognizer];
	booksStandViews = [NSMutableArray array];
	CGSize fullSize = self.view.bounds.size;
    
	booksView = [[BRBooksView alloc] initWithFrame:CGRectMake(0, 44, fullSize.width, fullSize.height-44)];
	booksView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	booksView.delegate = self;
	booksView.dataSource = self;
	booksView.booksViewDelegate = self;
	[[self BRHeaderView] addButtons];
	[[self BRHeaderView] setDelegate:self];
    [[self BRHeaderView] refreshUpdateButton];
	booksView.gridStyle = YES;
	[self.view addSubview:booksView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChapters) name:kStartSyncChaptersNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChaptersContent) name:kStartSyncChaptersContentNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncAutoSubscribe) name:kStartSyncAutoSubscribeNotification object:nil];
}

- (void)createStandViews:(NSInteger)number
{
	NSLog(@"create stand views");
	for (UIImageView *standView in booksStandViews) {
		[standView removeFromSuperview];
	}
	[booksStandViews removeAllObjects];
	startYOfStandView = 133;
	standViewsDistance = 109;
	for (int i = 0; i < number; i++) {
		UIImageView *standView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf"]];
		standView.frame = CGRectMake(0, standViewsDistance * i + startYOfStandView, self.view.frame.size.width, 27);
		[booksStandViews addObject:standView];
		[self.view addSubview:standView];
		[self.view sendSubviewToBack:standView];
		[self.view sendSubviewToBack:[self backgroundImage]];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kStartSyncChaptersNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kStartSyncChaptersContentNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kStartSyncAutoSubscribeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (![ServiceManager userID]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"firstlaunch", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        [alertView show];
    } else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kNeedRefreshBookShelf]) {
			stopAllSync = NO;
			[self syncBooks];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNeedRefreshBookShelf];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}
    [[self BRHeaderView] refreshUpdateButton];
	[self showBooks];
	[booksView reloadData];
}

- (void)syncBooks
{
	if (stopAllSync) return;
	//[self displayHUD:@"同步收藏..."];
	syncing = YES;
    [ServiceManager userBooksWithBlock:^(NSArray *resultArray, NSError *error) {
        if (error) {
			[self displayHUDError:nil message:error.description];
        } else {
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext  *localContext) {
				NSArray *allBooks = [Book findAllInContext:localContext];
				for (Book *b in allBooks) {
					b.bFav = NO;
				}
			} completion:^(BOOL success, NSError *error) {
				books = [resultArray mutableCopy];
				[Book persist:books withBlock:^(void) {
					[booksForDisplay removeAllObjects];
					[booksForDisplay addObjectsFromArray:books];
					[booksView reloadData];
					[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersNotification object:nil];
				}];
			}];
        }
    }];
}

- (void)syncChapters
{
	if (stopAllSync) return;
	if (books.count <= 0) {
		NSLog(@"sync chapters finished");
		[self hideHUD:YES];
		[booksView reloadData];
		[chapters removeAllObjects];
		chapters = [[Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"content=nil"]] mutableCopy];
		if (!chapters.count) {
			return;
		}
		NSLog(@"find %d chapters need download content", chapters.count);
		if([Reachability reachabilityWithHostName:@"server"].currentReachabilityStatus == ReachableViaWiFi) {
			NSLog(@"WIFI");
			[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersContentNotification object:nil];
		} else {
			NSLog(@"其他网络");
			wifiAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"当前使用的不是WiFi网络，更新章节内容将消耗较多的流量，是否更新？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
			[wifiAlert show];
		}
		return;
	}
	Book *book = books[0];
	//[self displayHUD:@"检查新章节目录..."];
	syncing = YES;
	[ServiceManager bookCatalogueList:book.uid withBlock:^(NSArray *resultArray, NSError *error) {
		if (!error) {
			[Chapter persist:resultArray withBlock:^(void) {
				[books removeObject:book];
				[self syncChapters];
			}];
        } else {
			[books removeObject:book];
            [self syncChapters];
        }
	}];
}

- (void)syncChaptersContent
{
	if (stopAllSync) return;
	if (chapters.count <= 0) {
		NSLog(@"sync chapters content finished");
		[booksView reloadData];
		[chapters removeAllObjects];
		NSArray *autoSubscribeOnBooks = [Book findAllWithPredicate:[NSPredicate predicateWithFormat:@"autoBuy=YES"]];
		NSLog(@"found %d books autoBuy is ON", autoSubscribeOnBooks.count);
		[autoSubscribeOnBooks enumerateObjectsUsingBlock:^(Book *book, NSUInteger idx, BOOL *stop) {
			[chapters addObjectsFromArray:[Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"bVip=YES AND content=nil AND bid=%@", book.uid]]];
		}];
		NSLog(@"find %d chapters need subscribe...", chapters.count);
		for (int i = 0; i < chapters.count; i++) {
			NSLog(@"%@", chapters[i]);
			if (i == 0) {
				NSLog(@"%@", ((Chapter *)(chapters[i])).content);
			}
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncAutoSubscribeNotification object:nil];
		return;
	}
	Chapter *chapter = chapters[0];
	NSLog(@"content nil chapter uid = %@ and bVIP = %@", chapter.uid, chapter.bVip);
	//[self displayHUD:@"检查自动更新中..."];
	syncing = YES;
	[ServiceManager bookCatalogue:chapter.uid VIP:chapter.bVip.boolValue withBlock:^(NSString *content, BOOL success, NSString *message, NSError *error) {
		if (content && ![content isEqualToString:@""]) {
			chapter.content = content;
			[chapter persistWithBlock:^(void) {
				[chapters removeObject:chapter];
				[self syncChaptersContent];
			}];
		} else {
			[chapters removeObject:chapter];
			[self syncChaptersContent];
		}
	}];
}

- (void)syncAutoSubscribe
{
	if (stopAllSync) return;
	if (chapters.count <= 0) {
		NSLog(@"sync auto subscribe finished");
		syncing = NO;
		[self hideHUD:YES];
		return;
	}
	Chapter *chapter = chapters[0];
	//[self displayHUD:@"自动更新中..."];
	Book *book = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", chapter.bid]];
	[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:book.authorID withBlock:^(NSString *content, NSString *message, BOOL success, NSError *error) {
		if (content && ![content isEqualToString:@""]) {
			chapter.content = content;
			[chapter persistWithBlock:^(void) {
				[chapters removeObject:chapter];
				[self syncAutoSubscribe];
			}];
		} else {
			[chapters removeObject:chapter];
			[self syncAutoSubscribe];
		}
	}];
}


- (void)syncRemoveFav
{
	if (needRemoveFavoriteBooks.count <= 0) {
		NSLog(@"no more book need to remove favorite...");
		[self hideHUD:YES];
		return;
	}
	Book *needRemoveBook = needRemoveFavoriteBooks[0];
	[ServiceManager addFavoriteWithBookID:needRemoveBook.uid On:NO withBlock:^(BOOL success, NSString *message, NSError *error) {
		if (success) {
			[needRemoveFavoriteBooks removeObject:needRemoveBook];
			[booksForDisplay removeObject:needRemoveBook];
			[booksView reloadData];
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				needRemoveBook.bFav = NO;
			} completion:^(BOOL success, NSError *error) {
				[self syncRemoveFav];
			}];
		} else {
			[self syncRemoveFav];
		}
	}];
}

- (void)showBooks
{
    booksForDisplay = [[Book findAllSortedBy:@"updateDate" ascending:NO] mutableCopy];
    [booksView reloadData];
}
- (void)headerButtonClicked:(NSNumber *)type
{
    if (type.intValue == kHeaderViewButtonBookStore) {
        [APP_DELEGATE gotoRootController:kRootControllerTypeBookStore];
    } else if (type.intValue == kHeaderViewButtonMember) {
        [APP_DELEGATE gotoRootController:kRootControllerTypeMember];
    } else if (type.intValue == kHeaderViewButtonEdit) {
		editing = YES;
		[booksView reloadData];
    } else if (type.intValue == kHeaderViewButtonDelete) {
		[self displayHUD:@"删除收藏..."];
		[self syncRemoveFav];
    } else if (type.intValue == kHeaderViewButtonFinishEditing) {
		editing = NO;
		[booksView reloadData];
    } else if (type.intValue == kHeaderViewButtonRefresh) {
		if (![ServiceManager userID]) return;
		if (!syncing) {
			[self syncBooks];
			NSLog(@"begin sync");
		} else {
			[self displayHUD:@"开始自动更新..."];
			[self performSelector:@selector(dismissHUD) withObject:nil afterDelay:3];
			[self displayHUDError:@"" message:@"开始更新..."];
			NSLog(@"already syncing");
		}
    }
}

- (void)dismissHUD
{
	[self hideHUD:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == wifiAlert && buttonIndex == 1) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersContentNotification object:nil];
	} else if (alertView != wifiAlert && buttonIndex == 0) {
        [APP_DELEGATE gotoRootController:kRootControllerTypeMember];
    }
	
}

#pragma mark - BRBooksViewDelegate
- (void)booksView:(BRBooksView *)booksView tappedBookCell:(BRBookCell *)bookCell
{
	if (editing) {
		bookCell.cellSelected = !bookCell.cellSelected;
		if (bookCell.cellSelected) {
			if (!needRemoveFavoriteBooks) needRemoveFavoriteBooks = [NSMutableArray array];
			[needRemoveFavoriteBooks addObject:bookCell.book];
		} else {
			[needRemoveFavoriteBooks removeObject:bookCell.book];
		}
        [[self BRHeaderView] deleteButtonEnable:[needRemoveFavoriteBooks count]>0 ? YES : NO];
	} else {
        [bookCell.book persistWithBlock:nil];//TODO need to this when actually start to read
		CoreTextViewController *controller = [[CoreTextViewController alloc] init];
		controller.book = bookCell.book;
        [self.navigationController pushViewController:controller animated:YES];
	}
}

- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell
{
	BOOL shiftToOnOrOff = !bookCell.autoBuy;
	NSString *message = shiftToOnOrOff ? @"开启订阅..." : @"关闭订阅...";
    [self displayHUD:message];
	[ServiceManager autoSubscribeWithBookID:bookCell.book.uid On:shiftToOnOrOff withBlock:^(BOOL success, NSError *error) {
		[self hideHUD:YES];
		if (!error) {
			bookCell.book.autoBuy = @(shiftToOnOrOff);
			[bookCell.book persistWithBlock:nil];
			bookCell.autoBuy = shiftToOnOrOff;
		}
	}];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	[self createStandViews:MAX(5, (int)ceil(booksForDisplay.count / 3) )];
	return booksForDisplay.count;
}

- (PSTCollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = booksForDisplay[indexPath.row];
	BRBookCell *cell = [booksView bookCell:book atIndexPath:indexPath];
	cell.badge = [book countOfUnreadChapters];
	cell.editing = editing;
	return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //	NSLog(@"scrollView.offset = %f", scrollView.contentOffset.y);
	for (int i = 0; i < booksStandViews.count; i++) {
		UIImageView *standView = booksStandViews[i];
		standView.frame = CGRectMake(0, standViewsDistance * i + startYOfStandView - scrollView.contentOffset.y, standView.frame.size.width, standView.frame.size.height);
	}
}
@end
