//
//  BookShelfViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Book+Test.h"

#import "BookShelfViewController.h"
#import "NonManagedBook.h"
#import "BookView.h"
#import "AppDelegate.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "NonManagedChapter.h"
#import "ManagedChapter.h"
#import "ManagedBook.h"
#import "BookInterface.h"
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

@implementation BookShelfViewController {
    //Remote
    NSMutableArray *selectedArray; //选中的书籍
    NSMutableArray *allArray;      //所有的书籍
    NSMutableArray *bookViewArray;
    UIScrollView *bookShelfView;
    BOOL editing;
    BookShelfHeaderView *headerView;
    BookShelfBottomView *bottomView;
    UITableView *infoTableView;
    
    BookShelfLayoutStyle layoutStyle;
    
    NSNumber *userid;
}
@synthesize delegate;
@synthesize layoutStyle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    allArray = [[NSMutableArray alloc] init];
    bookViewArray = [[NSMutableArray alloc]init];
    if (layoutStyle == kBookShelfLayoutStyleShelfLike) {
        selectedArray = [[NSMutableArray alloc] init];
        [self loadRemoteView];
    }
    else if (layoutStyle == kBookShelfLayoutStyleTableList) {
        [self loadLocalView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadUserBookShelf];
    NSLog(@"%d",[[ManagedBook findAll] count]);
}

- (void)loadUserBookShelf
{
    userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userid"];
    if ([allArray count]==0&&userid!=nil)
    {
        [self refreshUserBooks]; 
    }
}

- (void)refreshUserBooks
{
    if (userid==nil) {
        return;
    }
    [self displayHUD:@"获取用户书架中..."];
    [ServiceManager userBooks:userid size:@"5000" andIndex:@"1" withBlock:^(NSArray *result, NSError *error) {
        if (error) {
            [self hideHUD:YES];
        }else {
            [self hideHUD:YES];
            if ([allArray count]>0) {
                [allArray removeAllObjects];
            }
            for (int i = 0; i<[result count]; i++) {
                NonManagedBook *obj = [result objectAtIndex:i];
                NSArray *bookArray = [ManagedBook findByAttribute:@"uid" withValue:obj.uid];
                if ([bookArray count]==0)
                {
                    [ManagedBook createBookWithNonManagedBook:obj];
                    [[NSManagedObjectContext defaultContext] saveNestedContexts];
                }
                else
                {
                    ManagedBook *tmpobj = [bookArray objectAtIndex:0];
                    tmpobj.autoBuy = obj.autoBuy;
                    [[NSManagedObjectContext defaultContext] saveNestedContexts];
                }
                NSArray *chapterArray = [ManagedChapter findByAttribute:@"bid" withValue:obj.uid andOrderBy:@"index" ascending:YES];
                if ([chapterArray count] > 0)
                {
                    id<ChapterInterface> chapter = [chapterArray lastObject];
                    [self loadChapterList:chapter.uid andBookId:obj.uid];
                }
                else
                {
                    [self loadChapterList:[NSNumber numberWithInt:0] andBookId:obj.uid];
                }
            }
            [allArray addObjectsFromArray:result];
            [self layoutBookViewWithArray:[self bookViews]];
        }
    }];
}

//- (void)autoSubscribeBooks
//{
//    NSArray *userBookArray = [ManagedBook findAll];
//    for (int i = 0; i<[userBookArray count]; i++) {
//        id<BookInterface> book = [userBookArray objectAtIndex:i];
//        if ([book.autoBuy boolValue]==YES) {
//            NSArray *chaptersArray = [ManagedChapter findByAttribute:@"bid" withValue: andOrderBy:<#(NSString *)#> ascending:<#(BOOL)#>];
//        }
//    }
//}

- (void)loadChapterList:(NSNumber *)CataId andBookId:(NSString *)bookid
{
   [ServiceManager bookCatalogueList:bookid andNewestCataId:CataId withBlock:^(NSArray *result, NSError *error) {
       if (error)
       {
       }
       else
       {
           for (int i = 0; i<[result count]; i++) {
               [ManagedChapter createChapterWithNonManagedBook:[result objectAtIndex:i]];
               [[NSManagedObjectContext defaultContext] saveNestedContexts];
           }
       }
   }];
}



