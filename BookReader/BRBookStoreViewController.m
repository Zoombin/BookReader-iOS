//
//  ReBookStoreViewController.m
//  BookReader
//
//  Created by ZoomBin on 13-3-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BRBookStoreViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+BookReader.h"
#import "ServiceManager.h"
#import "BookDetailsViewController.h"
#import "UIViewController+HUD.h"
#import "UIColor+Hex.h"
#import "CategoryDetailsViewController.h"
#import "UIView+BookReader.h"
#import "BookCell.h"
#import "BRBottomView.h"

#define RECOMMEND 0
#define RANK 1
#define CATAGORY 2
#define SEARCH 3

@interface BRBookStoreViewController () <UIScrollViewDelegate,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (readwrite) int currentPage;
@property (readwrite) int currentIndex;
@property (readwrite) UILabel *titleLabel;
@property (readwrite) UISearchBar *searchBar;
@property (readwrite) UIButton *headerSearchButton;
@property (readwrite) UIView *tableViewHeader;
@property (readwrite) NSMutableArray *infoArray;
@property (readwrite) UITableView *infoTableView;
@property (readwrite) UIView *rankView;
@property (readwrite) UIView *catagoryView;
@property (readwrite) int currentType;
@property (readwrite) NSMutableArray *recommendArray;
@property (readwrite) NSMutableArray *recommendTitlesArray;
@property (readwrite) UIButton *recommendButton;
@property (readwrite) UIButton *rankButton;
@property (readwrite) UIButton *cataButton;
@property (readwrite) UIButton *searchButton;
@property (readwrite) UIButton *allRankButton;
@property (readwrite) UIButton *latestRankButton;
@property (readwrite) UIButton *hotRankButton;
@property (readwrite) NSMutableArray *rankBtns;
@property (readwrite) UITapGestureRecognizer *gestureRecognizer;
@property (readwrite) NSArray *catagoryNames;
@property (readwrite) NSMutableArray *catagoryBtns;
@property (readwrite) NSMutableArray *hotkeyBtns;
@property (readwrite) NSArray *hotwordsColors;
@property (readwrite) BOOL isLoading;
@property (readwrite) NSMutableArray *recommandArray;
@property (readwrite) NSMutableArray *searchArray;
@property (readwrite) NSMutableArray *allArray;
@property (readwrite) NSMutableArray *latestArray;
@property (readwrite) NSMutableArray *hotArray;
@property (readwrite) BRBottomView *bottomView;

@end

