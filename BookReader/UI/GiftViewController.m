//
//  GiftViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "GiftViewController.h"
#import "BookReader.h"
#import "GiftCell.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"

@implementation GiftViewController {
    NSString *title;
    NSString *currentIndex;
    Book *bookObj;
    NSArray *integralArrays;
    
    NSMutableArray *oldKeyWordsArray;
    NSMutableArray *newKeyWordsArray;
    UITableView *infoTableView;
}

- (id)initWithIndex:(NSString *)index
         andBookObj:(Book *)bookObject
{
    self = [super init];
    if (self) {
        // Custom initialization
        currentIndex = index;
        bookObj = bookObject;
        NSLog(@"==>%@",currentIndex);
        oldKeyWordsArray = [NSMutableArray arrayWithObjects:@"钻石",@"鲜花",@"打赏",@"月票",@"评价票", nil];
        newKeyWordsArray = [NSMutableArray arrayWithObjects:@"钻石",@"鲜花",@"打赏",@"月票",@"评价票", nil];
    
        NSString *key = [oldKeyWordsArray objectAtIndex:[index intValue]];
        [newKeyWordsArray removeObjectAtIndex:[index intValue]];
        [newKeyWordsArray insertObject:key atIndex:0];
    
        integralArrays = @[@"不知所云",@"随便看看",@"值得一看",@"不容错过",@"经典必看"];
        title = oldKeyWordsArray[[index integerValue]];
        //  1:送钻石 2:送鲜花 3:打赏 4:月票 5:投评价
        // 1:不知所云 2:随便看看 3:值得一看 4:不容错过 5:经典必看
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
    [titleLabel setText:title];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44-20) style:UITableViewStyleGrouped];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [self.view addSubview:infoTableView];
}

- (void)sendButtonClick:(NSDictionary *)value
{
    NSString *integral = @"";
    NSString *count = [value objectForKey:@"count"];
    NSString *index = [value objectForKey:@"index"];
    if ([value objectForKey:@"integral"]) {
        integral = [value objectForKey:@"integral"];
    }
    [self displayHUD:@"处理中..."];
    [ServiceManager giveGiftWithType:index
                      author:bookObj.authorID
                       count:count
                    integral:integral
                     andBook:bookObj.uid
                   withBlock:^(NSString *result, NSError *error) {
                       if (error) {
                           [self displayHUDError:nil message:NETWORK_ERROR];
                       }else {
                           [self displayHUDError:nil message:result];
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[newKeyWordsArray objectAtIndex:[indexPath section]] isEqualToString:@"评价票"]) {
        return 200;
    }
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [newKeyWordsArray objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    GiftCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[GiftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
        [cell setValue:[newKeyWordsArray objectAtIndex:[indexPath section]]];
        [cell setDelegate:self];
    }
    return cell;
}


@end
