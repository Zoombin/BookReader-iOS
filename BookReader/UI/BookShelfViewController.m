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
#import "BookView.h"
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

//UIFrame
#define EDIT_BUTTON_FRAME                      CGRectMake(10, 11, 50, 32)
#define DELETE_BUTTON_FRAME                    CGRectMake(MAIN_SCREEN.size.width-60,11,50,32)

#define SHELF_HEIGHT                      132
#define BOOK_WIDTH                        72
#define BOOK_HEIGHT                       99
#define BOOK_TOP_SPACING                  20
#define BOOK_HORIZONTAL_SPACING           26
#define BOOK_VERTICAL_SPACING             26
#define PROGRESS_BOOK_OFFSET              4

@interface BookShelfViewController () <BookShelfHeaderViewDelegate,BookShelfBottomViewDelegate,UIAlertViewDelegate, PSUICollectionViewDataSource, BRBooksViewDelegate>
@end

@implementation BookShelfViewController {
    NSMutableArray *allArray;      //所有的书籍
    NSMutableArray *bookViewArray;
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
    allArray = [[NSMutableArray alloc] init];
    bookViewArray = [[NSMutableArray alloc]init];
	
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
	userid = [BookReaderDefaultManager userid];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (!userid) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"firstlaunch", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        [alertView show];
		
		//TODO: load data from database
    } else {
		[self syncFav];//TOTEST: have to delete
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
			[self displayHUDError:@"出错了！" message:error.description];
        }else {
			[allArray removeAllObjects];
			[allArray addObjectsFromArray:result];
			NSLog(@"allArray = %@", allArray);
			[Book persist:allArray];
			[booksView reloadData];
			
//            for (int i = 0; i < result.count; i++) {
//                Book *book = result[i];
//				[book persist];
//                NSArray *bookArray = [Book findAllWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@",book.uid]];
//                if (bookArray.count == 0) {
//                    NSLog(@"%@",book.name);
//                    [book persist];
//                }
//                else {
//                    Book *tmpobj = bookArray[0];
//                    tmpobj.autoBuy = book.autoBuy;
//                    [tmpobj persist];
//                }
//                NSArray *chapterArray = [Chapter chaptersWithBookId:book.uid];
//                if (chapterArray.count > 0) {
//                    Chapter *chapter = [chapterArray lastObject];
//                    [self loadChapterList:chapter.uid andBookId:book.uid];
//                }
//                else {
//                    [self loadChapterList:@"0" andBookId:book.uid];
//                }
//            }            
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"登录");
        [APP_DELEGATE switchToRootController:kRootControllerTypeMember];
    }
}

//- (void)loadUserBookShelf
//{
//	//TODO: logical error, allArray.count > 0 means shouldn't refresh user's fav???
//    if ([allArray count] == 0 && userid != nil) {
//        NSArray *array = [Book findAll];
//        if (array.count > 0) {
//            [allArray addObjectsFromArray:array];
//			[booksView reloadData];
//        }
//        else {
//            //[self refreshUserBooks];
//        }
//    }
//}

//- (void)refreshUserBooks
//{
//    if (!userid) {
//        return;
//    }
//    [self displayHUD:@"获取用户书架中..."];
//    [ServiceManager userBooks:userid size:@"5000" andIndex:@"1" withBlock:^(NSArray *result, NSError *error) {
//        if (error) {
//            [self hideHUD:YES];
//        }else {
//			[allArray removeAllObjects];
//            for (int i = 0; i < result.count; i++) {
//                Book *obj = result[i];
//                NSArray *bookArray = [Book findAllWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@",obj.uid]];
//                if (bookArray.count == 0) {
//                    NSLog(@"%@",obj.name);
//                    [obj persist];
//                }
//                else {
//                    Book *tmpobj = bookArray[0];
//                    tmpobj.autoBuy = obj.autoBuy;
//                    [tmpobj persist];
//                }
//                NSArray *chapterArray = [Chapter chaptersWithBookId:obj.uid];
//                if (chapterArray.count > 0) {
//                    Chapter *chapter = [chapterArray lastObject];
//                    [self loadChapterList:chapter.uid andBookId:obj.uid];
//                }
//                else {
//                    [self loadChapterList:@"0" andBookId:obj.uid];
//                }
//            }
//            [allArray addObjectsFromArray:result];
//            //[self layoutBookViewWithArray:[self bookViews]];
//            [self hideHUD:YES];
//        }
//    }];
//}

