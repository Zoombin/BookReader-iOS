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
#import "HandleGBString.h"
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
}
@synthesize layoutStyle;

- (void)viewDidLoad
{
    [super viewDidLoad];
	booksView = [[BRBooksView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 44)];
	booksView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	booksView.dataSource = self;
	booksView.booksViewDelegate = self;
	if (layoutStyle == kBookShelfLayoutStyleShelfLike) {
		[self loadRemoteView];
		booksView.gridStyle = YES;
	} else {
		booksView.gridStyle = NO;
		//TODO: remote and local should be same style
		//[self loadLocalView];
	}
	[self.view addSubview:booksView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChapters) name:kStartSyncChaptersNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChaptersContent) name:kStartSyncChaptersContentNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncAutoSubscribe) name:kStartSyncAutoSubscribeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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
		booksForDisplay = [[Book findAllAndSortedByDate] mutableCopy];
		[booksView reloadData];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kNeedRefreshBookShelf]) {
			[self syncBooks];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNeedRefreshBookShelf];
		}
	}
}

- (void)syncBooks
{
	[self displayHUD:@"获取用户书架中..."];
    [ServiceManager userBooksWithSize:@"5000" andIndex:@"1" withBlock:^(NSArray *result, NSError *error) {
		[self hideHUD:YES];
        if (error) {
			[self displayHUDError:nil message:error.description];
        }else {
			books = [result mutableCopy];
			[Book persist:books withBlock:^(void) {
				[booksForDisplay removeAllObjects];
				[booksForDisplay addObjectsFromArray:books];
				[booksView reloadData];
				[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersNotification object:nil];
			}];
        }
    }];
}

- (void)syncChapters
{
	if (books.count <= 0) {
		NSLog(@"sync chapters finished");
		[booksView reloadData];
		chapters = [[Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"content=nil"]] mutableCopy];
		NSLog(@"find %d chapters need download content", chapters.count);
		[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersContentNotification object:nil];
		return;
	}
	Book *book = books[0];
	[ServiceManager bookCatalogueList:book.uid andNewestCataId:@"0" withBlock:^(NSArray *result, NSError *error) {
		if (!error) {
			[Chapter persist:result withBlock:^(void) {
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
		NSLog(@"autoSubscribeOnBooks = %@", autoSubscribeOnBooks);
		[autoSubscribeOnBooks enumerateObjectsUsingBlock:^(Book *book, NSUInteger idx, BOOL *stop) {
			[chapters addObjectsFromArray:[Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"bVip=YES AND content=nil AND bid=%@", book.uid]]];
			NSLog(@"find some chapters need auto subscribe");
		}];
		NSLog(@"find %d chapters", chapters.count);
		[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncAutoSubscribeNotification object:nil];
		return;
	}
	Chapter *chapter = chapters[0];
		//NSLog(@"content nil chapter uid = %@", chapter.uid);
		[ServiceManager bookCatalogue:chapter.uid withBlock:^(NSString *content, NSString *result, NSString *code, NSError *error) {
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
	[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:book.authorID andPrice:@"0" withBlock:^(NSString *content, NSString *errorMessage, NSString *result, NSError *error) {
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

- (void)removeFav:(NSInteger)idx
{
	static NSMutableIndexSet *needRemoveIndexes;
	if (!needRemoveIndexes) {
		needRemoveIndexes = [[NSMutableIndexSet alloc] init];
	}
	if (idx >= books.count) {
		[books removeObjectsAtIndexes:needRemoveIndexes];
		[needRemoveIndexes removeAllIndexes];
		[booksView reloadData];
		//TODO: need delete in database
		return;
	}
	BRBookCell *bookCell = (BRBookCell *)[booksView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
	if (bookCell.cellSelected) {
		[self displayHUD:[NSString stringWithFormat:@"删除收藏:%@", bookCell.book.name]];
		[ServiceManager addFavouriteWithBookID:bookCell.book.uid andValue:NO withBlock:^(NSString *errorMessage, NSString *result, NSError *error) {
			[self hideHUD:YES];
			if ([result isEqualToString:SUCCESS_FLAG]) {
				[needRemoveIndexes addIndex:idx];
				[self removeFav:idx + 1];
			}
		}];
	} else {
		[self removeFav:idx + 1];
	}
}

- (void)bottomButtonClicked:(NSNumber *)type {
    if (type.intValue == kBottomViewButtonEdit) {
		editing = YES;
		[booksView reloadData];
    }
    else if (type.intValue == kBottomViewButtonDelete)
    {
		[self removeFav:0];
    } else if (type.intValue == kBottomViewButtonFinishEditing) {
		editing = NO;
		[booksView reloadData];
    }
    else if (type.intValue == kBottomViewButtonRefresh) {
        //[self refreshUserBooksAndDownload];
    }
    else if (type.intValue == kBottomViewButtonShelf) {
        headerView.titleLabel.text = @"我的收藏";
    }
    else if (type.intValue == kBottomViewButtonBookHistoroy) {
        headerView.titleLabel.text = @"阅读历史";
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

//- (void)loadLocalView {
//    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headerImageViewFrame];
//    [headerImageView setImage:[UIImage imageNamed:@"main_headerbackground.png"]];
//    [self.view addSubview:headerImageView];
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
//    [titleLabel setText:NSLocalizedString(@"BookList", nil)];
//    [titleLabel setTextColor:txtColor];
//    [titleLabel setBackgroundColor:[UIColor clearColor]];
//    [titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
//    [self.view addSubview:titleLabel];
//    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_background.png"]];
//    UITableView *infoTableView = [[UITableView alloc] initWithFrame:infoTableViewFrame style:UITableViewStylePlain];
//    [infoTableView setDataSource:self];
//    [infoTableView setDelegate:self];
//    [infoTableView setBackgroundView:backgroundView];
//    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.view addSubview:infoTableView];
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
    }
}

- (void)loadRemoteView {
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"iphone_qqreader_Center_icon_bg"]];
    [self.view addSubview:backgroundImage];
    
    headerView = [[BookShelfHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [headerView setDelegate:self];
    [self.view addSubview:headerView];
    
    bottomView = [[BookShelfBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 44, self.view.bounds.size.width, 44)];
    [bottomView setDelegate:self];
    [self.view addSubview:bottomView];
}

#pragma mark - BRBooksViewDelegate
- (void)booksView:(BRBooksView *)booksView tappedBookCell:(BRBookCell *)bookCell
{
	if (editing) {
		bookCell.cellSelected = !bookCell.cellSelected;
	} else {
        bookCell.book.rDate = [NSDate date];
        [bookCell.book persistWithBlock:nil];
        [self.navigationController pushViewController:[[CoreTextViewController alloc] initWithBook:bookCell.book chapter:nil chaptersArray:nil andOnline:NO] animated:YES];
	}
}

- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell
{
	BOOL shiftToOnOrOff = !bookCell.autoBuy;
	NSString *message = shiftToOnOrOff ? @"开启订阅..." : @"关闭订阅...";
		[self displayHUD:message];
	[ServiceManager autoSubscribeWithBookID:bookCell.book.uid andValue:shiftToOnOrOff ? @"1" : @"0" withBlock:^(NSString *result, NSError *error) {
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
	//return books.count;
}

- (PSTCollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = booksForDisplay[indexPath.row];
	BRBookCell *cell = [booksView bookCell:book atIndexPath:indexPath];
	cell.badge = [book countOfUnreadChapters];
	cell.editing = editing;
	return cell;
}

@end