- (void)loadRemoteView {
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44-20)];
    [backgroundImage setImage:[UIImage imageNamed:@"iphone_qqreader_Center_icon_bg"]];
    [self.view addSubview:backgroundImage];
    editing = NO;
    
    headerView = [[BookShelfHeaderView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [headerView setDelegate:self];
    [self.view addSubview:headerView];
    
    bottomView = [[BookShelfBottomView alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN.size.height-44-20, MAIN_SCREEN.size.width, 44)];
    [bottomView setDelegate:self];
    [self.view addSubview:bottomView];
    
    bookShelfView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44-20-44)];
    [bookShelfView setDelegate:self];
    [bookShelfView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bookShelfView];
    
    [self layoutBookViewWithArray:[self bookViews]];
}

- (void)addDefaultBackground {
    for (int i =0; i<4; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, i*SHELF_HEIGHT*SCREEN_SCALE, MAIN_SCREEN.size.width, SHELF_HEIGHT*SCREEN_SCALE)];
        imageView.image = [UIImage imageNamed:@"bookshelf"];
        [bookShelfView insertSubview:imageView atIndex:0];
    }
}

- (void)layoutBookViewWithArray:(NSArray *)array
{
    for (UIView *view in [bookShelfView subviews]) {
        [view removeFromSuperview];
    }
    [self addDefaultBackground];
    int line = 0, column = 0;
    for (int i = 0; i < [array count]; i++) {
        line = i/3;
        if (line > 3) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_SCALE*line*SHELF_HEIGHT, MAIN_SCREEN.size.width, SHELF_HEIGHT*SCREEN_SCALE)];
            imageView.image = [UIImage imageNamed:@"bookshelf"];
            [bookShelfView insertSubview:imageView atIndex:0];
        }
        
        BookView *book = [array objectAtIndex:i];
        
        UIImageView *bookBackground = [[UIImageView alloc] init];
        [bookBackground setImage:[UIImage imageNamed:@"bookcase_readed_bg"]];
        CGRect backgroundframe = bookBackground.frame;
        backgroundframe.size.width = 88*SCREEN_SCALE;
        backgroundframe.size.height = 30*SCREEN_SCALE;
        backgroundframe.origin.x = book.frame.origin.x-(88*SCREEN_SCALE-79*SCREEN_SCALE);
        backgroundframe.origin.y = book.frame.origin.y + BOOK_HEIGHT*SCREEN_SCALE + PROGRESS_BOOK_OFFSET-18*SCREEN_SCALE;
        bookBackground.frame = backgroundframe;
        
        column++;
        if (column%3 == 0) {
            column = 0;
        }
        [bookShelfView addSubview:bookBackground];
        [bookShelfView addSubview:book];
        
        CGFloat lineHeight = (SHELF_HEIGHT*SCREEN_SCALE) *(line +1);
        bookShelfView.contentSize = CGSizeMake(MAIN_SCREEN.size.width, lineHeight+BOOK_TOP_SPACING);
    }
}

- (NSArray *)createFrames:(NSInteger)count
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int line = 0, column = 0;
    for (int i = 0; i < count; i++) {
        line = i/3;
        CGRect buttonFrame = CGRectMake(BOOK_HORIZONTAL_SPACING*SCREEN_SCALE*(column+1)+column*BOOK_WIDTH*SCREEN_SCALE, BOOK_VERTICAL_SPACING*SCREEN_SCALE*line+ BOOK_TOP_SPACING+line*BOOK_HEIGHT*SCREEN_SCALE + line*7, BOOK_WIDTH*SCREEN_SCALE, BOOK_HEIGHT*SCREEN_SCALE+PROGRESS_BOOK_OFFSET*SCREEN_SCALE);
        NSString *frameString = NSStringFromCGRect(buttonFrame);
        [array addObject:frameString];
        column++;
        if (column%3 == 0) {
            column = 0;
        }
    }
    return array;
}

- (NSMutableArray *)bookViews {
    if ([bookViewArray count]>0) {
        [bookViewArray removeAllObjects];
    }
    NSArray *framesArray = [self createFrames:[allArray count]];
    for (int i = 0; i< [allArray count]; i++) {
        BookView *bookView = [[BookView alloc]initWithFrame:CGRectFromString([framesArray objectAtIndex:i])];
        [bookView setBook:[allArray objectAtIndex:i]];
        [bookView setDelegate:self];
        [bookView setTag:i];
        bookView.isInEditing = editing;
        bookViewArray[i] = bookView;
    }
    return bookViewArray;
}

