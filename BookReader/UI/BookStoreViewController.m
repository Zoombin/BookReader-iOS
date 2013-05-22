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
#import "BookCell.h"

#define RECOMMEND 0
#define RANK 1
#define CATAGORY 2
#define SEARCH 3

#define CHILDVIEW_FRAME   CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44-50)
@implementation BookStoreViewController
{
    int currentPage;
    int currentIndex;
    UILabel       *titleLabel;
    
    UISearchBar *_searchBar;
    
    NSMutableArray *buttonArrays; //4个分类的按钮array
    
    NSMutableArray *infoArray;
    UITableView *infoTableView;
    
    UIView *rankView;
    UIView *categoryView;
    UIView *searchView;
    
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
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
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
        [self showSearchBarWithBoolValue:NO];
        [rankView setHidden:YES];
        [categoryView setHidden:YES];
        [self loadRecommendData];
        [infoTableView setHidden:NO];
        for (int i = 0; i<3; i++)
        {
            UIButton *button = (UIButton *)[self.view viewWithTag:i+10000];
            if (i==0)
            {
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }else
            {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
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

- (void)shouldRefresh {
    shouldRefresh = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    shouldRefresh = YES;
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
	// Do any additional setup after loading the view.
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:@"书城"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:titleLabel];
    
    UIImageView *bottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    [bottomImage setImage:[UIImage imageNamed:@"iphone_qqreader_feedback_bg"]];
    [self.view addSubview:bottomImage];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [self.view addSubview:bookShelfButton];
    
    NSArray *buttonImageNameDown = @[@"bookcity_RecoDown", @"bookcity_ExceDown", @"bookcity_CataDown", @"bookcity_SearchDown"];
    NSArray *buttonImageNameUp = @[@"bookcity_RecoUp", @"bookcity_ExceUp", @"bookcity_CataUp", @"bookcity_SearchUp"];
    for (int i=0; i<[buttonImageNameDown count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:buttonImageNameDown[i]] forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:buttonImageNameUp[i]] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(i*self.view.bounds.size.width/4, self.view.bounds.size.height-47, self.view.bounds.size.width/4, 47)];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [buttonArrays addObject:button];
    }
    
    recommendButton = buttonArrays[0];
    rankButton = buttonArrays[1];
    cataButton = buttonArrays[2];
    searchButton = buttonArrays[3];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 40)];
    [[_searchBar.subviews objectAtIndex:0]removeFromSuperview];
    _searchBar.delegate = self;
    [_searchBar setHidden:YES];
    _searchBar.tintColor = [UIColor blackColor];
    [_searchBar setPlaceholder:@"请输入书名作者"];
    [self.view addSubview:_searchBar];
    
    [self initCategoryButton];
    [self initRandButton];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 44, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50) style:UITableViewStylePlain];
    [infoTableView.layer setCornerRadius:4];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setBackgroundColor:[UIColor colorWithRed:244.0/255.0 green:240.0/255.0 blue:230.0/255.0 alpha:1.0]];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];
}

- (void)initCategoryButton {
    categoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-50-44)];
    [categoryView setHidden:YES];
    [categoryView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:categoryView];
    
    NSArray *buttonNames = @[@"穿越",@"架空",@"都市",@"青春",@"魔幻",@"玄幻",@"豪门",@"历史",@"异能",@"短篇",@"耽美"];
    for (int i=0; i<[buttonNames count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTag:i];
        if (i%2==0) {
            [button setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:239.0/255.0 blue:230.0/255.0 alpha:1.0]];
        } else {
           [button setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
        }
        [button setFrame:CGRectMake(30, 20+i*30, self.view.bounds.size.width-60, 30)];
        [button setTitleColor:[UIColor hexRGB:0xfbbf90] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [categoryView addSubview:button];
    }
}

- (void)initRandButton {
    rankView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 40)];
    [rankView setBackgroundColor:[UIColor clearColor]];
    [rankView setHidden:YES];
    [self.view addSubview:rankView];
    NSArray *buttonNames = @[@"总榜", @"最新", @"最热"];
    for (int i = 0; i<3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if (i==0) {
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(reloadDataByIndex:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(i*(self.view.bounds.size.width/3)+0, 0, self.view.bounds.size.width/3, 40)];
        [rankView addSubview:button];
        [rankBtns addObject:button];
    }
    allRankButton = rankBtns[0];
    newRankButton = rankBtns[1];
    hotRankButton = rankBtns[2];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBar.text length]>0) {
        [self loadDataWithKeyWord:_searchBar.text classId:@"0" ranking:@"0" size:@"5" andIndex:1];
    }
    [_searchBar resignFirstResponder];
}

