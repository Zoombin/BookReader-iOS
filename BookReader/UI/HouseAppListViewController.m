//
//  ScoreWallViewController.m
//  Reader
//
//  Created by 颜超 on 12-11-16.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import "HouseAppListViewController.h"
#import "UMTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation HouseAppListViewController
{
    UMUFPTableView *_mTableView;
    NSMutableArray  *infoArray;
}

- (id)init
{
    self = [super init];
    if (self) {
        infoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    _mTableView.dataLoadDelegate = nil;
    [_mTableView removeFromSuperview];
    _mTableView = nil;
}

- (void)loadHouseAppdata {
    [infoArray addObjectsFromArray:[NSArray arrayWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOUSE_URL, HOUSE_APPLIST_PATH]]]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headerImageViewFrame];
    [headerImageView setImage:[UIImage imageNamed:@"main_headerbackground"]];
    [self.view addSubview:headerImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    [titleLabel setText:NSLocalizedString(@"AppRecommand", nil)];
    [titleLabel setTextColor:txtColor];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.view addSubview:titleLabel];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_background.png"]];
    _mTableView = [[UMUFPTableView alloc] initWithFrame:_mTableViewFrame style:UITableViewStylePlain appkey:UMengAppKey slotId:nil currentViewController:self];
    _mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.backgroundColor = [UIColor clearColor];
    [_mTableView setBackgroundView:backgroundView];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mTableView.dataLoadDelegate = (id<UMUFPTableViewDataLoadDelegate>)self;
    [self.view addSubview:_mTableView];
    
    [NSThread detachNewThreadSelector:@selector(loadHouseAppdata) toTarget:self withObject:nil];
    
    //一次性全部把APP抓取完毕
    [_mTableView requestPromoterDataInBackground];
    [_mTableView requestMorePromoterInBackground];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    CGSize size = MAIN_SCREEN.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    _mTableView.frame = CGRectMake(0, frame.size.height, size.width, size.height - frame.size.height);
}

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0) {
        return [infoArray count] + [_mTableView.mPromoterDatas count] + 1;
    }
    else if (_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0) {
        return [infoArray count] + [_mTableView.mPromoterDatas count];
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"UMUFPTableViewCell%d", [indexPath row]];
    
    if (indexPath.section < [infoArray count])
    {
        UMTableViewCell *cell = (UMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            UIImageView *cellBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_cellbackground.png"]];
            [cellBackground setImage:[UIImage imageNamed:@"local_cellbackground"]];
            [cell setBackgroundView:cellBackground];
            
            UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [downloadButton setFrame:downloadButtonFrame];
            [downloadButton setTag:[indexPath section]];
            [downloadButton.layer setCornerRadius:4];
            [downloadButton.layer setMasksToBounds:YES];
            [downloadButton setUserInteractionEnabled:NO];
            [downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadbutton"] forState:UIControlStateNormal];
            [cell.contentView addSubview:downloadButton];
        }
        NSDictionary *promoter = [infoArray objectAtIndex:indexPath.section];
        cell.textLabel.text = [promoter valueForKey:@"appname"];
        cell.detailTextLabel.text = [promoter valueForKey:@"description"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        return cell;
    }
    else
    {
        UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            UIImageView *cellBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_cellbackground.png"]];
            [cell setBackgroundView:cellBackground];
            
            UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [downloadButton setFrame:downloadButtonFrame];
            [downloadButton setTag:[indexPath section]];
            [downloadButton.layer setCornerRadius:4];
            [downloadButton.layer setMasksToBounds:YES];
            [downloadButton setUserInteractionEnabled:NO];
            [downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadbutton"] forState:UIControlStateNormal];
            [cell.contentView addSubview:downloadButton];
        }
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.section-[infoArray count]];
        cell.textLabel.text = [promoter valueForKey:@"title"];
        cell.detailTextLabel.text = [promoter valueForKey:@"ad_words"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.0;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section < [infoArray count]) {
        NSDictionary *infoDict = [infoArray objectAtIndex:indexPath.section];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[infoDict objectForKey:@"downloadurl"]]];
    } else {
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.section-[infoArray count]];
        [_mTableView didClickPromoterAtIndex:promoter index:indexPath.section];
    }
}

#pragma mark - UMTableViewDataLoadDelegate methods
- (void)loadDataFailed{}

- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters {
    if ([promoters count] > 0) {
        [_mTableView reloadData];
    }
    else if ([_mTableView.mPromoterDatas count]) {
        [_mTableView reloadData];
    }
    else {
        [self loadDataFailed];
    }
}

- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error {
    if ([_mTableView.mPromoterDatas count]) {
        [_mTableView reloadData];
    }
    else {
        [self loadDataFailed];
    }
}


@end
