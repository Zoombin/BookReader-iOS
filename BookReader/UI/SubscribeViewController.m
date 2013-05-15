//
//  SubscribeViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SubscribeViewController.h"
#import "BookReader.h"
#import "ServiceManager.h"
#import "Chapter.h"
#import "Book.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"
#import "CoreTextViewController.h"
#import "UIColor+BookReader.h"

@implementation SubscribeViewController
{
    Book *bookobj;
    UITableView *infoTableView;
    NSMutableArray *infoArray;
    BOOL bOnline;
}
@synthesize delegate;

- (id)initWithBookId:(Book *)book
           andOnline:(BOOL)online;
{
    self = [super init];
    if (self) {
        bookobj = book;
        infoArray = [[NSMutableArray alloc] init];
        bOnline = online;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
	// Do any additional setup after loading the view.
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
    [self.view addSubview:backgroundImage];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame: CGRectMake(10, 4, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setText:@"目录"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44-20) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setDataSource:self];
    [self.view addSubview:infoTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([infoArray count]==0) {
        [self loadChapterData];
    }
}

- (void)loadChapterData
{
    if (bOnline) {
        [self chapterDataFromService];
    } else {
        NSArray *array = [Chapter chaptersWithBookID:bookobj.uid];
        if ([array count]>0)
        {
            [infoArray addObjectsFromArray:array];
            [infoTableView reloadData];
        }
        else
        {
            [self chapterDataFromService];
        }
    }
}

- (void)chapterDataFromService
{
    [self displayHUD:@"获取书籍目录中..."];
    [ServiceManager bookCatalogueList:bookobj.uid andNewestCataId:@"0" withBlock:^(NSArray *result, NSError *error) {
        if (error)
        {
            [self hideHUD:YES];
        }
        else
        {
            [self hideHUD:YES];
            if ([infoArray count]>0) {
                [infoArray removeAllObjects];
            }
            [infoArray addObjectsFromArray:result];
            [infoTableView reloadData];
        }
    }];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
        Chapter *obj = [infoArray objectAtIndex:[indexPath row]];
        cell.textLabel.text = obj.name;
        if (obj.content!=nil) {
            cell.textLabel.textColor = [UIColor blueColor];
        }
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        NSString *vipString = @"";
        vipString = [obj.bVip boolValue] ? @"v" : @"";
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.text = vipString;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(chapterDidSelectAtIndex:)]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate chapterDidSelectAtIndex:indexPath.row];
    }
}


@end