- (void)refreshUserBooksAndDownload
{
//    [self refreshUserBooks];
    [self chaptersArrayWithIndex:0];
}

- (void)chaptersArrayWithIndex:(NSInteger)index
{
    NSLog(@"index %d ? = %d",index, [allArray count]);
    if (index < [allArray count]) {
        Book *book = [allArray objectAtIndex:index];
        NSArray *chaptersArray = [Chapter chaptersWithBookId:book.uid];
        [self downloadBooks:[chaptersArray objectAtIndex:0] andBookIndex:index andCurrentChapterArray:chaptersArray];
    } else {
        NSLog(@"下载完毕");
    }
}

- (void)downloadBooks:(Chapter *)obj andBookIndex:(NSInteger)bookIndex andCurrentChapterArray:(NSArray *)chaptersArray;
{
    Book *book = [allArray objectAtIndex:bookIndex];
    if (obj.content) {
        [self nextBookOrChapterWithChapter:obj
                          andChaptersArray:chaptersArray
                              andBookIndex:bookIndex];
        return;
    }
    [ServiceManager bookCatalogue:obj.uid
                        andUserid:userid
                        withBlock:^(NSString *content,NSString *result,NSString *code, NSError *error) {
                            if (error) {
                                [self nextBookOrChapterWithChapter:obj
                                                  andChaptersArray:chaptersArray
                                                      andBookIndex:bookIndex];
                            }
                            else
                            {
                                if (![code isEqualToString:SUCCESS_FLAG]) {
                                    if ([book.autoBuy boolValue]) {
                                        [self subscribeBook:obj
                                               andBookIndex:bookIndex
                                     andCurrentChapterArray:chaptersArray];
                                    } else {
                                        [self nextBookOrChapterWithChapter:obj
                                                          andChaptersArray:chaptersArray
                                                              andBookIndex:bookIndex];
                                    }
                                }
                                else
                                {
                                    obj.content = content;
                                    [self nextBookOrChapterWithChapter:obj
                                                      andChaptersArray:chaptersArray
                                                          andBookIndex:bookIndex];
                                }
                            }
                        }];
}

- (void)nextBookOrChapterWithChapter:(Chapter *)chapter
                    andChaptersArray:(NSArray *)chaptersArray
                        andBookIndex:(NSInteger)bookIndex
{
    if ([chapter.index integerValue] < [chaptersArray count]-1) {
        [self downloadBooks:[chaptersArray objectAtIndex:[chapter.index integerValue] + 1]
               andBookIndex:bookIndex
     andCurrentChapterArray:chaptersArray];
    }
    else {
        [self chaptersArrayWithIndex:bookIndex + 1];
    }
}

- (void)subscribeBook:(Chapter *)chapter
         andBookIndex:(NSInteger)bookIndex
andCurrentChapterArray:(NSArray *)chaptersArray
{
    Book *book = [allArray objectAtIndex:bookIndex];
    if ([chapter.bVip boolValue] && chapter.content == nil) {
        [ServiceManager chapterSubscribe:userid chapter:chapter.uid book:book.uid author:book.authorID andPrice:@"0" withBlock:^(NSString *content, NSString *errorMessage, NSString *result, NSError *error) {
            if (error) {
                [self nextBookOrChapterWithChapter:chapter
                                  andChaptersArray:chaptersArray
                                      andBookIndex:bookIndex];
            }
            else {
                if ([result isEqualToString:SUCCESS_FLAG]) {
                    chapter.content = content;
                    [self nextBookOrChapterWithChapter:chapter
                                      andChaptersArray:chaptersArray
                                          andBookIndex:bookIndex];
                }else {
                    [self nextBookOrChapterWithChapter:chapter
                                      andChaptersArray:chaptersArray
                                          andBookIndex:bookIndex];
                }
            }
        }];
    }
}

