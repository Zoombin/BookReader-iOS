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
#import "BookReaderDefaultsManager.h"

#define RECOMMEND 0
#define RANK 1
#define CATAGORY 2
#define SEARCH 3

@implementation BookStoreViewController
{
    int currentPage;
    int currentIndex;
    UILabel *titleLabel;
    
    UISearchBar *_searchBar;
    UIButton *_headerSearchButton;
    UIView *tableViewHeader;
    
    NSMutableArray *infoArray;
    UITableView *infoTableView;
    
    UIView *rankView;
    UIView *catagoryView;
    
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
    
    NSArray *hotkeyNames;
    NSMutableArray *hotkeyBtns;
	NSArray *hotwordsColors;
    
    BOOL isLoading;
}

- (id)init
{
    self = [super init];
    if (self) {
        catagoryNames = @[@"穿越",@"架空",@"都市",@"青春",@"魔幻",@"玄幻",@"豪门",@"历史",@"异能",@"短篇",@"耽美"];
        hotkeyNames = @[@"皇后", @"王妃", @"红楼", @"后宫", @"丑女",@"公主", @"总裁", @"冤家", @"杀手", @"女佣", @"郡主", @"小妾", @"王爷", @"将军", @"黑帮", @"精灵",@"丫鬟", @"校园", @"灵异", @"清穿", @"契约", @"豪门", @"励志", @"唯美", @"盗墓", @"搞笑", @"复仇",@"专情", @"花心", @"灵魂", @"职场", @"惊悚", @"种田", @"宫斗", @"代嫁", @"宝宝", @"重生", @"小三",@"都市", @"囧文", @"婚姻", @"青春", @"腹黑", @"废柴", @"仙侠", @"升级", @"免费", @"女强", @"异世",@"虐恋", @"苦情", @"高干", @"古武", @"修真", @"异能", @"宠文", @"纯爱", @"短篇", @"幻情", @"科幻",@"明星", @"魔幻", @"同人", @"网游", @"悬疑", @"神奇", @"爽文", @"召唤", @"冥修", @"技能", @"未来",@"学院"];
		hotwordsColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blackColor], [UIColor blueColor], [UIColor grayColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor cyanColor], [UIColor magentaColor], [UIColor purpleColor], [UIColor brownColor]];
        
        hotkeyBtns = [NSMutableArray array];
        recommendArray = [[NSMutableArray alloc] init];
        infoArray = [[NSMutableArray alloc] init];
        recommendTitlesArray = [[NSMutableArray alloc] init];
        
        rankBtns = [[NSMutableArray alloc] init];
