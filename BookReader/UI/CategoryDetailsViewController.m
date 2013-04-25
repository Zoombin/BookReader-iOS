//
//  CategoryDetailView.m
//  BookReader
//
//  Created by 颜超 on 13-3-26.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "CategoryDetailsViewController.h"
#import "UIDefines.h"
#import "AppDelegate.h"
#import "BookDetailsViewController.h"
#import "ServiceManager.h"
#import "BookCell.h"
#import "NonManagedBook.h"
#import "UIViewController+HUD.h"

@implementation CategoryDetailsViewController
{
    UITableView *infoTableView;
    NSMutableArray *infoArray;
    int catagoryId;
    int currentIndex;
    UILabel *titleLabel;
}

- (id)init
{
    self = [super init];
    if (self) {
        currentIndex = 1;
        catagoryId = 0;
        infoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage*img =[UIImage imageNamed:@"main_view_bkg"];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:img]];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
    [self.view addSubview:backgroundImage];
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:titleLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame: CGRectMake(10, 4, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-40-20) style:UITableViewStylePlain];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];
    [infoTableView reloadData];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadDataWithArray:(NSArray *)array andCatagoryId:(int)cataId
{
    catagoryId = cataId;
    NSArray *buttonNames = @[@"穿越",@"架空",@"都市",@"青春",@"魔幻",@"玄幻",@"豪门",@"历史",@"异能",@"短篇",@"耽美"];
    [titleLabel setText:buttonNames[catagoryId-1]];
    if ([infoArray count]>0) {
        [infoArray removeAllObjects];
    }
    [infoArray addObjectsFromArray:array];
    if ([infoArray count]==5) {
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
    [infoTableView reloadData];
}

- (void)getMore
{
    [self displayHUD:@"加载中..."];
    [ServiceManager books:@""
                    classID:[NSString stringWithFormat:@"%d",catagoryId]
                  ranking:@"0"
                     size:@"5"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex+1] withBlock:^(NSArray *result, NSError *error) {
                     if (error) {
                         [self hideHUD:YES];
                     }else {
                         if ([infoArray count]>0) {
                             [infoArray addObjectsFromArray:result];
                             [infoTableView reloadData];
                             currentIndex++;
                         }else {
                             [infoTableView setTableFooterView:nil];
                         }
                         [self hideHUD:YES];
                     }
                 }];
    
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BookCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
        cell = [[BookCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
        id<BookInterface> book = [infoArray objectAtIndex:[indexPath row]];
        [cell setBook:book];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id< BookInterface> book = [infoArray objectAtIndex:[indexPath row]];
    BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
    [self.navigationController pushViewController:childViewController animated:YES];
}



@end
