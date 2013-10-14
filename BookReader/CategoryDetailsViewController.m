//
//  CategoryDetailView.m
//  BookReader
//
//  Created by ZoomBin on 13-3-26.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "CategoryDetailsViewController.h"
#import "AppDelegate.h"
#import "BookDetailsViewController.h"
#import "ServiceManager.h"
#import "BookCell.h"
#import "UIViewController+HUD.h"
#import "UIButton+BookReader.h"
#import "UIView+BookReader.h"
#import <QuartzCore/QuartzCore.h>

@implementation CategoryDetailsViewController
{
    UITableView *infoTableView;
    NSMutableArray *infoArray;
    int catagoryId;
    int currentIndex;
    BOOL isLoading;
}

- (id)init
{
    self = [super init];
    if (self) {
        isLoading = NO;
        currentIndex = 1;
        catagoryId = 0;
        infoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 50, self.view.bounds.size.width-10, self.view.bounds.size.height-54) style:UITableViewStylePlain];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView.layer setCornerRadius:5];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];
    [infoTableView reloadData];
	self.hideKeyboardRecognzier.enabled = NO;
}

- (void)reloadDataWithArray:(NSArray *)array andCatagoryId:(int)cataId
{
    catagoryId = cataId;
    NSArray *buttonNames = [ServiceManager bookCategories];
    [self setTitle:buttonNames[catagoryId-1]];
	[infoArray removeAllObjects];
    [infoArray addObjectsFromArray:array];
    if ([infoArray count] == 7) {
        UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
        [infoTableView setTableFooterView:footview];
    }
    [infoTableView reloadData];
}

- (void)getMore
{
    [ServiceManager books:@""
                    classID:catagoryId
                  ranking:0
                     size:@"7"
                 andIndex:[NSString stringWithFormat:@"%d",currentIndex+1] withBlock:^(BOOL success, NSError *error, NSArray *result) {
                     if (success) {
                         if ([infoArray count]>0) {
                             [infoArray addObjectsFromArray:result];
                             [infoTableView reloadData];
                         }else {
                             [infoTableView setTableFooterView:nil];
                         }
                         isLoading = NO;
                     } else {
                         if (error) {
                         [self displayHUDTitle:nil message:NETWORK_ERROR];
                         }
                     }
                 }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height - 100) {
        if (!isLoading) {
            isLoading = YES;
            NSLog(@"可刷新");
            [self getMore];
        }
    }
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (infoArray.count == 0) {
        return 1;
    }
    return infoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return [cell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    BookCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
        if (infoArray.count == 0) {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleEmpty reuseIdentifier:@"MyCell"];
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        } else {
        cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
        Book *book = [infoArray objectAtIndex:[indexPath row]];
        [cell setBook:book];
        }
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (infoArray.count  == 0) {
        [self loadCatagoryData];
        return;
    }
    Book *book = [infoArray objectAtIndex:[indexPath row]];
    BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
    [self.navigationController pushViewController:childViewController animated:YES];
}

- (void)loadCatagoryData
{
    [ServiceManager books:@""
                  classID:catagoryId
                  ranking:0
                     size:@"7"
                 andIndex:@"1" withBlock:^(BOOL success, NSError *error, NSArray *result) {
                     if (success) {
                         if ([infoArray count]>0) {
                             [infoArray addObjectsFromArray:result];
                             [infoTableView reloadData];
                             currentIndex++;
                         }else {
                             [infoTableView setTableFooterView:nil];
                         }
                         isLoading = NO;
                     } else {
                         if (error) {
                             [self displayHUDTitle:nil message:NETWORK_ERROR];
                         }
                     }
                 }];
}

@end
