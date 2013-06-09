//
//  ReBookStoreViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-23.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "BookStoreViewController.h"
#import "BookReader.h"
#import "AppDelegate.h"
#import "BookShelfButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabel+BookReader.h"
#import "UIButton+BookReader.h"
#import "ServiceManager.h"
#import "BookDetailsViewController.h"
#import "UIViewController+HUD.h"
#import "UIColor+Hex.h"
#import "CategoryDetailsViewController.h"
#import "UIColor+BookReader.h"
#import "UIView+BookReader.h"
#import "BookCell.h"

#define RECOMMEND 0
#define RANK 1
#define CATAGORY 2
#define SEARCH 3

@implementation BookStoreViewController
{
    int currentPage;
    int currentIndex;
    UILabel       *titleLabel;
    
    UISearchBar *_searchBar;
    UIButton *_headerSearchButton;
    UIView      *tableViewHeader;
    
    NSMutableArray *buttonArrays; //4个分类的按钮array
    
    NSMutableArray *infoArray;
    UITableView *infoTableView;
    
    UIView *rankView;
    
    BOOL shouldRefresh;
    int currentType;
    
    NSMutableArray *recommendArray;
    
    NSMutableArray *recommendTitlesArray;
    
    UIButton *recommendButton;
    UIButton *rankButton;
    UIButton *cataButton;
    UIButton *searchButton;
    
    UIButton *allRankButton;
    UIButton *newRankButton;
    UIButton *hotRankButton;
    
    NSMutableArray *rankBtns;
    UITapGestureRecognizer *gestureRecognizer;
    NSArray *catagoryNames;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        catagoryNames = @[@"穿越",@"架空",@"都市",@"青春",@"魔幻",@"玄幻",@"豪门",@"历史",@"异能",@"短篇",@"耽美"];
        recommendArray = [[NSMutableArray alloc] init];
        buttonArrays = [[NSMutableArray alloc] init];
        infoArray = [[NSMutableArray alloc] init];
        recommendTitlesArray = [[NSMutableArray alloc] init];
        
        rankBtns = [[NSMutableArray alloc] init];
        currentType = RECOMMEND;
        currentPage = 1;
        currentIndex = 1;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self RefreshUI];
}

- (void)RefreshUI {
    if (shouldRefresh==YES) {
        currentType = RECOMMEND;
        [infoTableView setTableFooterView:nil];
        [rankView setHidden:YES];
        [self loadRecommendData];
        [infoTableView setHidden:NO];
        [[self BRHeaderView].titleLabel setText:@"推荐"];
        NSArray *buttonImageNameUp = @[@"bookcity_RecoUp", @"bookcity_ExceUp", @"bookcity_CataUp", @"bookcity_SearchUp"];
        NSArray *buttonImageNameDown = @[@"bookcity_RecoDown", @"bookcity_ExceDown", @"bookcity_CataDown", @"bookcity_SearchDown"];
        for (int i = 0; i < 4; i++) {
            UIButton *button = (UIButton *)[buttonArrays objectAtIndex:i];
            if (i == 0) {
                [button setImage:[UIImage imageNamed:buttonImageNameDown[0]] forState:UIControlStateNormal];
            }else {
                [button setImage:[UIImage imageNamed:buttonImageNameUp[i]] forState:UIControlStateNormal];
            }
        }
        shouldRefresh = NO;
    }
}