@implementation BRBookStoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _catagoryNames = [ServiceManager bookCategories];
		_hotwordsColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blackColor], [UIColor blueColor], [UIColor grayColor], [UIColor yellowColor], [UIColor orangeColor], [UIColor cyanColor], [UIColor magentaColor], [UIColor purpleColor], [UIColor brownColor]];
        
        _hotkeyBtns = [NSMutableArray array];
        _recommendArray = [[NSMutableArray alloc] init];
        _infoArray = [[NSMutableArray alloc] init];
        _recommendTitlesArray = [[NSMutableArray alloc] init];
        _catagoryBtns = [[NSMutableArray alloc] init];
        
        _rankBtns = [[NSMutableArray alloc] init];
		
        _currentPage = 1;
        _currentIndex = 1;
        
        _recommandArray = [[NSMutableArray alloc] init];
        _searchArray = [[NSMutableArray alloc] init];
        _allArray = [[NSMutableArray alloc] init];
        _hotArray = [[NSMutableArray alloc] init];
        _latestArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.hidden = YES;
	
	CGSize fullSize = self.view.bounds.size;
	CGSize buttonSize = CGSizeMake(fullSize.width / 4, 45);
	CGFloat startX = 0;
	
	UIImageView *tabBarBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, 44)];
	[tabBarBGView setImage:[UIImage imageNamed:@"navigationbar_bkg"]];
	tabBarBGView.userInteractionEnabled = YES;
	[self.view addSubview:tabBarBGView];
	
    _recommendButton = [UIButton bookStoreTabBarButtonWithFrame:CGRectMake(startX, 0, buttonSize.width, buttonSize.height) andStyle:BRBookStoreTabBarButtonStyleRecomend];
    [_recommendButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_recommendButton setTitle:@"推荐" forState:UIControlStateNormal];
    [tabBarBGView addSubview:_recommendButton];
    
	startX = CGRectGetMaxX(_recommendButton.frame);
	
    _rankButton = [UIButton bookStoreTabBarButtonWithFrame:CGRectMake(startX, 0, buttonSize.width, buttonSize.height) andStyle:BRBookStoreTabBarButtonStyleRank];
    [_rankButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_rankButton setTitle:@"排行" forState:UIControlStateNormal];
    [tabBarBGView addSubview:_rankButton];
	
	startX = CGRectGetMaxX(_rankButton.frame);
    
    _cataButton = [UIButton bookStoreTabBarButtonWithFrame:CGRectMake(startX, 0, buttonSize.width, buttonSize.height) andStyle:BRBookStoreTabBarButtonStyleCatagory];
    [_cataButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_cataButton setTitle:@"分类" forState:UIControlStateNormal];
    [tabBarBGView addSubview:_cataButton];
    
	startX = CGRectGetMaxX(_cataButton.frame);
	
    _searchButton = [UIButton bookStoreTabBarButtonWithFrame:CGRectMake(startX, 0, buttonSize.width, buttonSize.height) andStyle:BRBookStoreTabBarButtonStyleSearch];
    [_searchButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
	[_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
    [tabBarBGView addSubview:_searchButton];
    
    _tableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, 40)];
    [_tableViewHeader setBackgroundColor:[UIColor clearColor]];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, fullSize.width - 65, 42)];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[_searchBar.subviews objectAtIndex:0] removeFromSuperview];
    } else {
        [_searchBar setBarStyle:UIBarStyleBlack];
        [_searchBar performSelector:@selector(setBarTintColor:) withObject:[UIColor clearColor]];
    }
    
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor blackColor];
    [_searchBar setPlaceholder:@"请输入书名、作者"];
    UITextField *searchField;
	NSUInteger numViews = [_searchBar.subviews count];
	for(int i = 0; i < numViews; i++) {
		if([[_searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            NSLog(@"有textField");
			searchField = [_searchBar.subviews objectAtIndex:i];
            [searchField setBorderStyle:UITextBorderStyleRoundedRect];
            searchField.leftView = nil;
		}
	}
    [_searchBar layoutSubviews];
    [_tableViewHeader addSubview:_searchBar];
    
    _headerSearchButton = [UIButton createButtonWithFrame:CGRectMake(CGRectGetMaxX(_searchBar.frame), 5, 45, 30)];
    [_headerSearchButton addTarget:self action:@selector(searchBarSearchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_headerSearchButton setBackgroundImage:[UIImage imageNamed:@"bookstore_search_btn"] forState:UIControlStateNormal];
    [_tableViewHeader addSubview:_headerSearchButton];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fullSize.width - 10, fullSize.height - [BRHeaderView height] - 50)];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    
    _infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(8, [BRHeaderView height], fullSize.width - 16, fullSize.height  - [BRHeaderView height] - [BRBottomView height]) style:UITableViewStylePlain];
    [_infoTableView.layer setCornerRadius:4];
    [_infoTableView.layer setMasksToBounds:YES];
    [_infoTableView setBackgroundView:backgroundView];
    [_infoTableView setBackgroundColor:[UIColor clearColor]];
    [_infoTableView setDataSource:self];
    [_infoTableView setDelegate:self];
    [_infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_infoTableView];
	
	_bottomView = [[BRBottomView alloc] initWithFrame:CGRectMake(0, fullSize.height - [BRBottomView height], fullSize.width, [BRBottomView height])];
	_bottomView.bookstoreButton.selected = YES;
	[self.view addSubview:_bottomView];
    
    _catagoryView = [[UIView alloc] initWithFrame:_infoTableView.frame];
    [self showCatagoryViewBtn];
    [self.view addSubview:_catagoryView];
    
    _catagoryView.hidden = YES;
    
    [self initRandButton];
    
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [backgroundView addGestureRecognizer:_gestureRecognizer];
    
	self.hideKeyboardRecognzier.enabled = NO;
	[self buttonClick:_recommendButton];
	
	[[NSNotificationCenter defaultCenter] addObserver:_bottomView selector:@selector(refresh) name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (![ServiceManager showDialogs]) {
		[ServiceManager showDialogsSettingsByAppVersion:[NSString appVersion] withBlock:^(BOOL success, NSError *error) {
			[_bottomView refresh];
		}];
	} else {
		[_bottomView refresh];
	}
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:_bottomView name:REFRESH_BOTTOM_TAB_NOTIFICATION_IDENTIFIER object:nil];
}

