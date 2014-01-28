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

@interface CategoryDetailsViewController ()

@property (readwrite) UITableView *infoTableView;
@property (readwrite) NSMutableArray *infoArray;
@property (readwrite) int catagoryId;
@property (readwrite) int currentIndex;
@property (readwrite) BOOL isLoading;

@end

@implementation CategoryDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isLoading = NO;
        _currentIndex = 1;
        _catagoryId = 0;
        _infoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 50, self.view.bounds.size.width - 10, self.view.bounds.size.height - 54) style:UITableViewStylePlain];
    [_infoTableView setBackgroundColor:[UIColor clearColor]];
    [_infoTableView.layer setCornerRadius:5];
    [_infoTableView.layer setMasksToBounds:YES];
    [_infoTableView setDataSource:self];
    [_infoTableView setDelegate:self];
    [_infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_infoTableView];
    [_infoTableView reloadData];
	self.hideKeyboardRecognzier.enabled = NO;
}

- (void)reloadDataWithArray:(NSArray *)array andCatagoryId:(int)cataId
{
    _catagoryId = cataId;
    NSArray *buttonNames = [ServiceManager bookCategories];
    [self setTitle:buttonNames[_catagoryId - 1]];
	[_infoArray removeAllObjects];
    [_infoArray addObjectsFromArray:array];
    if ([_infoArray count] == 7) {
        UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
        [_infoTableView setTableFooterView:footview];
    }
    [_infoTableView reloadData];
}

- (void)getMore
{
    [ServiceManager books:@""
                    classID:_catagoryId
                  ranking:0
                     size:@"7"
                 andIndex:[NSString stringWithFormat:@"%d", _currentIndex + 1] withBlock:^(BOOL success, NSError *error, NSArray *result) {
                     if (success) {
                         if ([_infoArray count] > 0) {
                             [_infoArray addObjectsFromArray:result];
                             [_infoTableView reloadData];
                         }else {
                             [_infoTableView setTableFooterView:nil];
                         }
                         _currentIndex++;
                         _isLoading = NO;
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
        if (!_isLoading) {
            _isLoading = YES;
            NSLog(@"可刷新");
            [self getMore];
        }
    }
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_infoArray.count == 0) {
        return 1;
    }
    return _infoArray.count;
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
	if (!cell) {
        if (_infoArray.count == 0) {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleEmpty reuseIdentifier:@"MyCell"];
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        } else {
            cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
            Book *book = [_infoArray objectAtIndex:[indexPath row]];
            [cell setBook:book];
        }
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_infoArray.count  == 0) {
        [self loadCatagoryData];
        return;
    }
    Book *book = [_infoArray objectAtIndex:[indexPath row]];
    BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:book.uid];
    [self.navigationController pushViewController:childViewController animated:YES];
}

- (void)loadCatagoryData
{
    [ServiceManager books:@""
                  classID:_catagoryId
                  ranking:0
                     size:@"7"
                 andIndex:@"1" withBlock:^(BOOL success, NSError *error, NSArray *result) {
                     if (success) {
                         if (_infoArray.count) {
                             [_infoArray addObjectsFromArray:result];
                             [_infoTableView reloadData];
                         }else {
                             [_infoTableView setTableFooterView:nil];
                         }
                         _currentIndex++;
                         _isLoading = NO;
                     } else {
                         if (error) {
                             [self displayHUDTitle:nil message:NETWORK_ERROR];
                         }
                     }
                 }];
}

@end
