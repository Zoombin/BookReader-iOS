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
#import "BookManager.h"
#import "ChapterViewController.h"
#import "UserDefaultsManager.h"
#import "PurchaseManager.h"
#import "BookReader.h"
#import "CoreTextViewController.h"
#import "SubscribeViewController.h"
#import "BookCell.h"
#import "BRBooksView.h"
#import "BRBookCell.h"
#import "BookReaderDefaultsManager.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"

static NSString *kStartSyncChaptersNotification = @"start_sync_chapters";
static NSString *kStartSyncChaptersContentNotification = @"start_sync_chapters_content";
static NSString *kStartSyncAutoSubscribeNotification = @"start_sync_auto_subscribe";

@interface BookShelfViewController () <BookShelfHeaderViewDelegate,BookShelfBottomViewDelegate,UIAlertViewDelegate, PSUICollectionViewDataSource, BRBooksViewDelegate>
@end

@implementation BookShelfViewController {
	NSMutableArray *booksForDisplay;
    NSMutableArray *books;
	NSMutableArray *chapters;
    BookShelfHeaderView *headerView;
    BookShelfBottomView *bottomView;
	BRBooksView *booksView;
	BOOL editing;
	BOOL displayingHistory;
	NSMutableArray *needRemoveFavoriteBooks;
}
@synthesize layoutStyle;

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"iphone_qqreader_Center_icon_bg"]];
    [self.view addSubview:backgroundImage];
	
	booksView = [[BRBooksView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 44)];
	booksView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	booksView.dataSource = self;
	booksView.booksViewDelegate = self;
	if (layoutStyle == kBookShelfLayoutStyleShelfLike) {
		headerView = [[BookShelfHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
		[headerView setDelegate:self];
		[self.view addSubview:headerView];
		
		bottomView = [[BookShelfBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 44, self.view.bounds.size.width, 44)];
		[bottomView setDelegate:self];
		[self.view addSubview:bottomView];
		booksView.gridStyle = YES;
	} else {
		booksView.gridStyle = NO;
		//TODO: remote and local should be same style
	}
	[self.view addSubview:booksView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChapters) name:kStartSyncChaptersNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChaptersContent) name:kStartSyncChaptersContentNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncAutoSubscribe) name:kStartSyncAutoSubscribeNotification object:nil];
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
		//TODO
		//switch to history and display history
    } else {
		if (displayingHistory) {
			booksForDisplay = [[Book findAllHistory] mutableCopy];
		} else {
			booksForDisplay = [[Book findAllFavorite] mutableCopy];
		}
		[booksView reloadData];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kNeedRefreshBookShelf]) {
			[self syncBooks];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNeedRefreshBookShelf];
		}
	}
}

- (void)syncBooks
{
	[self displayHUD:@"同步收藏..."];
    [ServiceManager userBooksWithBlock:^(NSArray *resultArray, NSError *error) {
		[self hideHUD:YES];
        if (error) {
			[self displayHUDError:nil message:error.description];
        }else {
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
					[self displayHUD:@"检查新章节目录..."];
					[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersNotification object:nil];
				}];
			}];
        }
    }];
}

- (void)syncChapters
{
	if (books.count <= 0) {
		NSLog(@"sync chapters finished");
		[self hideHUD:YES];
		[booksView reloadData];
		[chapters removeAllObjects];
		chapters = [[Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"content=nil"]] mutableCopy];
		NSLog(@"find %d chapters need download content", chapters.count);
//		NSLog(@"chapters = %@", ((Chapter *)chapters[0]).content);
		[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersContentNotification object:nil];
		return;
	}
	Book *book = books[0];
	[ServiceManager bookCatalogueList:book.uid andNewestCataId:@"0" withBlock:^(NSArray *resultArray, NSError *error) {
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
		[ServiceManager bookCatalogue:chapter.uid withBlock:^(NSString *content, NSString *code, NSString *resultMessage, NSError *error) {
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
	if (chapters.count <= 0) {
		NSLog(@"sync auto subscribe finished");
//		[booksView reloadData];//TODO:do i need to reloaddata? seems noting need to be changed in UI
		return;//nothing to do any more
	}
	Chapter *chapter = chapters[0];
	Book *book = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", chapter.bid]];
	[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:book.authorID withBlock:^(NSString *content, NSString *resultMessage, NSString *code, NSError *error) {
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
	[ServiceManager addFavoriteWithBookID:needRemoveBook.uid On:NO withBlock:^(NSString *code, NSString *resultMessage, NSError *error) {
		if ([code isEqualToString:SUCCESS_FLAG]) {
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

- (void)bottomButtonClicked:(NSNumber *)type {
    if (type.intValue == kBottomViewButtonEdit) {
		editing = YES;
		[booksView reloadData];
    }
    else if (type.intValue == kBottomViewButtonDelete)
    {
		[self displayHUD:@"删除收藏..."];
		[self syncRemoveFav];
    } else if (type.intValue == kBottomViewButtonFinishEditing) {
		editing = NO;
		[booksView reloadData];
    }
    else if (type.intValue == kBottomViewButtonRefresh) {
		[self syncBooks];
    }
    else if (type.intValue == kBottomViewButtonShelf) {
        headerView.titleLabel.text = @"我的收藏";
		booksForDisplay = [[Book findAllFavorite] mutableCopy];
		[booksView reloadData];
		displayingHistory = NO;
    }
    else if (type.intValue == kBottomViewButtonBookHistoroy) {
        headerView.titleLabel.text = @"阅读历史";
		booksForDisplay = [[Book findAllHistory] mutableCopy];
		[booksView reloadData];
		displayingHistory = YES;
    }
}

- (void)headerButtonClicked:(NSNumber *)type
{
    if (type.intValue == kHeaderViewButtonBookStore)
    {
        [APP_DELEGATE switchToRootController:kRootControllerTypeBookStore];
    }
    else if (type.intValue == kHeaderViewButtonMember)
    {
        [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
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
	} else {
        bookCell.book.rDate = [NSDate date];
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
	[ServiceManager autoSubscribeWithBookID:bookCell.book.uid On:shiftToOnOrOff withBlock:^(NSString *code, NSError *error) {
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
	return booksForDisplay.count;
}

- (PSTCollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = booksForDisplay[indexPath.row];
	BRBookCell *cell = [booksView bookCell:book atIndexPath:indexPath];
	cell.editing = editing;
	return cell;
}

@end
