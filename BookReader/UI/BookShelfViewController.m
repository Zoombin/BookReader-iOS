//
//  BookShelfViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BookShelfViewController.h"
#import "Book.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "Chapter.h"
#import "Book.h"
#import "LoginReminderView.h"
#import "CoreTextViewController.h"
#import "BookCell.h"
#import "BRBooksView.h"
#import "BRBookCell.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "BookDetailsViewController.h"
#import "Reachability.h"

@interface BookShelfViewController () <BookShelfHeaderViewDelegate,UIAlertViewDelegate, PSTCollectionViewDataSource, PSTCollectionViewDelegate, BRBooksViewDelegate>
@end

@implementation BookShelfViewController {
	NSArray *booksForDisplay;
    NSMutableArray *books;
	NSMutableArray *chapters;
	BRBooksView *booksView;
	BOOL editing;
	NSMutableArray *needRemoveFavoriteBooks;
	UIAlertView *favAndAutoBuyAlert;
	BOOL syncing;
	NSMutableArray *booksStandViews;
	CGFloat startYOfStandView;
	CGFloat standViewsDistance;
    
    LoginReminderView *_loginReminderView;
	BRBookCell *needFavAndAutoBuyBookCell;
    NotificationView *notificationView;
}

- (BOOL)isWifi
{
	Reachability *reachability = [Reachability reachabilityForLocalWiFi];
	return [reachability isReachableViaWiFi];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"书架";
	self.hideKeyboardRecognzier.enabled = NO;
	booksStandViews = [NSMutableArray array];
	CGSize fullSize = self.view.bounds.size;
    
    notificationView = [[NotificationView alloc] initWithFrame:CGRectMake(30, 60, fullSize.width - 60, 85)];
    [notificationView setDelegate:self];
    [self.view addSubview:notificationView];
    [notificationView setHidden:YES];
    
	booksView = [[BRBooksView alloc] initWithFrame:CGRectMake(0, BRHeaderView.height, fullSize.width, fullSize.height - BRHeaderView.height)];
	booksView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	booksView.delegate = self;
	booksView.dataSource = self;
	booksView.booksViewDelegate = self;
	[self.headerView addButtons];
	[self.headerView setDelegate:self];
	booksView.gridStyle = YES;
	[self.view addSubview:booksView];
}

- (LoginReminderView *)loginReminderView {
	if (!_loginReminderView) {
		_loginReminderView = [[LoginReminderView alloc] initWithFrame:CGRectMake(10, 38, self.view.frame.size.width - 20, 18)];
		[self.view addSubview:_loginReminderView];
	}
	[_loginReminderView reset];
	return _loginReminderView;
}


- (void)createStandViews:(NSInteger)number
{
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
		[self.view sendSubviewToBack:self.backgroundView];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self loginReminderView].hidden = [ServiceManager isSessionValid];
	
    if (notificationView.bShouldLoad) {
        [self showNotificationInfo];
    }
	
	if (![ServiceManager hadLaunchedBefore]) {
		[self recommendBooks:^(void) {
			[self startSync];
		}];
    } else {
		[self refreshBooks];
		[self startSync];
	}
}

- (void)startSync
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:NEED_REFRESH_BOOKSHELF]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:NEED_REFRESH_BOOKSHELF];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self syncBooks];
	}
}

- (void)showNotificationInfo
{
    [ServiceManager systemNotifyWithBlock:^(BOOL success, NSError *error, NSArray *resultArray, NSString *content) {
		if (success) {
			notificationView.hidden = NO;
            Book *book = nil;
            if (resultArray.count > 0) {
                book = resultArray[0];
            }
            if ([ServiceManager checkHasShowNotifi:book.describe] || [ServiceManager checkHasShowNotifi:content]) {
                notificationView.hidden = YES;
                return;
            }
            CGSize fullSize = self.view.bounds.size;
            [booksView setFrame:CGRectMake(0, CGRectGetMaxY(notificationView.frame) + 5, fullSize.width, fullSize.height - BRHeaderView.height - 85)];
            [notificationView showInfoWithBook:book andNotificateContent:content];
		} else {
			if (resultArray.count == 0 && content.length == 0) {
                notificationView.hidden = YES;
                NSLog(@"无公告和推荐");
            }
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
	if ([ServiceManager isSessionValid]) {
		syncing = YES;
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
						[self syncChapters];
					}];
				}];
			}
		}];
	} else {
		books = [[Book allBooksOfUser:[ServiceManager userID]] mutableCopy];
		[self syncChapters];
	}
}

- (void)syncChapters
{
	if (!books.count) {
		NSLog(@"sync chapters finished");
		syncing = NO;
		[self refreshBooks];
		[chapters removeAllObjects];
		chapters = [[Chapter chaptersNeedFetchContentWhenWifiReachable:[self isWifi]] mutableCopy];
		NSLog(@"find %d chapters need download content", chapters.count);
		[self syncChaptersContent];
		return;
	}
	
	Book *book = books[0];
	if (![book needUpdate]) {
		[books removeObject:book];
		[self syncChapters];
		return;
	}
	syncing = YES;
	
	[ServiceManager bookCatalogueList:book.uid lastChapterID:[Chapter lastChapterIDOfBook:book] withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
		if (success) {
			NSLog(@"get chapter list of book: %@", book);
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Book *b = [Book findFirstByAttribute:@"uid" withValue:book.uid inContext:localContext];
				if (b) {
					if (forbidden) {
						[b deleteInContext:localContext];
					} else {
						b.nextUpdateTime = nextUpdateTime;
					}
				}
			} completion:^(BOOL success, NSError *error) {
				[Chapter persist:resultArray withBlock:^(void) {
					[self refreshBooks];
					[books removeObject:book];
					[self syncChapters];
				}];
			}];
		} else {
			[books removeObject:book];
			[self syncChapters];
		}
	}];
}

