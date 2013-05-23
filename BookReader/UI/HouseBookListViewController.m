//
//  HouseBookListViewController.m
//  BookReader
//
//  Created by 颜超 on 12-11-26.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import "HouseBookListViewController.h"
#import "AppDelegate.h"
#import "BookManager.h"
#import <QuartzCore/QuartzCore.h>
#import "BookReader.h"
#import "UMTableViewCell.h"
#import "UILabel+BookReader.h"

#define headerImageViewFrame    CGRectMake(0, 0, self.view.bounds.size.width, 44)
#define titleLabelFrame         CGRectMake(0, 0, self.view.bounds.size.width, 44)
#define downloadButtonFrame     CGRectMake(self.view.bounds.size.width-60, 5, 50, 25)
#define infoTableViewFrame          CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-85+6)

@implementation HouseBookListViewController
{
    UITableView     *infoTableView;
    BOOL isloading;
    NSArray *houseBooks;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headerImageViewFrame];
    [headerImageView setImage:[UIImage imageNamed:@"main_headerbackground"]];
    [self.view addSubview:headerImageView];
    
    UILabel *titleLabel = [UILabel titleLableWithFrame:titleLabelFrame];
    [titleLabel setText:NSLocalizedString(@"BookStore", nil)];
    [titleLabel setTextColor:txtColor];
    [self.view addSubview:titleLabel];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_background.png"]];
    infoTableView = [[UITableView alloc] initWithFrame:infoTableViewFrame style:UITableViewStylePlain];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setBackgroundView:backgroundView];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [self.view addSubview:infoTableView];
    
    isloading = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self loadData];
    [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
}

- (void)checkShouldLoadAgain {
    if ([houseBooks count] == 0 && isloading == NO) {
        [NSThread detachNewThreadSelector:@selector(loadData) toTarget:self withObject:nil];
    }
}

- (void)loadData {
    isloading = YES;
    houseBooks = [[NSArray alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOUSE_URL, HOUSE_BOOKLIST_PATH]]];
    [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
}

- (void)stopLoading {
    [infoTableView reloadData];
    isloading = NO;
}

#pragma mark -
#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [houseBooks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if(cell == nil) {
        UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            UIImageView *cellBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_cellbackground.png"]];
            [cell setBackgroundView:cellBackground];
            
            UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [downloadButton setFrame:downloadButtonFrame];
            [downloadButton.layer setCornerRadius:4];
            [downloadButton.layer setMasksToBounds:YES];
            [downloadButton setUserInteractionEnabled:NO];
            [downloadButton setBackgroundImage:[UIImage imageNamed:@"downloadbutton"] forState:UIControlStateNormal];
            [cell.contentView addSubview:downloadButton];
        }
        
        NSDictionary *promoter = [houseBooks objectAtIndex:[indexPath row]];
        cell.textLabel.text = [promoter valueForKey:@"appname"];
        cell.detailTextLabel.text = [promoter valueForKey:@"description"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        return cell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *itunesUrl = [[houseBooks objectAtIndex:[indexPath row] ] objectForKey:@"downloadurl"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesUrl]];
}


@end
