//
//  GiftViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "GiftViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GiftCell.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "UIColor+BookReader.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"



@implementation GiftViewController {
    NSString *currentIndex;
    Book *bookObj;
    UITableView *infoTableView;
}

- (id)initWithIndex:(NSString *)index andBook:(Book *)book {
    self = [super init];
    if (self) {
        currentIndex = index;
        bookObj = book;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.hideKeyboardRecognzier.enabled = NO;
	self.headerView.titleLabel.text = @"赠送";
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, BRHeaderView.height, self.view.bounds.size.width-5*2, self.view.bounds.size.height - BRHeaderView.height - 10) style:UITableViewStylePlain];
    [infoTableView.layer setCornerRadius:4];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [self.view addSubview:infoTableView];
}

- (void)sendButtonClick:(NSDictionary *)value
{
    NSLog(@"%@",value);
    NSString *integral = @"";
    NSString *count = [value objectForKey:@"count"];
    NSString *index = [value objectForKey:@"index"];
    if ([value objectForKey:@"integral"]) {
        integral = [value objectForKey:@"integral"];
    }
    [self displayHUD:@"处理中..."];
    [ServiceManager giveGiftWithType:index.integerValue
                      author:bookObj.authorID
                       count:count
                    integral:integral.integerValue
                     andBook:bookObj.uid
                   withBlock:^(BOOL success, NSError *error, NSString *message) {
                       if (error) {
                           [self displayHUDError:nil message:NETWORK_ERROR];
                       }else {
                           [self displayHUDError:nil message:message];
                       }
                   }];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GiftCell *cell = (GiftCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    GiftCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[GiftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier andIndexPath:indexPath andStyle:indexPath.row];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];
    }
    return cell;
}


@end
