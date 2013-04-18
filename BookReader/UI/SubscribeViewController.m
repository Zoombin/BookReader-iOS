//
//  SubscribeViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SubscribeViewController.h"
#import "UIDefines.h"
#import "ServiceManager.h"
#import "Chapter.h"
#import "UIViewController+HUD.h"

@implementation SubscribeViewController
{
    Book *bookobj;
    NSString *userid;
    UITableView *infoTableView;
    NSMutableArray *infoArray;
}

- (id)initWithBookId:(Book *)book;
{
    self = [super init];
    if (self) {
        bookobj = book;
        userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userid"];
        infoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage*img =[UIImage imageNamed:@"main_view_bkg"];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:img]];
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
    [self loadChapterData];
}

- (void)loadChapterData
{
    [self displayHUD:@"获取章节列表..."];
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
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        NSString *vipString = @"";
        vipString = obj.bVip==YES?@"VIP":@"免费";
        cell.detailTextLabel.text = vipString;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Chapter *obj = [infoArray objectAtIndex:[indexPath row]];
    [ServiceManager bookCatalogue:obj.uid andUserid:userid withBlock:^(NSString *result,NSString *code, NSError *error) {
        if (error)
        {
            
        }
        else
        {
            if (![code isEqualToString:@"0000"])
            {
                [self chapterSubscribeWithObj:obj];
            }
            else
            {
                [self showAlertWithMessage:result];
            }
        }
    }];
}

- (void)chapterSubscribeWithObj:(Chapter *)obj
{
    if (userid!=nil)
    {
        [ServiceManager chapterSubscribe:userid chapter:obj.uid book:bookobj.uid author:bookobj.authorID andPrice:@"0" withBlock:^(NSString *result,NSString *code,NSError *error) {
            if (error)
            {
                
            }
            else
            {
                if ([code isEqualToString:@"0000"]) {
                   obj.bBuy = YES; 
                }
                [self showAlertWithMessage:result];
            }
        }];
    }
    else
    {
        [self showAlertWithMessage:@"您尚未登录"];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    
}

@end