- (void)shouldRefresh
{
    shouldRefresh = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    shouldRefresh = YES;
    [self setHideBackBtn:YES];
    [self setTitle:@"书城"];
    
    UIImageView *bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    [bottomImage setImage:[UIImage imageNamed:@"nav_header"]];
    [self.view addSubview:bottomImage];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    NSArray *buttonImageNameDown = @[@"bookcity_RecoDown", @"bookcity_ExceDown", @"bookcity_CataDown", @"bookcity_SearchDown"];
    NSArray *buttonImageNameUp = @[@"bookcity_RecoUp", @"bookcity_ExceUp", @"bookcity_CataUp", @"bookcity_SearchUp"];
    for (int i=0; i<[buttonImageNameDown count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:buttonImageNameDown[i]] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:buttonImageNameUp[i]] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(i*self.view.bounds.size.width/4, self.view.bounds.size.height-48, self.view.bounds.size.width/4, 46)];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [buttonArrays addObject:button];
    }
    
    recommendButton = buttonArrays[0];
    rankButton = buttonArrays[1];
    cataButton = buttonArrays[2];
    searchButton = buttonArrays[3];
    
    tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    [tableViewHeader setBackgroundColor:[UIColor clearColor]];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-80, 40)];
    [[_searchBar.subviews objectAtIndex:0]removeFromSuperview];
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor blackColor];
    [_searchBar setPlaceholder:@"请输入书名作者"];
    [tableViewHeader addSubview:_searchBar];
    
    _headerSearchButton = [UIButton createButtonWithFrame:CGRectMake(self.view.bounds.size.width-70, 5, 50, 30)];
    [_headerSearchButton addTarget:self action:@selector(searchBarSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerSearchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [tableViewHeader addSubview:_headerSearchButton];
 
    [self initRandButton];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50)];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 44, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50) style:UITableViewStylePlain];
    [infoTableView.layer setCornerRadius:4];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setBackgroundView:backgroundView];
    [infoTableView setBackgroundColor:[UIColor whiteColor]];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];

    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [backgroundView addGestureRecognizer:gestureRecognizer];
    
    [self removeGestureRecognizer];
}

- (void)hideKeyboard {
    [_searchBar resignFirstResponder];
}

- (void)initRandButton {
    CGRect frame = CGRectMake(0, 10, self.view.bounds.size.width/9, 20);
    rankView = [[UIView alloc]initWithFrame: CGRectMake(-5+(self.view.bounds.size.width/3 *2), 0, self.view.bounds.size.width/3, 40)];
    [rankView setBackgroundColor:[UIColor clearColor]];
    [rankView setHidden:YES];
    [self.view addSubview:rankView];
    NSArray *buttonNames = @[@"总榜", @"最新", @"最热"];
    NSArray *imagesArray = @[@"all_btn" , @"new_btn", @"hot_btn"];
    for (int i = 0; i<3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==0) {
            [button setBackgroundImage:[UIImage imageNamed:@"all_btn_hl"] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:[UIImage imageNamed:imagesArray[i]] forState:UIControlStateNormal];
        }
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reloadDataByIndex:) forControlEvents:UIControlEventTouchUpInside];
        if (i!=0) {
            frame = CGRectMake(CGRectGetMaxX(frame), 10, frame.size.width, frame.size.height);
        }
        [button setFrame:frame];
        [rankView addSubview:button];
        [rankBtns addObject:button];
    }
    allRankButton = rankBtns[0];
    newRankButton = rankBtns[1];
    hotRankButton = rankBtns[2];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBar.text length]>0) {
        [self loadDataWithKeyWord:_searchBar.text classId:0 ranking:0 size:@"6" andIndex:1];
    }
    [_searchBar resignFirstResponder];
}

- (void)loadDataWithKeyWord:(NSString *)keyword
                    classId:(NSString *)classid
                    ranking:(XXSYRankingType)rank
                       size:(NSString *)size
                   andIndex:(NSInteger)index
{
    currentIndex = 1;
    [self displayHUD:@"加载中..."];
    [ServiceManager books:[NSString stringWithFormat:@"%@",keyword] classID:classid.integerValue ranking:rank size:size andIndex:[NSString stringWithFormat:@"%d",index] withBlock:^(NSArray *resultArray, NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            if ([infoArray count] > 0) {
                [infoArray removeAllObjects];
            }
            [infoArray addObjectsFromArray:resultArray];
            if ([infoArray count]==6) {
                [self addFootView];
            }else {
                [infoTableView setTableFooterView:nil];
            }
            [infoTableView reloadData];
            [self hideHUD:YES];
        }
    }];
    
}

- (void)changeButtonImage:(UIButton *)sender {
    NSArray *buttonImageNameUp = @[@"bookcity_RecoUp", @"bookcity_ExceUp", @"bookcity_CataUp", @"bookcity_SearchUp"];
    NSArray *buttonImageNameDown = @[@"bookcity_RecoDown", @"bookcity_ExceDown", @"bookcity_CataDown", @"bookcity_SearchDown"];
    for (int i = 0; i < 4; i++) {
        UIButton *button = (UIButton *)[buttonArrays objectAtIndex:i];
        if (sender == button) {
            [sender setImage:[UIImage imageNamed:buttonImageNameDown[i]] forState:UIControlStateNormal];
        }else {
            [button setImage:[UIImage imageNamed:buttonImageNameUp[i]] forState:UIControlStateNormal];
        }
    }
}