- (void)syncChaptersContent
{
	if (!chapters.count) {
		syncing = NO;
		NSLog(@"sync chapter content finished");
		[chapters removeAllObjects];
		chapters = [[Chapter chaptersNeedSubscribe] mutableCopy];
		NSLog(@"find %d VIP chapters need subscribe and download content", chapters.count);
		[self syncAutoSubscribe];
		return;
	}
	
	Chapter *chapter = chapters[0];
	NSLog(@"fetch chapter: %@", chapter);
	syncing = YES;
	
	[ServiceManager bookCatalogue:chapter.uid VIP:chapter.bVip.boolValue withBlock:^(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
		if (success) {
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Chapter *c = [Chapter findFirstByAttribute:@"uid" withValue:chapter.uid inContext:localContext];
				if (c) {
					c.content = content;
					c.previousID = previousID;
					c.nextID = nextID;
				}
			} completion:^(BOOL success, NSError *error) {
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
	if (!chapters.count) {
		NSLog(@"subscribe chapters finished");
		syncing = NO;
		return;
	}
	
	Chapter *chapter = chapters[0];
	syncing = YES;
	
	Book *book = [Book findFirstByAttribute:@"uid" withValue:chapter.bid];
	[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:book.authorID withBlock:^(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
		if (success) {
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Chapter *c = [Chapter findFirstByAttribute:@"uid" withValue:chapter.uid inContext:localContext];
				if (c) {
					c.content = content;
					c.previousID = previousID;
					c.nextID = nextID;
				}
			} completion:^(BOOL success, NSError *error) {
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
	[ServiceManager addFavoriteWithBookID:needRemoveBook.uid On:NO withBlock:^(BOOL success, NSError *error, NSString *message) {
		if (success) {
			[needRemoveFavoriteBooks removeObject:needRemoveBook];

			//[booksForDisplay removeObject:needRemoveBook];
			//[booksView reloadData];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == favAndAutoBuyAlert && buttonIndex != alertView.cancelButtonIndex) {
		if (needFavAndAutoBuyBookCell) {
			[self displayHUD:@"收藏并开启自动更新..."];
			[ServiceManager addFavoriteWithBookID:needFavAndAutoBuyBookCell.book.uid On:YES withBlock:^(BOOL success, NSError *error, NSString *message) {
				if (success) {
					[ServiceManager autoSubscribeWithBookID:needFavAndAutoBuyBookCell.book.uid On:YES withBlock:^(BOOL success, NSError *error) {
						[self hideHUD:YES];
						needFavAndAutoBuyBookCell.autoBuy = YES;
						needFavAndAutoBuyBookCell.book.autoBuy = @(YES);
						[MagicalRecord saveWithBlock:^(NSManagedObjectContext  *localContext) {
							Book *b = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", needFavAndAutoBuyBookCell.book.uid] inContext:localContext];
							b.autoBuy = @(YES);
						}];
					}];
				} else {
					[self hideHUD:YES];
					[self displayHUDError:@"错误" message:message];
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
    } else if (type.intValue == kHeaderViewButtonRefresh) {
		[self displayHUD:@"开始自动更新..."];
		[self performSelector:@selector(dismissHUD) withObject:nil afterDelay:1];
		if (!syncing) {
			[self syncBooks];
		} else {
			NSLog(@"already syncing");
		}		
    }
}

- (void)dismissHUD
{
	[self hideHUD:YES];
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
        [self.headerView deleteButtonEnable:needRemoveFavoriteBooks.count > 0];
	} else {
		Book *book = [Book findFirstByAttribute:@"uid" withValue:bookCell.book.uid];
		if (book) {
			CoreTextViewController *controller = [[CoreTextViewController alloc] init];
			controller.book = book;
			[self.navigationController pushViewController:controller animated:YES];
		}
	}
}

- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell
{
	if (![ServiceManager isSessionValid]) {
		[self displayHUDError:nil message:@"您尚未登录不能进行此操作"];
		return;
	}

	if (!bookCell.book.bFav) {
		needFavAndAutoBuyBookCell = bookCell;
		favAndAutoBuyAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"您尚未收藏本书，开启自动更新需要收藏此书！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"收藏并开启", nil];
		[favAndAutoBuyAlert show];
		return;
	}
	
	BOOL shiftToOnOrOff = !bookCell.autoBuy;
	NSString *message = shiftToOnOrOff ? @"开启自动更新..." : @"关闭自动更新...";
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

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	[self createStandViews:MAX(5, (int)ceil(booksForDisplay.count / 3) )];
	return booksForDisplay.count;
}

- (PSTCollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = booksForDisplay[indexPath.row];
	BRBookCell *cell = [booksView bookCell:book atIndexPath:indexPath];
	cell.editing = editing;
	cell.badge = [Chapter countOfUnreadChaptersOfBook:book];
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

#pragma mark - NotificationViewDelegate

- (void)startReadButtonClicked:(Book *)book
{
	BookDetailsViewController *bookDetailsViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
	[self.navigationController pushViewController:bookDetailsViewController animated:YES];
	[self closeButtonClicked];
}

- (void)closeButtonClicked
{
    notificationView.hidden = YES;
    notificationView.bShouldLoad = NO;
    CGSize fullSize = self.view.bounds.size;
    [booksView setFrame:CGRectMake(0, BRHeaderView.height, fullSize.width, fullSize.height - BRHeaderView.height)];
}
@end