- (void)showCatagoryViewBtn
{
    int k = 0;
    int offSet = (_catagoryView.frame.size.width-20) - (130 *2);
    
    UIColor *backGroundColor = [UIColor colorWithRed:225.0/255.0 green:223.0/255.0 blue:213.0/255.0 alpha:1.0];
    UIView *leftBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(10, 28, 130, 3+(51*6))];
    [leftBackGroundView.layer setCornerRadius:5];
    [leftBackGroundView setBackgroundColor:backGroundColor];
    [_catagoryView addSubview:leftBackGroundView];
    
    UIView *rightBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(10+(130+offSet), 28, 130, 3+(51*5))];
    [rightBackGroundView.layer setCornerRadius:5];
    [rightBackGroundView setBackgroundColor:backGroundColor];
    [_catagoryView addSubview:rightBackGroundView];
    
    
    for (int i = 0; i < [_catagoryNames count]; i++) {
        if (i % 2 == 0 && i != 0) {
            k++;
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:_catagoryNames[i] forState:UIControlStateNormal];
		button.showsTouchWhenHighlighted = YES;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundColor:backGroundColor];
        [button setFrame:CGRectMake(10 + (130 + offSet) *(i%2 ==0 ? 0 :1), 30+ 51 *k, 130, 50)];
        [button setTag:i];
        [button addTarget:self action:@selector(loadCatagoryDataWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [_catagoryView addSubview:button];
        [_catagoryBtns addObject:button];
        if (i!=9&i!=10) {
            UIView *separteLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame), 130, 1)];
            [separteLine setBackgroundColor:[UIColor whiteColor]];
            [_catagoryView addSubview:separteLine];
        }
    }
}

- (void)hideKeyboard {
    [_searchBar resignFirstResponder];
}