- (void)bottomButtonClicked:(NSNumber *)type {
    if (type.intValue == kBottomViewButtonEdit) {
        editing = YES;
        if ([selectedArray count]>0) {
            [selectedArray removeAllObjects];
        }
        [self layoutBookViewWithArray:[self bookViews]];
    }
    else if (type.intValue == kBottomViewButtonDelete)
    {
        for (int i = 0; i<[selectedArray count]; i++)
        {
            BookView *bookView = [selectedArray objectAtIndex:i];
            id<BookInterface> book = [allArray objectAtIndex:bookView.tag];
            [ServiceManager addFavourite:userid book:book.uid andValue:NO withBlock:^(NSString *errorMessage,NSString *result, NSError *error) {
                if (error)
                {
                    
                }
                else
                {
                    if ([result isEqualToString:@"0000"]) {
                        [allArray removeObject:book];
                        [bookViewArray removeObject:bookView];
                        [self layoutBookViewWithArray:[self bookViews]];
                    }
                }
            }];
        }
        [selectedArray removeAllObjects];
    } else if (type.intValue == kBottomViewButtonFinishEditing)
    {
        if (editing)
        {
            editing = NO;
        }
        if ([selectedArray count]>0)
        {
            [selectedArray removeAllObjects];
        }
        [self layoutBookViewWithArray:[self bookViews]];
    }
    else if (type.intValue == kBottomViewButtonRefresh)
    {
        [self refreshUserBooks];
    }
    else if (type.intValue == kBottomViewButtonShelf)
    {
        
    }
    else if (type.intValue == kBottomViewButtonBookHistoroy)
    {
        
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

#pragma mark -
#pragma mark BookShelfView Delegate
- (void)bookViewButtonClick:(id)sender
{
    BookView *bookView = [bookViewArray objectAtIndex:[sender tag]];
    if (editing)
    {
        if ([selectedArray containsObject:bookView])
        {
            bookView.isSelected = NO;
            [selectedArray removeObject:bookView];
        } else
        {
            bookView.isSelected = YES;
            [selectedArray addObject:bookView];
        }
    } else {
        id<BookInterface> book = [allArray objectAtIndex:bookView.tag];
        [self.navigationController pushViewController:[[SubscribeViewController alloc] initWithBookId:book andOnline:NO] animated:YES];
    }
}


- (void)loadLocalView {
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headerImageViewFrame];
    [headerImageView setImage:[UIImage imageNamed:@"main_headerbackground.png"]];
    [self.view addSubview:headerImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    [titleLabel setText:NSLocalizedString(@"BookList", nil)];
    [titleLabel setTextColor:txtColor];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.view addSubview:titleLabel];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_background.png"]];
    infoTableView = [[UITableView alloc] initWithFrame:infoTableViewFrame style:UITableViewStylePlain];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setBackgroundView:backgroundView];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [BookCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
        cell = [[BookCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        id<BookInterface> book = allArray[indexPath.row];
        [cell setBook:book];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    Book *book = allArray[indexPath.row];
    //    NSString *bookid = [bookIdArray objectAtIndex:[indexPath row]];
    //    UIViewController *pushController;
    //    //此处做判断,如果没有章节则直接进入阅读,并且当这书是免费的。
    //    if ([[[BookManager sharedInstance] getchaptersByBookId:bookid]count] == 0) {
    //        ReadViewController *controller = [[ReadViewController alloc] initWithBookUID:bookid andShouldMoveToNew:NO andMoveIndex:@"" andNewText:nil];
    //        controller.isBuy = YES;
    //        pushController = controller;
    //        //[self.navigationController pushViewController:controller animated:YES];
    //        //[controller release];
    //        //return;
    //    }
    //    ChapterViewController *chapterViewController = [[ChapterViewController alloc] initBookWithUID:book.uid];
    //    pushController = chapterViewController;
    //    if (delegate) {
    //        [delegate selectedABook:pushController];
    //    }
}

@end
