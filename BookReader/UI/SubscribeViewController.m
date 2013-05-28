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
#import "Mark.h"
#import "Book.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"
#import "CoreTextViewController.h"
#import "UIColor+BookReader.h"
#import "UILabel+BookReader.h"
#import "Chapter+Setup.h"
#import "UIButton+BookReader.h"

#define BOOKMARK  0
#define CHAPTER 1

@implementation SubscribeViewController
{
    Book *bookobj;
    UITableView *infoTableView;
    NSMutableArray *infoArray;
    NSMutableArray *chapterArray;
    NSMutableArray *bookmarkArray;
    NSInteger currentMode;
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
        chapterArray = [[NSMutableArray alloc] init];
        bookmarkArray = [[NSMutableArray alloc] init];
        bOnline = online;
        currentMode = CHAPTER;
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
    
    CGRect CHAPTERS_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width-110,4,48,32);
    CGRect BOOKMARK_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width-60,4,48,32);
    NSArray *titles = @[@"目录", @"书签"];
    NSArray *rectStrings = @[NSStringFromCGRect(CHAPTERS_BUTTON_FRAME), NSStringFromCGRect(BOOKMARK_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"chapterButtonClick", @"bookmarkButtonClick"];
    
#define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"universal_btn"), UIIMAGE(@"universal_btn"), ];
    NSArray *highlightedImages = @[UIIMAGE(@"universal_btn_hl"), UIIMAGE(@"universal_btn_hl")];
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImages[i] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)chapterButtonClick
{
    self.title = @"目录";
    currentMode = CHAPTER;
    infoArray = chapterArray;
    [infoTableView reloadData];
}

- (void)bookmarkButtonClick
{
    self.title = @"书签";
    currentMode = BOOKMARK;
    infoArray = bookmarkArray;
    [infoTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([chapterArray count]==0) {
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
            [chapterArray addObjectsFromArray:array];
            infoArray = chapterArray;
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
            if ([chapterArray count]>0) {
                [chapterArray removeAllObjects];
            }
            [chapterArray addObjectsFromArray:resultArray];
            infoArray = chapterArray;
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
        if (currentMode == CHAPTER) {
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
        } else {
            Mark *obj = [infoArray objectAtIndex:[indexPath row]];
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            cell.textLabel.text = obj.reference;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentMode == CHAPTER) {
        if ([self.delegate respondsToSelector:@selector(chapterDidSelectAtIndex:)]) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate chapterDidSelectAtIndex:indexPath.row];
        }
    } else {
        
    }
}


@end