- (void)initRandButton {
    _rankView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, _infoTableView.bounds.size.width, 50)];
    float width = (_rankView.bounds.size.width - 40)/3;
    CGRect frame = CGRectMake(20, 10, width, 30);
    
    UIView *rankBtnBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(18, 8, _rankView.bounds.size.width - 36, 34)];
    [rankBtnBackGroundView.layer setCornerRadius:5];
    [rankBtnBackGroundView.layer setMasksToBounds:YES];
    [rankBtnBackGroundView.layer setBorderColor:[UIColor colorWithRed:206.0/255.0 green:195.0/255.0 blue:173.0/255.0 alpha:1.0].CGColor];
    [rankBtnBackGroundView.layer setBorderWidth:0.5];
    [rankBtnBackGroundView setBackgroundColor:[UIColor colorWithRed:223.0/255.0 green:211.0/255.0 blue:187.0/255.0 alpha:1.0]];
    [_rankView addSubview:rankBtnBackGroundView];
    
    _allRankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allRankButton setTitle:@"热评" forState:UIControlStateNormal];
    [_allRankButton.layer setCornerRadius:5];
    [_allRankButton.layer setMasksToBounds:YES];
    [_allRankButton setTitleColor:[UIColor rankButtonTextColor] forState:UIControlStateNormal];
    [_allRankButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_allRankButton setBackgroundColor:[UIColor whiteColor]];
    [_allRankButton addTarget:self action:@selector(reloadDataByIndex:) forControlEvents:UIControlEventTouchUpInside];
    [_allRankButton setFrame:frame];
    [_rankView addSubview:_allRankButton];
    [_rankBtns addObject:_allRankButton];
    
    _latestRankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_latestRankButton setTitle:@"最新" forState:UIControlStateNormal];
    [_latestRankButton.layer setCornerRadius:5];
    [_latestRankButton.layer setMasksToBounds:YES];
    [_latestRankButton setTitleColor:[UIColor rankButtonTextColor] forState:UIControlStateNormal];
    [_latestRankButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_latestRankButton setBackgroundColor:[UIColor clearColor]];
    [_latestRankButton addTarget:self action:@selector(reloadDataByIndex:) forControlEvents:UIControlEventTouchUpInside];
    frame = CGRectMake(CGRectGetMaxX(frame), 10, width, frame.size.height);
    [_latestRankButton setFrame:frame];
    [_rankView addSubview:_latestRankButton];
    [_rankBtns addObject:_latestRankButton];
    
    _hotRankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_hotRankButton setTitle:@"最热" forState:UIControlStateNormal];
    [_hotRankButton.layer setCornerRadius:5];
    [_hotRankButton.layer setMasksToBounds:YES];
    [_hotRankButton setTitleColor:[UIColor rankButtonTextColor] forState:UIControlStateNormal];
    [_hotRankButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_hotRankButton setBackgroundColor:[UIColor clearColor]];
    [_hotRankButton addTarget:self action:@selector(reloadDataByIndex:) forControlEvents:UIControlEventTouchUpInside];
    frame = CGRectMake(CGRectGetMaxX(frame), 10, width, frame.size.height);
    [_hotRankButton setFrame:frame];
    [_rankView addSubview:_hotRankButton];
    [_rankBtns addObject:_hotRankButton];
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
    _currentIndex = 1;
    [self displayHUD:@"加载中..."];
    [ServiceManager books:[NSString stringWithFormat:@"%@",keyword] classID:classid.integerValue ranking:rank size:size andIndex:[NSString stringWithFormat:@"%d", index] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if(success) {
            [_infoArray removeAllObjects];
            if ([resultArray count] > 0) {
                [self hideAllHotkeyBtns];
            } else if(_currentType == SEARCH && [resultArray count]==0) {
                [self showHotkeyBtns];
                [_searchArray removeAllObjects];
            }
            [self addInfoArrayObjectsWithArray:resultArray];
            if ([_infoArray count] == 6) {
                [self addFootView];
            }else {
                [_infoTableView setTableFooterView:nil];
            }
            [_infoTableView reloadData];
            [self hideHUD:YES];
        } else {
            [_infoArray removeAllObjects];
            [_infoTableView reloadData];
            if (error) {
                [self displayHUDTitle:nil message:NETWORK_ERROR];
            }
        }
    }];
    
}

- (void)changeRankButtonImage:(UIButton *)sender {
    for (int i = 0; i<3; i++) {
        UIButton *button = _rankBtns[i];
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
    if (_currentType == RANK) {
        rankId = _currentPage;
    } else {
        if (_searchBar.text) {
            keyWord = _searchBar.text;
        }
    }
    [ServiceManager books:keyWord
                  classID:0
                  ranking:rankId
                     size:@"6"
                 andIndex:[NSString stringWithFormat:@"%d", _currentIndex+1] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
                     if (success){
                         if (_infoArray.count == 0) {
                             [_infoTableView setTableFooterView:nil];
                         } else {
                             [self addInfoArrayObjectsWithArray:resultArray];
                         }
                         _currentIndex++;
                         [_infoTableView reloadData];
                         _isLoading = NO;
                     } else {
                         if (error) {
                             [self displayHUDTitle:nil message:NETWORK_ERROR];
                         }
                     }
                 }];
}

- (void)addFootView {
    UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
    [_infoTableView setTableFooterView:footview];
}

- (void)reloadDataByIndex:(id)sender {
    if (_currentPage==[_rankBtns indexOfObject:sender]+1)
        return;
    _currentPage = [_rankBtns indexOfObject:sender]+1;
    [self changeRankButtonImage:sender];
    if ([self refreshRankInfo]) {
        return;
    }
    [self loadDataWithKeyWord:@"" classId:0 ranking:_currentPage size:@"6" andIndex:1];
}

- (void)loadRecommendDataWithIndex:(NSInteger)index
{
    [_infoTableView setHidden:NO];
    [ServiceManager recommendBooksIndex:index WithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
		if (success){
			[_infoArray addObjectsFromArray:resultArray];
			[_recommandArray addObjectsFromArray:resultArray];
			[self refreshRecommendDataWithArray:_infoArray];
			if (index<5) {
				[self loadRecommendDataWithIndex:index+1];
			}
		} else {
			[_infoTableView reloadData];
			if (error) {
				[self displayHUDTitle:nil message:NETWORK_ERROR];
			}
		}
	}];
}

