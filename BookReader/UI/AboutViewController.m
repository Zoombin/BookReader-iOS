//
//  SettingViewcontroller.m
//  iReader
//
//  Created by Sha XiaoQuan on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "AboutViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "BookReader.h"

//---infoTableView---
#define textViewFrame               CGRectMake(20, 2, self.view.bounds.size.width-40, 78)
#define backgroundImageViewFrame    CGRectMake(15, 0, textView.frame.size.width+10, textView.frame.size.height+10)
#define headerImageViewFrame    CGRectMake(0, 0, self.view.bounds.size.width, 44)
#define titleLabelFrame         CGRectMake(0, 0, self.view.bounds.size.width, 44)
#define infoTableViewFrame          CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-85+6)

@implementation AboutViewController {
    UITableView     *infoTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"local_background.png"]];
    [self.view addSubview:backgroundView];
    
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:headerImageViewFrame];
    [headerImageView setImage:[UIImage imageNamed:@"main_headerbackground"]];
    [self.view addSubview:headerImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    [titleLabel setText:NSLocalizedString(@"AboutUs", nil)];
    [titleLabel setTextColor:txtColor];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.view addSubview:titleLabel];
    
    infoTableView = [[UITableView alloc] initWithFrame:infoTableViewFrame style:UITableViewStylePlain];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [infoTableView setScrollEnabled:NO];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:infoTableView];
}

#pragma mark -
#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-6, -0, 320, 32)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, -0, 100, 32)];
    if (section==0) {
      [label setText:NSLocalizedString(@"CopyRight", nil)];
    }else {
      [label setText:NSLocalizedString(@"Contaceus", nil)];
    }
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setTextColor:txtColor];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    [label setBackgroundColor:[UIColor clearColor]];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
        
        UILabel *textView = [[UILabel alloc] initWithFrame:textViewFrame];
        [textView setTextColor:txtColor];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setUserInteractionEnabled:NO];
        [textView setFont:[UIFont systemFontOfSize:16]];
        [textView setLineBreakMode:NSLineBreakByCharWrapping];
        [textView setNumberOfLines:0];
        [cell.contentView addSubview:textView];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundImageViewFrame];
        [backgroundImageView setImage:[UIImage imageNamed:@"setting_cellbackground.png"]];
        [backgroundImageView setAlpha:0.7];
        [backgroundImageView.layer setCornerRadius:6];
        [cell.contentView addSubview:backgroundImageView];
        if ([indexPath section]==0) {
            [textView setText:textCopyRight];
            [textView sizeToFit];
        } else {
            [textView setText:textEmail];
            [textView sizeToFit];
            [backgroundImageView setFrame:CGRectMake(15, 0, self.view.bounds.size.width-30, textView.frame.size.height+10)];
        }
    }
	return cell;
}




@end