- (void)loadDataWithKeyWord:(NSString *)keyword
                    classId:(NSString *)classid
                    ranking:(NSString *)rank
                       size:(NSString *)size
                   andIndex:(NSInteger)index
{
    currentIndex = 1;
    [self displayHUD:@"加载中..."];
    [ServiceManager books:[NSString stringWithFormat:@"%@",keyword] classID:classid ranking:rank size:size andIndex:[NSString stringWithFormat:@"%d",index] withBlock:^(NSArray *reArray, NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            if ([infoArray count] > 0) {
                [infoArray removeAllObjects];
            }
            [infoArray addObjectsFromArray:reArray];
            if ([infoArray count]==5) {
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
    for (int i = 0; i<3; i++) {
        UIButton *button = rankBtns[i];
        if(sender == button) {
            [sender setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }else {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void)getMore {
    NSString *keyWord = @"";
    NSString *rankId = @"0";
    if (currentType==RANK) {
        rankId = [NSString stringWithFormat:@"%d",currentPage];
    } else {
        keyWord = _searchBar.text;
    }
    [self displayHUD:@"加载中..."];
    [ServiceManager books:@""
                  classID:@"0"
                  ranking:rankId
                     size:@"5"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex+1] withBlock:^(NSArray *result, NSError *error) {
                     if (error) {
                         [self displayHUDError:nil message:NETWORK_ERROR];
                     }else {
                         if ([infoArray count]==0) {
                             [infoTableView setTableFooterView:nil];
                         }
                         [infoArray addObjectsFromArray:result];
                         currentIndex++;
                         [infoTableView reloadData];
                         [self hideHUD:YES];
                     }
                 }];
}

- (void)addFootView {
    UIView *footview = [[UIView alloc]initWithFrame:CGRectMake(-4, 0, 316, 26)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(-4, 0, 316, 26)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setTitle:@"查看更多..." forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:UITextAlignmentCenter];
    [button addTarget:self action:@selector(getMore) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:button];
    [infoTableView setTableFooterView:footview];
}

- (void)reloadDataByIndex:(id)sender {
    if (currentPage==[rankBtns indexOfObject:sender]+1)
        return;
    currentPage = [rankBtns indexOfObject:sender]+1;
    [self changeRankButtonImage:sender];
    [self loadDataWithKeyWord:@"" classId:@"0" ranking:[NSString stringWithFormat:@"%d",currentPage] size:@"5" andIndex:1];
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

- (void)showSearchBarWithBoolValue:(BOOL)boolValue
{
    if ([infoArray count] > 0) {
        [infoArray removeAllObjects];
        [infoTableView reloadData];
    }
    if(boolValue==YES){
        [_searchBar setHidden:!boolValue];
        [infoTableView setFrame:CGRectMake(5, 44+40, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50-40)];
    }else {
        [_searchBar setHidden:!boolValue];
    }
}

- (void)buttonClicked:(id)sender {
    CategoryDetailsViewController *childViewController = [[CategoryDetailsViewController alloc]init];
    [childViewController.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+20)];
    [self.navigationController pushViewController:childViewController animated:YES];
    [childViewController displayHUD:@"加载中..."];
    [ServiceManager books:@""
                  classID:[NSString stringWithFormat:@"%d",[sender tag]+1]
                  ranking:@"0"
                     size:@"5"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex] withBlock:^(NSArray *result, NSError *error) {
                     if (error) {
                         [childViewController displayHUDError:nil message:NETWORK_ERROR];
                     }else {
                         if ([infoArray count]>0) {
                             [infoArray removeAllObjects];
                         }
                         [infoArray addObjectsFromArray:result];
                         [childViewController reloadDataWithArray:infoArray andCatagoryId:[sender tag]+1];
                         currentPage = [sender tag]+1;
                         [childViewController hideHUD:YES];
                     }
                 }];
}

- (void)buttonClick:(UIButton *)sender {
    [infoTableView setTableFooterView:nil];
    [self changeButtonImage:sender];
    switch ([buttonArrays indexOfObject:sender]) {
        case 0:
            currentType = RECOMMEND;
            [self showSearchBarWithBoolValue:NO];
            [rankView setHidden:YES];
            [categoryView setHidden:YES];
            [self loadRecommendData];
            [infoTableView setHidden:NO];
            break;
        case 1:
            currentType = RANK;
            [self loadDataWithKeyWord:@"" classId:@"0" ranking:@"1" size:@"5" andIndex:1];
            [infoTableView setFrame:CGRectMake(5, 44+40, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50-40)];
            [self showSearchBarWithBoolValue:NO];
            [rankView setHidden:NO];
            [categoryView setHidden:YES];
            [infoTableView setHidden:NO];
            break;
        case 2:
            currentType = CATAGORY;
            [self showSearchBarWithBoolValue:NO];
            [rankView setHidden:YES];
            [categoryView setHidden:NO];
            [infoTableView setHidden:YES];
            break;
        case 3:
            currentType = SEARCH;
            [self showSearchBarWithBoolValue:YES];
            [rankView setHidden:YES];
            [categoryView setHidden:YES];
            [infoTableView setHidden:NO];
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
    UILabel *label = [UILabel bookStoreLabelWithFrame:CGRectMake(0, 0, view.bounds.size.width, 30)];
        for (int i = 0; i<[recommendTitlesArray count]; i++) {
            if (section == i) {
                [label setText:[@"\t\t" stringByAppendingString:[recommendTitlesArray objectAtIndex:i]]];
            }
        }
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentType == RECOMMEND) {
        for (int i = 0; i<[recommendTitlesArray count]; i++) {
            if (section == i) {
                NSMutableArray *array = [recommendArray objectAtIndex:i];
                return [array count];
            }
        }
    }
    return [infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentType == RECOMMEND) {
        if (indexPath.row == 0) {
            return [BookCell height];
        }
        else {
            return 30;
        }
    }
    return [BookCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    else {
        if (cell == nil) {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
            Book *book = infoArray[indexPath.row];
            [(BookCell *)cell setBook:book];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Book *book;
    if (currentType == RECOMMEND) {
        NSMutableArray *array = [recommendArray objectAtIndex:[indexPath section]];
        book = array[indexPath.row];
    } else {
        book = infoArray[indexPath.row];
    }
    BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
    [self.navigationController pushViewController:childViewController animated:YES];
}

@end
