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
	UIAlertView *favAndAutoBuyAlert;
	BOOL syncing;
	NSMutableArray *booksStandViews;
	CGFloat startYOfStandView;
	CGFloat standViewsDistance;
    
    LoginReminderView *_loginReminderView;
	BRBookCell *needFavAndAutoBuyBookCell;
    NotificationView *notificationView;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChapters) name:kStartSyncChaptersNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncChaptersContent) name:kStartSyncChaptersContentNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncAutoSubscribe) name:kStartSyncAutoSubscribeNotification object:nil];
}

- (void)startReadButtonClicked:(Book *)book
{
    [book persistWithBlock:^(void) {//下载章节目录
        [self displayHUD:@"获取章节目录..."];
        [ServiceManager bookCatalogueList:book.uid withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
            if (!error) {
                [Chapter persist:resultArray withBlock:^{
                    [self hideHUD:YES];
                    [self closeButtonClicked];
                    CoreTextViewController *controller = [[CoreTextViewController alloc] init];
                    controller.book = book;
                    [self.navigationController pushViewController:controller animated:YES];
                }];
            } else {
                [self displayHUDError:@"获取章节目录失败" message:error.debugDescription];
            }
        }];
    }];
}

- (void)closeButtonClicked
{
    notificationView.hidden = YES;
    notificationView.bShouldLoad = NO;
    CGSize fullSize = self.view.bounds.size;
    [booksView setFrame:CGRectMake(0, BRHeaderView.height, fullSize.width, fullSize.height - BRHeaderView.height)];
}


- (LoginReminderView *)loginReminderView {
	if (!_loginReminderView) {
		_loginReminderView = [[LoginReminderView alloc] initWithFrame:CGRectMake(10, 38, self.view.frame.size.width - 20, 18)];
		[self.view addSubview:_loginReminderView];
	}
	return _loginReminderView;
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
		[self.view sendSubviewToBack:self.backgroundView];
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
    if (notificationView.bShouldLoad) {
        [self showNotificationInfo];
    }
	if (![ServiceManager hadLaunchedBefore]) {
		[self recommendBooks];
    } else {
		if ([ServiceManager userID]) {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:NEED_REFRESH_BOOKSHELF]) {
				stopAllSync = NO;
				[self syncBooks];
				[[NSUserDefaults standardUserDefaults] setBool:NO forKey:NEED_REFRESH_BOOKSHELF];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
		}
	}
	[self loginReminderView].hidden = [ServiceManager userID] != nil;
	[self showBooks];
	[booksView reloadData];
}

- (void)showNotificationInfo
{
    [ServiceManager systemNotifyWithBlock:^(NSError *error, NSArray *resultArray, NSString *content) {
        if (!error) {
            if (resultArray.count == 0 && content.length == 0) {
                notificationView.hidden = YES;
                NSLog(@"无公告和推荐");
                return;
            }
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
        }
    }];
}

- (void)recommendBooks
{
    [ServiceManager recommandDefaultBookwithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
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

- (void)syncBooks
{
	if (stopAllSync) return;
	
//	[self displayHUD:@"同步收藏..."];
	syncing = YES;
    [ServiceManager userBooksWithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
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
		[[NSNotificationCenter defaultCenter] postNotificationName:kStartSyncChaptersContentNotification object:nil];
		return;
	}
	Book *book = books[0];
	//[self displayHUD:@"检查新章节目录..."];
	syncing = YES;

	Book *tmpBook = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", book.uid]];
	if (tmpBook.nextUpdateTime) {
		NSDate *now = [NSDate date];
		NSLog(@"now = %@,  nextUpdateTime = %@", now, tmpBook.nextUpdateTime);
		if ([now compare:tmpBook.nextUpdateTime] == NSOrderedAscending) {
			[books removeObject:book];
			[self syncChapters];
			return;
		}
	}
	
	[ServiceManager bookCatalogueList:book.uid withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
		NSLog(@"updated chapters of book:%@", book.name);
		if (!error) {
			if (forbidden) {
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					Book *forbiddenBook = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", book.uid] inContext:localContext];
					[forbiddenBook truncate];
					[books removeObject:book];
					[self syncChapters];
					for (Book *b in booksForDisplay) {
						if ([b.uid isEqualToString:book.uid]) {
							[booksForDisplay removeObject:b];
							[booksView reloadData];
							return;
						}
					}
				}];
			} else {
				if (nextUpdateTime) {
					[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
						Book *tmpBook = [Book findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", book.uid] inContext:localContext];
						tmpBook.nextUpdateTime = nextUpdateTime;
					}];
				}
				[Chapter persist:resultArray withBlock:^(void) {
					[books removeObject:book];
					[self syncChapters];
				}];
			}
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
	[ServiceManager bookCatalogue:chapter.uid VIP:chapter.bVip.boolValue withBlock:^(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
		if (content) {
			chapter.content = content;
			chapter.previousID = previousID;
			chapter.nextID = nextID;
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Chapter *ch = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", chapter.uid] inContext:localContext];
				if (ch) {
					ch.content = content;
					ch.previousID = previousID;
					ch.nextID = nextID;
				}
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
	[ServiceManager chapterSubscribeWithChapterID:chapter.uid book:chapter.bid author:book.authorID withBlock:^(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID) {
		if (content) {
			chapter.content = content;
			chapter.previousID = previousID;
			chapter.nextID = nextID;
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Chapter *ch = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", chapter.uid] inContext:localContext];
				if (ch) {
					ch.content = content;
					ch.previousID = previousID;
					ch.nextID = nextID;
				}
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
		if (![ServiceManager userID]) return;
		if (!syncing) {
			[self syncBooks];
			NSLog(@"begin sync");
		} else {
			[self displayHUD:@"开始自动更新..."];
			[self performSelector:@selector(dismissHUD) withObject:nil afterDelay:1];
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
        [self.headerView deleteButtonEnable:[needRemoveFavoriteBooks count]>0 ? YES : NO];
	} else {
        //[bookCell.book persistWithBlock:nil];//TODO: need to this when actually start to read. Why should persist here?
		CoreTextViewController *controller = [[CoreTextViewController alloc] init];
		controller.book = bookCell.book;
        [self.navigationController pushViewController:controller animated:YES];
	}
}

- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell
{
	if (![ServiceManager userID]) {
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
	cell.editing = editing;
	cell.badge = [book countOfUnreadChapters];
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