- (void)changeRankButtonImage:(UIButton *)sender {
    NSArray *highlightImages = @[@"all_btn_hl", @"new_btn_hl", @"hot_btn_hl"];
    NSArray *images = @[@"all_btn", @"new_btn", @"hot_btn"];
    for (int i = 0; i<3; i++) {
        UIButton *button = rankBtns[i];
        if(sender == button) {
            [sender setBackgroundImage:[UIImage imageNamed:highlightImages[i]] forState:UIControlStateNormal];
        }else {
            [button setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        }
    }
}

- (void)getMore {
    NSString *keyWord = @"";
    NSInteger rankId = 0;
    if (currentType==RANK) {
        rankId = currentPage;
    } else {
        keyWord = _searchBar.text;
    }
    [self displayHUD:@"加载中..."];
    [ServiceManager books:keyWord
                  classID:0
                  ranking:currentPage
                     size:@"6"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex+1] withBlock:^(NSArray *resultArray, NSError *error) {
                     if (error) {
                         [self displayHUDError:nil message:NETWORK_ERROR];
                     }else {
                         if ([infoArray count]==0) {
                             [infoTableView setTableFooterView:nil];
                         }
                         [infoArray addObjectsFromArray:resultArray];
                         currentIndex++;
                         [infoTableView reloadData];
                         [self hideHUD:YES];
                     }
                 }];
}

- (void)addFootView {
    UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
    [infoTableView setTableFooterView:footview];
}

- (void)reloadDataByIndex:(id)sender {
    if (currentPage==[rankBtns indexOfObject:sender]+1)
        return;
    currentPage = [rankBtns indexOfObject:sender]+1;
    [self changeRankButtonImage:sender];
    [self loadDataWithKeyWord:@"" classId:0 ranking:currentPage size:@"6" andIndex:1];
}

- (void)loadRecommendData
{
    [infoTableView setFrame:CGRectMake(5, 44, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50)];
    [infoTableView setHidden:NO];
    [self displayHUD:@"加载中..."];
    [ServiceManager recommendBooksWithBlock:^(NSArray *resultArray, NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            if ([infoArray count]>0) {
                [infoArray removeAllObjects];
            }
            [infoArray addObjectsFromArray:resultArray];
            [self refreshRecommendDataWithArray:infoArray];
        }
    }];
}

- (void)refreshRecommendDataWithArray:(NSArray *)array
{
    NSString *lastKey = nil;
    if ([recommendTitlesArray count]>0) {
        [recommendTitlesArray removeAllObjects];
        [recommendArray removeAllObjects];
    }
    for (int i = 0; i < [array count]; i++) {
        Book *book = [array objectAtIndex:i];
        if (![recommendTitlesArray containsObject:book.recommendTitle]) {
            [recommendTitlesArray addObject:book.recommendTitle];
        }
        NSMutableArray *tmpArray;
        if ([lastKey isEqualToString:book.recommendTitle]) {
            tmpArray = [recommendArray objectAtIndex:[recommendTitlesArray indexOfObject:book.recommendTitle]];
        } else {
            tmpArray = [[NSMutableArray alloc] init];
            [recommendArray addObject:tmpArray];
        }
        [tmpArray addObject:book];
        lastKey = book.recommendTitle;
    }
    [infoTableView reloadData];
    [self hideHUD:YES];
}

- (void)loadCatagoryDataWithIndex:(NSInteger)index {
    CategoryDetailsViewController *childViewController = [[CategoryDetailsViewController alloc]init];
    [childViewController.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+20)];
    [self.navigationController pushViewController:childViewController animated:YES];
    [childViewController displayHUD:@"加载中..."];
    [ServiceManager books:@""
                  classID:index + 1
                  ranking:0
                     size:@"7"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex] withBlock:^(NSArray *resultArray, NSError *error) {
                     if (error) {
                         [childViewController displayHUDError:nil message:NETWORK_ERROR];
                     }else {
                         if ([infoArray count]>0) {
                             [infoArray removeAllObjects];
                         }
                         [infoArray addObjectsFromArray:resultArray];
                         [childViewController reloadDataWithArray:infoArray andCatagoryId:index+1];
                         currentPage = index +1;
                         [childViewController hideHUD:YES];
                     }
                 }];
}