//        currentType = RECOMMEND;
        currentPage = 1;
        currentIndex = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setHideBackBtn:YES];
    [self setTitle:@"书城"];
    
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-45, self.view.bounds.size.width, 50)];
    [bottomView setImage:[UIImage imageNamed:@"bookstore_bottom_bar"]];
    [self.view addSubview:bottomView];
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [bookShelfButton setFrame:CGRectMake(260, 3, 50, 32)];
    [self.view addSubview:bookShelfButton];
    
    NSArray *buttonImagesNormal = @[@"bookstore_reco", @"bookstore_rank", @"bookstore_cata", @"bookstore_search"];
    NSArray *buttonImagesHighlighted = @[@"bookstore_reco_hl", @"bookstore_rank_hl", @"bookstore_cata_hl", @"bookstore_search_hl"];
    float width = 53;
    float delta = (bottomView.frame.size.width - width * 4) / 5;
	NSMutableArray *buttons = [NSMutableArray array];
    for (int i=0; i<[buttonImagesHighlighted count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:buttonImagesHighlighted[i]] forState:UIControlStateHighlighted];
		[button setBackgroundImage:[UIImage imageNamed:buttonImagesHighlighted[i]] forState:UIControlStateSelected];
        [button setBackgroundImage:[UIImage imageNamed:buttonImagesNormal[i]] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(delta * (i + 1) + i * width, self.view.bounds.size.height - 45, width, 50)];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [buttons addObject:button];
    }
    
    recommendButton = buttons[0];
    rankButton = buttons[1];
    cataButton = buttons[2];
    searchButton = buttons[3];
    
    tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    [tableViewHeader setBackgroundColor:[UIColor clearColor]];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 65, 42)];
    [[_searchBar.subviews objectAtIndex:0]removeFromSuperview];
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor blackColor];
    [_searchBar setPlaceholder:@"请输入书名、作者"];
    UITextField *searchField;
	NSUInteger numViews = [_searchBar.subviews count];
	for(int i = 0; i < numViews; i++) {
		if([[_searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
			searchField = [_searchBar.subviews objectAtIndex:i];
            [searchField setBorderStyle:UITextBorderStyleRoundedRect];
            searchField.leftView = nil;
		}
	}
    [_searchBar layoutSubviews];
    [tableViewHeader addSubview:_searchBar];
    
    _headerSearchButton = [UIButton createButtonWithFrame:CGRectMake(CGRectGetMaxX(_searchBar.frame), 5, 45, 30)];
    [_headerSearchButton addTarget:self action:@selector(searchBarSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerSearchButton setBackgroundImage:[UIImage imageNamed:@"bookstore_search_btn"] forState:UIControlStateNormal];
    [tableViewHeader addSubview:_headerSearchButton];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-10, self.view.bounds.size.height-44-50)];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(8, 44, self.view.bounds.size.width-16, self.view.bounds.size.height-44-50) style:UITableViewStylePlain];
    [infoTableView.layer setCornerRadius:4];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setBackgroundView:backgroundView];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];
    
    catagoryView = [[UIView alloc] initWithFrame:infoTableView.frame];
    [catagoryView setBackgroundColor:[UIColor colorWithRed:237.0/255.0 green:235.0/255.0 blue:237.0/255.0 alpha:1.0]];
    [self showCatagoryViewBtn];
    [self.view addSubview:catagoryView];
    
    catagoryView.hidden = YES;
    
    [self initRandButton];
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [backgroundView addGestureRecognizer:gestureRecognizer];
    
    [self removeGestureRecognizer];
	[self buttonClick:recommendButton];
}

- (void)showCatagoryViewBtn
{
    int k = 0;
    int offSet = (catagoryView.frame.size.width-20) - (130 *2);
    
    UIColor *backGroundColor = [UIColor colorWithRed:225.0/255.0 green:223.0/255.0 blue:213.0/255.0 alpha:1.0];
    UIView *leftBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 28, 130, 3+(51*6))];
    [leftBackGroundView.layer setCornerRadius:5];
    [leftBackGroundView setBackgroundColor:backGroundColor];
    [catagoryView addSubview:leftBackGroundView];
    
    UIView *rightBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(10+(130+offSet), 28, 130, 3+(51*5))];
    [rightBackGroundView.layer setCornerRadius:5];
    [rightBackGroundView setBackgroundColor:backGroundColor];
    [catagoryView addSubview:rightBackGroundView];
    
    
    for (int i = 0; i < [catagoryNames count]; i++) {
        if (i%2==0&&i!=0) {
            k++;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:catagoryNames[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:backGroundColor];
        [button setFrame:CGRectMake(10+(130+offSet) *(i%2 ==0 ? 0 :1), 30+ 51 *k, 130, 50)];
        [button setTag:i];
        [button addTarget:self action:@selector(loadCatagoryDataWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [catagoryView addSubview:button];
        if (i!=9&i!=10) {
            UIView *separteLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame), 130, 1)];
            [separteLine setBackgroundColor:[UIColor whiteColor]];
            [catagoryView addSubview:separteLine];
        }
    }
}

- (void)hideKeyboard {
    [_searchBar resignFirstResponder];
}

