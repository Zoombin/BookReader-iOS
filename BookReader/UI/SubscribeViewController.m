//
//  SubscribeViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SubscribeViewController.h"
#import "ServiceManager.h"
#import "Chapter.h"
#import "Book.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"
#import "CoreTextViewController.h"
#import "UIColor+BookReader.h"
#import "UILabel+BookReader.h"
#import "Chapter+Setup.h"
#import "UIButton+BookReader.h"

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
    [self setTitle:@"目录"];
    [self removeGestureRecognizer];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain];
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
        NSArray *array = [Chapter chaptersRelatedToBook:bookobj.uid];
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
    [ServiceManager bookCatalogueList:bookobj.uid withBlock:^(NSArray *resultArray, NSError *error) {
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
            [infoArray addObjectsFromArray:resultArray];
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
