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
#import "UIDefines.h"
#import "Constants.h"
#import "CoreTextViewController.h"
#import "SubscribeViewController.h"
#import "BookCell.h"
#import "BRBooksView.h"
#import "BRBookCell.h"
#import "BookReaderDefaultManager.h"

@interface BookShelfViewController () <BookShelfHeaderViewDelegate,BookShelfBottomViewDelegate,UIAlertViewDelegate, PSUICollectionViewDataSource, BRBooksViewDelegate>
@end

@implementation BookShelfViewController {
    NSMutableArray *books;      //所有的书籍
    BookShelfHeaderView *headerView;
    BookShelfBottomView *bottomView;
	BRBooksView *booksView;
    NSNumber *userid;
	BOOL editing;
}
@synthesize layoutStyle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    books = [[NSMutableArray alloc] init];
	
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
	userid = [ServiceManager userID];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (!userid) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"firstlaunch", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        [alertView show];
		
		//TODO: load data from database
    } else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kNeedRefreshBookShelf]) {
			[self syncFav];
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:kNeedRefreshBookShelf];
		}
	}
}

- (void)syncFav
{
	if (!userid) return;
	[self displayHUD:@"获取用户书架中..."];
    [ServiceManager userBooks:userid size:@"5000" andIndex:@"1" withBlock:^(NSArray *result, NSError *error) {
		[self hideHUD:YES];
        if (error) {
			[self displayHUDError:nil message:error.description];
        }else {
			[books removeAllObjects];
			[books addObjectsFromArray:result];
			[Book persist:books];
			[booksView reloadData];
			
			[books enumerateObjectsUsingBlock:^(Book *book, NSUInteger idx, BOOL *stop) {
				[ServiceManager bookCatalogueList:book.uid andNewestCataId:@"0" withBlock:^(NSArray *result, NSError *error) {
					if (!error) {
						[Chapter persist:result withBlock:nil];
					}
					
					if (idx == books.count - 1) {
						//[self syncChapterContent:0 bookIdx:0];
					}
				}];
				

			}];
        }
    }];
}

- (void)syncChapterContent:(NSInteger)idx bookIdx:(NSInteger)bookIdx
{
	if (bookIdx >= books.count) return;
	Book *book = books[bookIdx];
	NSArray *chapters = [Chapter chaptersWithBookID:book.uid];
	if (idx >= chapters.count) return;
	[books enumerateObjectsUsingBlock:^(Book *book, NSUInteger bookIdx, BOOL *stop) {
		[chapters enumerateObjectsUsingBlock:^(Chapter *chapter, NSUInteger idx, BOOL *stop) {
			[self displayHUD:[NSString stringWithFormat:@"下载中%@:%@", book.name, chapter.name]];
			[ServiceManager bookCatalogue:book.uid	andUserid:userid withBlock:^(NSString *content, NSString *result, NSString *code, NSError *error) {
				chapter.content = content;
				[chapter persistWithBlock:^{
					[self syncChapterContent:idx + 1 bookIdx:bookIdx];
				}];
			}];
		}];
	}];
}

//- (void)subscribeBook:(Chapter *)chapter
//         andBookIndex:(NSInteger)bookIndex
//andCurrentChapterArray:(NSArray *)chaptersArray
//{
//    Book *book = [books objectAtIndex:bookIndex];
//    if ([chapter.bVip boolValue] && chapter.content == nil) {
//        [ServiceManager chapterSubscribe:userid chapter:chapter.uid book:book.uid author:book.authorID andPrice:@"0" withBlock:^(NSString *content, NSString *errorMessage, NSString *result, NSError *error) {
//            if (error) {
//                [self nextBookOrChapterWithChapter:chapter
//                                  andChaptersArray:chaptersArray
//                                      andBookIndex:bookIndex];
//            }
//            else {
//                if ([result isEqualToString:SUCCESS_FLAG]) {
//                    chapter.content = content;
//                    [self nextBookOrChapterWithChapter:chapter
//                                      andChaptersArray:chaptersArray
//                                          andBookIndex:bookIndex];
//                }else {
//                    [self nextBookOrChapterWithChapter:chapter
//                                      andChaptersArray:chaptersArray
//                                          andBookIndex:bookIndex];
//                }
//            }
//        }];
//    }
//}

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
		[ServiceManager addFavourite:userid book:bookCell.book.uid andValue:NO withBlock:^(NSString *errorMessage, NSString *result, NSError *error) {
			[self hideHUD:YES];
			if ([result isEqualToString:SUCCESS_FLAG]) {
				[needRemoveIndexes addIndex:idx];
				[self removeFav:idx + 1];
			}
		}];
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
		[self.navigationController pushViewController:[[SubscribeViewController alloc] initWithBookId:bookCell.book andOnline:NO] animated:YES];
	}
}

- (void)booksView:(BRBooksView *)booksView changedValueBookCell:(BRBookCell *)bookCell
{
	BOOL shiftToOnOrOff = !bookCell.autoBuy;
	NSString *message = shiftToOnOrOff ? @"开启订阅..." : @"关闭订阅...";
		[self displayHUD:message];
	[ServiceManager autoSubscribe:userid book:bookCell.book.uid andValue:shiftToOnOrOff ? @"1" : @"0" withBlock:^(NSString *result, NSError *error) {
		[self hideHUD:YES];
		if (!error) {
			bookCell.book.autoBuy = @(shiftToOnOrOff);
			bookCell.autoBuy = shiftToOnOrOff;
		}
	}];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return books.count;
}

- (PSTCollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = books[indexPath.row];
	BRBookCell *cell = [booksView bookCell:book atIndexPath:indexPath];
	cell.editing = editing;
	return cell;
}

@end
