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
#import "UIColor+BookReader.h"
#import <QuartzCore/QuartzCore.h>


@implementation GiftViewController {
    NSString *currentIndex;
    Book *bookObj;
    NSArray *integralArrays;
    
    NSMutableArray *newKeyWordsArray;
    UITableView *infoTableView;
}

- (id)initWithIndex:(NSString *)index andBook:(Book *)book {
    self = [super init];
    if (self) {
        currentIndex = index;
        bookObj = book;
        NSLog(@"==>%@",currentIndex);
        newKeyWordsArray = [NSMutableArray arrayWithObjects:@"钻石",@"鲜花",@"打赏",@"月票",@"评价票", nil];
        NSString *key = [newKeyWordsArray objectAtIndex:[index intValue]];
        [newKeyWordsArray removeObject:key];
        [newKeyWordsArray insertObject:key atIndex:0];
    
        integralArrays = @[@"不知所云",@"随便看看",@"值得一看",@"不容错过",@"经典必看"];
        //  1:送钻石 2:送鲜花 3:打赏 4:月票 5:投评价
        // 1:不知所云 2:随便看看 3:值得一看 4:不容错过 5:经典必看
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor: [UIColor mainBackgroundColor]];
	// Do any additional setup after loading the view.
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame: CGRectMake(10, 4, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setText:@"赠送"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 44, MAIN_SCREEN.size.width-5*2, MAIN_SCREEN.size.height-44-30) style:UITableViewStylePlain];
    [infoTableView.layer setCornerRadius:4];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setDataSource:self];
    [infoTableView setDelegate:self];
    [self.view addSubview:infoTableView];
}

- (void)sendButtonClick:(NSDictionary *)value
{
    NSLog(@"%@",value);
//    NSString *integral = @"";
//    NSString *count = [value objectForKey:@"count"];
//    NSString *index = [value objectForKey:@"index"];
//    if ([value objectForKey:@"integral"]) {
//        integral = [value objectForKey:@"integral"];
//    }
//    [self displayHUD:@"处理中..."];
//    [ServiceManager giveGiftWithType:index
//                      author:bookObj.authorID
//                       count:count
//                    integral:integral
//                     andBook:bookObj.uid
//                   withBlock:^(NSString *result, NSError *error) {
//                       if (error) {
//                           [self displayHUDError:nil message:NETWORK_ERROR];
//                       }else {
//                           [self displayHUDError:nil message:result];
//                       }
//                   }];
}

- (void)backButtonClicked
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
        return 140;
    }
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    GiftCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[GiftCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier andIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setValue:[newKeyWordsArray objectAtIndex:[indexPath section]]];
        [cell setDelegate:self];
    }
    return cell;
}


@end