- (void)loadChapterList:(NSString *)cataId andBookId:(NSString *)bookid
{
    [ServiceManager bookCatalogueList:bookid andNewestCataId:cataId withBlock:^(NSArray *result, NSError *error) {
        if (!error) {
			[Chapter persist:result withBlock:nil];
        }
    }];
}

//- (void)addDefaultBackground {
//    for (int i =0; i<4; i++) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, i*SHELF_HEIGHT*SCREEN_SCALE, MAIN_SCREEN.size.width, SHELF_HEIGHT*SCREEN_SCALE)];
//        imageView.image = [UIImage imageNamed:@"bookshelf"];
//        //[bookShelfView insertSubview:imageView atIndex:0];
//    }
//}

//- (NSMutableArray *)bookViews {
//	[bookViewArray removeAllObjects];
//    NSArray *framesArray = [self createFrames:[allArray count]];
//    for (int i = 0; i< [allArray count]; i++) {
//        BookView *bookView = [[BookView alloc] initWithFrame:CGRectFromString([framesArray objectAtIndex:i])];
//        Book *book = allArray[i];
//        bookView.selected = NO;
//        bookView.editing = NO;
//        [bookView setBadgeValue:[[book numberOfUnreadChapters] integerValue]];
//        [bookView setBook:book];
//        [bookView setDelegate:self];
//        bookViewArray[i] = bookView;
//    }
//    return bookViewArray;
//}

- (void)bottomButtonClicked:(NSNumber *)type {
    if (type.intValue == kBottomViewButtonEdit) {
		editing = YES;
		[booksView reloadData];
    }
    else if (type.intValue == kBottomViewButtonDelete)
    {
		for (BookView *bv in bookViewArray) {
			if (bv.selected) {
				[ServiceManager addFavourite:userid book:bv.book.uid andValue:NO withBlock:^(NSString *errorMessage,NSString *result, NSError *error) {
					if (error) {
					}
					else {
						if ([result isEqualToString:SUCCESS_FLAG]) {
							[allArray removeObject:bv.book];
							[bookViewArray removeObject:bv];
						}
					}
				}];
			}
		}
    } else if (type.intValue == kBottomViewButtonFinishEditing) {
		editing = NO;
		[booksView reloadData];
    }
    else if (type.intValue == kBottomViewButtonRefresh) {
        [self refreshUserBooksAndDownload];
    }
    else if (type.intValue == kBottomViewButtonShelf) {
        headerView.titleLabel.text = @"我的收藏";
    }
    else if (type.intValue == kBottomViewButtonBookHistoroy) {
        headerView.titleLabel.text = @"阅读历史";
    }
}

- (void)saveBookValue
{
    if ([allArray count]>0) {
        for (int i = 0; i<[allArray count]; i++) {
            Book *book = [allArray objectAtIndex:i];
            [book persist];
        }
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

- (void)loadRemoteView {
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectInset(self.view.bounds, 0, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"iphone_qqreader_Center_icon_bg"]];
    [self.view addSubview:backgroundImage];
    
    headerView = [[BookShelfHeaderView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [headerView setDelegate:self];
    [self.view addSubview:headerView];
    
    bottomView = [[BookShelfBottomView alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN.size.height-44-20, MAIN_SCREEN.size.width, 44)];
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
	NSLog(@"changedValue");
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return allArray.count;
}

- (PSTCollectionViewCell *)collectionView:(PSUICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Book *book = allArray[indexPath.row];
	BRBookCell *cell = [booksView cellForBook:book atIndexPath:indexPath];
	cell.editing = editing;
	return cell;
}

@end