- (void)refreshRecommendDataWithArray:(NSArray *)array
{
    NSString *lastKey = nil;
    if ([_recommendTitlesArray count]>0) {
        [_recommendTitlesArray removeAllObjects];
        [_recommendArray removeAllObjects];
    }
    for (int i = 0; i < [array count]; i++) {
        Book *book = [array objectAtIndex:i];
        if (book.recommendTitle == nil) {
            break;
        }
        if (![_recommendTitlesArray containsObject:book.recommendTitle]) {
            [_recommendTitlesArray addObject:book.recommendTitle];
        }
        NSMutableArray *tmpArray;
        if ([lastKey isEqualToString:book.recommendTitle]) {
            tmpArray = [_recommendArray objectAtIndex:[_recommendTitlesArray indexOfObject:book.recommendTitle]];
        } else {
            tmpArray = [[NSMutableArray alloc] init];
            [_recommendArray addObject:tmpArray];
        }
        [tmpArray addObject:book];
        lastKey = book.recommendTitle;
    }
    if (_currentType == RECOMMEND) {
        [_infoTableView reloadData];
    }
    [self hideHUD:YES];
}

- (void)loadCatagoryDataWithIndex:(id)sender {
    NSInteger index = [sender tag];
    CategoryDetailsViewController *childViewController = [[CategoryDetailsViewController alloc]init];
    [childViewController.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height + 20)];
    [self.navigationController pushViewController:childViewController animated:YES];
    [childViewController displayHUD:@"加载中..."];
    [ServiceManager books:@""
                  classID:index + 1
                  ranking:0
                     size:@"7"
                 andIndex:@"1" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
                     if (success){
                         if ([_infoArray count]>0) {
                             [_infoArray removeAllObjects];
                         }
                         [_infoArray addObjectsFromArray:resultArray];
                         [childViewController reloadDataWithArray:_infoArray andCatagoryId:index+1];
                         [childViewController hideHUD:YES];
                     } else {
                         if (error) {
                             [childViewController displayHUDTitle:nil message:NETWORK_ERROR];
                         }
                     }
                 }];
}

- (void)resetBottomButtons
{
	_recommendButton.selected = NO;
	_rankButton.selected = NO;
	_cataButton.selected = NO;
	_searchButton.selected = NO;
}

- (void)buttonClick:(UIButton *)sender {
	if (sender.selected) return;
	[self resetBottomButtons];
	sender.selected = YES;
    _catagoryView.hidden = YES;
    [self hideAllHotkeyBtns];
    [_infoArray removeAllObjects];
    [_infoTableView reloadData];
    [_infoTableView setTableFooterView:nil];
	
	if (sender == _recommendButton) {
		_currentType = RECOMMEND;
		[_infoTableView setTableHeaderView:nil];
		[self.headerView.titleLabel setText:@"推荐"];
		[_rankView setHidden:YES];
		[_infoTableView setHidden:NO];
        if ([_recommandArray count] > 0) {
            [_infoArray addObjectsFromArray:_recommandArray];
            [_infoTableView reloadData];
            return;
        }
        [self displayHUD:@"加载中..."];
        [self loadRecommendDataWithIndex:1];
	} else if (sender == _rankButton) {
		_currentType = RANK;
		[_infoTableView setTableHeaderView:_rankView];
		[self.headerView.titleLabel setText:@"排行"];
        [_rankView setHidden:NO];
		[_infoTableView setHidden:NO];
        if ([self refreshRankInfo]) {
            return;
        }
        [self changeRankButtonImage:_rankBtns[_currentPage - 1]];
		[self loadDataWithKeyWord:@"" classId:0 ranking:_currentPage size:@"6" andIndex:1];
	} else if (sender == _cataButton) {
		_currentType = CATAGORY;
		_catagoryView.hidden = NO;
		[_infoTableView setTableHeaderView:nil];
		[self.headerView.titleLabel setText:@"分类"];
		[_rankView setHidden:YES];
		[_infoTableView reloadData];
	} else if (sender == _searchButton) {
		_currentType = SEARCH;
		[_infoTableView setTableHeaderView:_tableViewHeader];
		[self.headerView.titleLabel setText:@"搜索"];
		[_rankView setHidden:YES];
		[_infoTableView setHidden:NO];
        if ([_searchArray count] > 0) {
            _currentIndex = (_searchArray.count / 6) + 1;
            [_infoArray addObjectsFromArray:_searchArray];
            [self hideAllHotkeyBtns];
        } else{
            [self showHotkeyBtns];
        }
		[_infoTableView reloadData];
	}
}