- (void)initRandButton {
    rankView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, infoTableView.bounds.size.width, 50)];
    float width = (rankView.bounds.size.width - 40)/3;
    CGRect frame = CGRectMake(20, 10, width, 30);
    
    UIView *rankBtnBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(18, 8, rankView.bounds.size.width - 36, 34)];
    [rankBtnBackGroundView.layer setCornerRadius:5];
    [rankBtnBackGroundView.layer setMasksToBounds:YES];
    [rankBtnBackGroundView.layer setBorderColor:[UIColor colorWithRed:206.0/255.0 green:195.0/255.0 blue:173.0/255.0 alpha:1.0].CGColor];
    [rankBtnBackGroundView.layer setBorderWidth:0.5];
    [rankBtnBackGroundView setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:211.0/255.0 blue:187.0/255.0 alpha:1.0]];
    [rankView addSubview:rankBtnBackGroundView];
    
    NSArray *buttonNames = @[@"总榜", @"最新", @"最热"];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        [button.layer setCornerRadius:5];
        [button.layer setMasksToBounds:YES];
        [button setTitleColor:[UIColor colorWithRed:71.0/255.0 green:0.0/255.0 blue:1.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        if (i==0) {
            [button setBackgroundColor:[UIColor whiteColor]];
        } else {
            [button setBackgroundColor:[UIColor clearColor]];
        }
        [button addTarget:self action:@selector(reloadDataByIndex:) forControlEvents:UIControlEventTouchUpInside];
        if (i!=0) {
            frame = CGRectMake(CGRectGetMaxX(frame), 10, width, frame.size.height);
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
    [ServiceManager books:[NSString stringWithFormat:@"%@",keyword] classID:classid.integerValue ranking:rank size:size andIndex:[NSString stringWithFormat:@"%d",index] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        }else {
            if ([infoArray count] > 0) {
                [infoArray removeAllObjects];
            }
            if ([resultArray count]>0) {
                [self hideAllHotkeyBtns];
            } else if(currentType == SEARCH&&[resultArray count]==0) {
                [self showHotkeyBtns];
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

- (void)changeRankButtonImage:(UIButton *)sender {
    for (int i = 0; i<3; i++) {
        UIButton *button = rankBtns[i];
        if(sender == button) {
            [sender setBackgroundColor:[UIColor whiteColor]];
        }else {
            [button setBackgroundColor:[UIColor clearColor]];
        }
    }
}

- (void)getMore {
    NSString *keyWord = @"";
    NSInteger rankId = 0;
    if (currentType == RANK) {
        rankId = currentPage;
    } else {
        if (_searchBar.text) {
            keyWord = _searchBar.text;
        }
    }
    [ServiceManager books:keyWord
                  classID:0
                  ranking:rankId
                     size:@"6"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex+1] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
                     if (error) {
                         [self displayHUDError:nil message:NETWORK_ERROR];
                     }else {
                         if ([infoArray count]==0) {
                             [infoTableView setTableFooterView:nil];
                         } else {
                         [infoArray addObjectsFromArray:resultArray];
                         }
                         currentIndex++;
                         [infoTableView reloadData];
                         isLoading = NO;
                         //                         [self hideHUD:YES];
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

- (void)loadRecommendDataWithIndex:(NSInteger)index
{
    if (index==1) {
        [self displayHUD:@"加载中..."];
        [infoArray removeAllObjects];
    }
    [infoTableView setHidden:NO];
    [ServiceManager recommendBooksIndex:index
                              WithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
                                  if (error) {
                                      [self displayHUDError:nil message:NETWORK_ERROR];
                                  }else {
                                      [infoArray addObjectsFromArray:resultArray];
                                      [self refreshRecommendDataWithArray:infoArray];
                                      if (index<=5) {
                                          [self loadRecommendDataWithIndex:index+1];
                                      }
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
        if (book.recommendTitle == nil) {
            break;
        }
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

- (void)loadCatagoryDataWithIndex:(id)sender {
    NSInteger index = [sender tag];
    CategoryDetailsViewController *childViewController = [[CategoryDetailsViewController alloc]init];
    [childViewController.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+20)];
    [self.navigationController pushViewController:childViewController animated:YES];
    [childViewController displayHUD:@"加载中..."];
    [ServiceManager books:@""
                  classID:index + 1
                  ranking:0
                     size:@"7"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
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

- (void)resetBottomButtons
{
	recommendButton.selected = NO;
	rankButton.selected = NO;
	cataButton.selected = NO;
	searchButton.selected = NO;
}

- (void)buttonClick:(UIButton *)sender {
	if (sender.selected) return;
	[self resetBottomButtons];
	sender.selected = YES;
    catagoryView.hidden = YES;
    [self hideAllHotkeyBtns];
    [infoArray removeAllObjects];
    [infoTableView reloadData];
    [infoTableView setTableFooterView:nil];
	
	if (sender == recommendButton) {
		currentType = RECOMMEND;
		[infoTableView setTableHeaderView:nil];
		[[self BRHeaderView].titleLabel setText:@"推荐"];
		[rankView setHidden:YES];
		[self loadRecommendDataWithIndex:1];
		[infoTableView setHidden:NO];		
	} else if (sender == rankButton) {
		currentType = RANK;
		[infoTableView setTableHeaderView:rankView];
		[[self BRHeaderView].titleLabel setText:@"排行"];
		[self loadDataWithKeyWord:@"" classId:0 ranking:XXSYRankingTypeAll size:@"6" andIndex:1];
		[rankView setHidden:NO];
		[infoTableView setHidden:NO];		
	} else if (sender == cataButton) {
		currentType = CATAGORY;
		catagoryView.hidden = NO;
		[infoTableView setTableHeaderView:nil];
		[[self BRHeaderView].titleLabel setText:@"分类"];
		[rankView setHidden:YES];
		[infoTableView reloadData];		
	} else if (sender == searchButton) {
		currentType = SEARCH;
		[infoTableView setTableHeaderView:tableViewHeader];
		[[self BRHeaderView].titleLabel setText:@"搜索"];
		[rankView setHidden:YES];
		[infoTableView setHidden:NO];
		[infoTableView reloadData];
		[self showHotkeyBtns];
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
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [view setImage:[UIImage imageNamed:@"bookstore_recommend_title"]];
    UILabel *label = [UILabel bookStoreLabelWithFrame:CGRectMake(0, 0, view.bounds.size.width, 30)];
    [label setTextColor:[UIColor blackColor]];
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
        if (!cell) {
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
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        }
    }
    else if (currentType != CATAGORY){
        if (!cell) {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            if ([infoArray count] > 0) {
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
    }
}

//显示热词
- (void)showHotkeyBtns {
    [self hideAllHotkeyBtns];
    NSMutableArray *hotNamesIndex = [NSMutableArray array];
    while (hotNamesIndex.count < 10) {
        int randomNum = arc4random() % hotkeyNames.count;
        if (![hotNamesIndex containsObject:@(randomNum)]) {
            [hotNamesIndex addObject:@(randomNum)];
        }
    }
    NSArray *cgrectArr = [self randomRect:10];
    for (int i = 0; i < [cgrectArr count]; i++) {
        NSString *cgrectstring = [cgrectArr objectAtIndex:i];
        UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tmpButton setFrame:CGRectFromString(cgrectstring)];
        NSNumber *indexNum = [hotNamesIndex objectAtIndex:i];
        [tmpButton setTitle:hotkeyNames[indexNum.integerValue] forState:UIControlStateNormal];
        NSInteger colorIndex = arc4random() % hotwordsColors.count;
        [tmpButton setTitleColor:hotwordsColors[colorIndex] forState:UIControlStateNormal];
        [tmpButton.titleLabel setFont:[UIFont boldSystemFontOfSize:arc4random() % 10 + 15]];
        [tmpButton addTarget:self action:@selector(hotkeybuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [infoTableView addSubview:tmpButton];
        [hotkeyBtns addObject:tmpButton];
    }
}

- (void)hideAllHotkeyBtns
{
    for (UIButton *button in hotkeyBtns) {
        [button removeFromSuperview];
    }
}

- (void)hotkeybuttonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    _searchBar.text = button.titleLabel.text;
    [self searchBarSearchButtonClicked:_searchBar];
}

- (NSArray *)randomRect:(int)rectCount {
    NSMutableArray *rectArray = [NSMutableArray array];
    while([rectArray count] < rectCount) {
        int x =arc4random()%200+15;    //随机坐标x
        int y = arc4random()%200+100;//随机坐标y
        CGRect rect = CGRectMake(x, y, 80, 30);
        if ([rectArray count] == 0) {
            [rectArray addObject:NSStringFromCGRect(rect)];
            continue;
        }
        BOOL bIntersects = NO;
        for (int i = 0; i < [rectArray count]; ++i) {
            CGRect tmpRect = CGRectFromString([rectArray objectAtIndex:i]);
            if (CGRectIntersectsRect(rect, tmpRect)) {
                bIntersects = YES;
            }
        }
        if (bIntersects == NO) {
            [rectArray addObject:NSStringFromCGRect(rect)];
        }
    }
    return rectArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([infoArray count] == 0) {
        return;
    }
    if (currentType == RANK || currentType == SEARCH) {
        if(scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height - 100) {
            if (!isLoading) {
                isLoading = YES;
                NSLog(@"可刷新");
                [self getMore];
            }
        }
    }
}

@end
