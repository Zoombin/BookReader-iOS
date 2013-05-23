//
//  CategoryDetailView.m
//  BookReader
//
//  Created by 颜超 on 13-3-26.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "CategoryDetailsViewController.h"
#import "AppDelegate.h"
#import "BookDetailsViewController.h"
#import "ServiceManager.h"
#import "BookCell.h"
#import "Book.h"
#import "UIViewController+HUD.h"
#import "UIColor+BookReader.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"

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
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
    
    titleLabel = [UILabel titleLableWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [self.view addSubview:titleLabel];
    
	UIButton *backButton = [UIButton navigationBackButton];
    [backButton setFrame: CGRectMake(10, 4, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 40, self.view.bounds.size.width-10, self.view.bounds.size.height-40) style:UITableViewStylePlain];
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
                    classID:catagoryId
                  ranking:0
                     size:@"5"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex+1] withBlock:^(NSArray *result, NSError *error) {
                     if (error) {
                         [self displayHUDError:nil message:NETWORK_ERROR];
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
        cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
        Book *book = [infoArray objectAtIndex:[indexPath row]];
        [cell setBook:book];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Book *book = [infoArray objectAtIndex:[indexPath row]];
    BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
    [self.navigationController pushViewController:childViewController animated:YES];
}



@end