- (void)buttonClick:(UIButton *)sender {
    [infoArray removeAllObjects];
    [infoTableView setTableFooterView:nil];
    [self changeButtonImage:sender];
    switch ([buttonArrays indexOfObject:sender]) {
        case 0:
            currentType = RECOMMEND;
            [infoTableView setTableHeaderView:nil];
            [[self BRHeaderView].titleLabel setText:@"推荐"];
            [rankView setHidden:YES];
            [self loadRecommendData];
            [infoTableView setHidden:NO];
            break;
        case 1:
            currentType = RANK;
            [infoTableView setTableHeaderView:nil];
            [[self BRHeaderView].titleLabel setText:@"排行"];
            [self loadDataWithKeyWord:@"" classId:0 ranking:XXSYRankingTypeAll size:@"6" andIndex:1];
            [rankView setHidden:NO];
            [infoTableView setHidden:NO];
            break;
        case 2:
            currentType = CATAGORY;
            [infoTableView setTableHeaderView:nil];
            [[self BRHeaderView].titleLabel setText:@"分类"];
            [rankView setHidden:YES];
            [infoTableView reloadData];
            break;
        case 3:
            currentType = SEARCH;
            [infoTableView setTableHeaderView:tableViewHeader];
            [[self BRHeaderView].titleLabel setText:@"搜索"];
            [rankView setHidden:YES];
            [infoTableView setHidden:NO];
            [infoTableView reloadData];
            break;
        default:
            break;
    }
}

#pragma mark tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (currentType == RECOMMEND) {
        return [recommendTitlesArray count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (currentType != RECOMMEND) {
        return 0;
    }
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (currentType != RECOMMEND) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [view setBackgroundColor:[UIColor colorWithRed:142.0/255.0 green:196.0/255.0 blue:102.0/255.0 alpha:1.0]];
    UILabel *label = [UILabel bookStoreLabelWithFrame:CGRectMake(0, 0, view.bounds.size.width, 30)];
    for (int i = 0; i<[recommendTitlesArray count]; i++) {
        if (section == i) {
            [label setText:[@"  " stringByAppendingString:[recommendTitlesArray objectAtIndex:i]]];
        }
    }
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentType == RECOMMEND) {
        for (int i = 0; i<[recommendTitlesArray count]; i++) {
            if (section == i) {
                NSMutableArray *array = [recommendArray objectAtIndex:i];
                return [array count];
            }
        }
    } else if (currentType == CATAGORY) {
        return [catagoryNames count];
    }
    return [infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (currentType == RECOMMEND) {
        if (cell == nil) {
            NSMutableArray *array = [recommendArray objectAtIndex:[indexPath section]];
            if (indexPath.row == 0) {
                cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
                Book *book = array[indexPath.row];
                [(BookCell *)cell setBook:book];
            }else {
                cell = [[BookCell alloc] initWithStyle:BookCellStyleSmall reuseIdentifier:@"MyCell"];
                Book *book = array[indexPath.row];
                [(BookCell *)cell setBook:book];
            }
        }
    }
    else if (currentType == CATAGORY){
        if (cell == nil) {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleCatagory reuseIdentifier:@"MyCell"];
            [(BookCell *)cell setCatagoryName:catagoryNames[[indexPath row]]];
        }
    } else {
        if (cell == nil) {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
            if ([infoArray count]>0) {
            Book *book = infoArray[indexPath.row];
            [(BookCell *)cell setBook:book];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (currentType != CATAGORY) {
        Book *book;
        if (currentType == RECOMMEND) {
            NSMutableArray *array = [recommendArray objectAtIndex:[indexPath section]];
            book = array[indexPath.row];
        } else {
            book = infoArray[indexPath.row];
        }
        BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
        [self.navigationController pushViewController:childViewController animated:YES];
    } else {
        [self loadCatagoryDataWithIndex:indexPath.row];
    }
}

@end