#pragma mark tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_currentType == RECOMMEND) {
        if (_recommendTitlesArray.count == 0) {
            return 1;
        }
        return [_recommendTitlesArray count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_currentType != RECOMMEND) {
        return 0;
    }
    if (_recommendTitlesArray.count == 0) {
        return 0;
    }
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_currentType != RECOMMEND) {
        return nil;
    }
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [view setImage:[UIImage imageNamed:@"bookstore_recommend_title"]];
    UILabel *label = [UILabel bookStoreLabelWithFrame:CGRectMake(0, 0, view.bounds.size.width, 30)];
    [label setTextColor:[UIColor blackColor]];
    for (int i = 0; i < [_recommendTitlesArray count]; i++) {
        if (section == i) {
            [label setText:[@"  " stringByAppendingString:[_recommendTitlesArray objectAtIndex:i]]];
        }
    }
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_currentType == RECOMMEND) {
        for (int i = 0; i < [_recommendTitlesArray count]; i++) {
            if (section == i) {
                NSMutableArray *array = [_recommendArray objectAtIndex:i];
                return [array count];
            }
        }
        if ([_recommendTitlesArray count] == 0) {
            return 1;
        }
    }else if (_currentType == RANK) {
        if (_infoArray.count == 0) {
            return 1;
        }
    }
    return [_infoArray count];
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
    if (_currentType == RECOMMEND) {
        if (!cell) {
            if (_recommendTitlesArray.count == 0) {
                cell = [[BookCell alloc] initWithStyle:BookCellStyleEmpty reuseIdentifier:@"MyCell"];
                [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            } else {
                NSMutableArray *array = _recommendArray[indexPath.section];
				if (indexPath.row == 0) {
					cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
					Book *book = array[indexPath.row];
					[(BookCell *)cell setBook:book];
				} else {
					cell = [[BookCell alloc] initWithStyle:BookCellStyleSmall reuseIdentifier:@"MyCell"];
					Book *book = array[indexPath.row];
					[(BookCell *)cell setBook:book];
                }
            }
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        }
    }
    else if (_currentType == RANK){
        if (!cell) {
            if ([_infoArray count] > 0) {
                cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
                [cell.contentView setBackgroundColor:[UIColor whiteColor]];
                Book *book = _infoArray[indexPath.row];
                [(BookCell *)cell setBook:book];
            } else {
                cell = [[BookCell alloc] initWithStyle:BookCellStyleEmpty reuseIdentifier:@"MyCell"];
                [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            }
        }
    } else if (_currentType == SEARCH) {
        cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        if ([_infoArray count] >0) {
            Book *book = _infoArray[indexPath.row];
            [(BookCell *)cell setBook:book];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_currentType != CATAGORY) {
        if (_currentType == RANK) {
            if (_infoArray.count == 0) {
				[self loadDataWithKeyWord:@"" classId:0 ranking:_currentPage size:@"6" andIndex:1];
				NSLog(@"重新刷新排行");
				return;
            }
        }
        Book *book;
        if (_currentType == RECOMMEND) {
            if (_recommendTitlesArray.count == 0) {
                [self loadRecommendDataWithIndex:1];
                NSLog(@"重新刷新推荐");
                return;
            }
            NSMutableArray *array = [_recommendArray objectAtIndex:[indexPath section]];
            book = array[indexPath.row];
        } else {
            book = _infoArray[indexPath.row];
        }
        [_searchBar resignFirstResponder];
        BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
        [self.navigationController pushViewController:childViewController animated:YES];
    }
}

//显示热词
- (void)showHotkeyBtns {
    [self hideAllHotkeyBtns];
    if (_currentType!=SEARCH)
        return;
    NSMutableArray *hotNamesIndex = [NSMutableArray array];
    [ServiceManager hotKeyWithBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (success) {
            if (_currentType!=SEARCH)
                return;
            while (hotNamesIndex.count < resultArray.count) {
                int randomNum = arc4random() % resultArray.count;
                if (![hotNamesIndex containsObject:@(randomNum)]) {
                    [hotNamesIndex addObject:@(randomNum)];
                }
            }
            NSArray *cgrectArr = [self randomRect:resultArray.count];
            for (int i = 0; i < [cgrectArr count]; i++) {
                NSString *cgrectstring = [cgrectArr objectAtIndex:i];
                UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [tmpButton setFrame:CGRectFromString(cgrectstring)];
                NSNumber *indexNum = [hotNamesIndex objectAtIndex:i];
                [tmpButton setTitle:resultArray[indexNum.integerValue] forState:UIControlStateNormal];
                NSInteger colorIndex = arc4random() % _hotwordsColors.count;
                [tmpButton setTitleColor:_hotwordsColors[colorIndex] forState:UIControlStateNormal];
                [tmpButton.titleLabel setFont:[UIFont boldSystemFontOfSize:arc4random() % 10 + 15]];
                [tmpButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
                [tmpButton addTarget:self action:@selector(hotkeybuttonClick:) forControlEvents:UIControlEventTouchUpInside];
                [_infoTableView addSubview:tmpButton];
                [_hotkeyBtns addObject:tmpButton];
            }
        } else {
            if (error) {
                [self displayHUDTitle:nil message:NETWORK_ERROR];
            }
        }
    }];
}

- (void)hideAllHotkeyBtns
{
    for (UIButton *button in _hotkeyBtns) {
        [button removeFromSuperview];
    }
}

- (void)hotkeybuttonClick:(id)sender
{
    [_searchArray removeAllObjects];
    UIButton *button = (UIButton *)sender;
    _searchBar.text = button.titleLabel.text;
    [self searchBarSearchButtonClicked:_searchBar];
}

- (NSArray *)randomRect:(int)rectCount {
    NSMutableArray *rectArray = [NSMutableArray array];
    while([rectArray count] < rectCount) {
        int x =arc4random()%160 + 15;    //随机坐标x
        int y = arc4random()%200 + 100;//随机坐标y
        CGRect rect = CGRectMake(x, y, 120, 30);
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
    if ([_infoArray count] == 0) {
        return;
    }
    if (_currentType == RANK || _currentType == SEARCH) {
        if(scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height - 100) {
            if (!_isLoading) {
                _isLoading = YES;
                NSLog(@"可刷新");
                [self getMore];
            }
        }
    }
}

- (BOOL)refreshRankInfo
{
    if (_currentPage == 1) {
        if (_allArray.count) {
            [_infoArray removeAllObjects];
            [_infoArray addObjectsFromArray:_allArray];
            _currentIndex = _allArray.count / 6 + 1;
            [_infoTableView reloadData];
            return YES;
        }
    } else if (_currentPage == 2) {
        if (_latestArray.count) {
            [_infoArray removeAllObjects];
            [_infoArray addObjectsFromArray:_latestArray];
            _currentIndex = _latestArray.count / 6 + 1;
            [_infoTableView reloadData];
            return YES;
        }
    } else if (_currentPage == 3) {
        if (_hotArray.count) {
            [_infoArray removeAllObjects];
            [_infoArray addObjectsFromArray:_hotArray];
            _currentIndex = _hotArray.count / 6 + 1;
            [_infoTableView reloadData];
            return YES;
        }
    }
    return NO;
}

- (void)addInfoArrayObjectsWithArray:(NSArray *)resultArray
{
    [_infoArray addObjectsFromArray:resultArray];
    if (_currentType == SEARCH) {
        [_searchArray addObjectsFromArray:resultArray];
    } else if (_currentType == RANK) {
        if (_currentPage == 1) {
            [_allArray addObjectsFromArray:resultArray];
        } else if (_currentPage == 2) {
            [_latestArray addObjectsFromArray:resultArray];
        } else {
            [_hotArray addObjectsFromArray:resultArray];
        }
    }
}

@end
