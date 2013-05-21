//
//  ChapterViewController.m
//  BookReader
//
//  Created by 颜超 on 12-12-24.
//  Copyright (c) 2012年 颜超. All rights reserved.
//

#import "ChapterViewController.h"
#import "AppDelegate.h"
#import "BookManager.h"
#import "UserDefaultsManager.h"
#import "PurchaseManager.h"
#import "BookReader.h"

#define TOP_BAR_IMAGE [UIImage imageNamed:@"read_top_bar.png"]
#define BACKGROUND_IMAGE [UIImage imageNamed:@"read_more_background.png"]

@implementation ChapterViewController
@synthesize chaptersArray;
@synthesize chaptersRealName;

- (void)viewDidLoad
{
    [super viewDidLoad];
    bFirstAppeared = YES;
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:BACKGROUND_IMAGE];
    [self.view setBackgroundColor:backgroundColor];
    
    UIImageView *topBarImageView = [[UIImageView alloc] initWithImage:TOP_BAR_IMAGE];
    [topBarImageView setFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 42)];
    [self.view addSubview:topBarImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 38)];
    [titleLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Catalogue", nil)]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_menu_top_view_back_button.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5, 5, 63, 29)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
      
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (bFirstAppeared) { //如果是第一次进入章节界面,则加载数据
        [self registIapObservers];
        bought = [[[BookManager sharedInstance]getBookInfoById:bookid] objectForKey:BOUGHT_FLAG];
        
        NSDictionary *tempDict = [[BookManager sharedInstance]getBookInfoById:bookid];
        
        [bookMarkTableView setContentOffset:CGPointMake(320, 50*[[tempDict objectForKey:BEFORE_READ_CHAPTER] intValue]) animated:YES];
        self.chaptersArray = [NSMutableArray arrayWithArray:[[BookManager sharedInstance]getchaptersByBookId:bookid]];
        self.chaptersRealName = [NSMutableArray arrayWithArray:[[BookManager sharedInstance]getchaptersArrayByBookId:bookid]];
        
        bookMarkTableView = [[UITableView alloc] initWithFrame:CGRectMake(6, 50, MAIN_SCREEN.size.width-12, MAIN_SCREEN.size.height-38-40) style:UITableViewStylePlain];
        [bookMarkTableView setBackgroundColor:[UIColor clearColor]];
        bookMarkTableView.delegate = self;
        bookMarkTableView.dataSource = self;
        [bookMarkTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view addSubview:bookMarkTableView];
    }
    bFirstAppeared = NO;
    [bookMarkTableView reloadData];
}

- (id)initBookWithUID:(NSString *)uid
{
    self = [super init];
    if (self) {
        bookid = uid;
        pageArr = [[NSMutableArray alloc] init];
        currentIndex = -1;
    }
    return self;
}


- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    UITableViewCell * cell = [bookMarkTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        int row = [indexPath row];
        if([indexPath row] <= [chaptersArray count]) {
            UIImageView *backgroundView = [[UIImageView alloc] init];
            [backgroundView setFrame:CGRectMake(2,2, MAIN_SCREEN.size.width-14, 46)];
            [backgroundView setImage:[UIImage imageNamed:@"read_settingcellback"]];
            [cell.contentView addSubview:backgroundView];
            
            UILabel *textLabel = [[UILabel alloc] init];
            [textLabel setText:[chaptersRealName objectAtIndex:row]];
            [textLabel setFrame:CGRectMake(10, 5, MAIN_SCREEN.size.width-20, 40)];
            [textLabel setBackgroundColor:[UIColor clearColor]];
            [textLabel setFont:[UIFont systemFontOfSize:17.0]];
            [textLabel setTextAlignment:NSTextAlignmentCenter];
            [backgroundView addSubview:textLabel];
            
            NSDictionary *tempDict = [[BookManager sharedInstance]getBookInfoById:bookid];
            if ([[tempDict objectForKey:BEFORE_READ_CHAPTER] intValue]==[indexPath row]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                currentIndex = [indexPath row];
            }
        }
    }
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chaptersArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    currentIndex=indexPath.row;
    NSInteger bookindex = [[BookManager sharedInstance] getIndex:bookid];
    NSString *productId = [NSString stringWithFormat:@"%@",[[PurchaseManager sharedInstance]getProductIdByIndex:bookindex]];
    if ([[PurchaseManager sharedInstance]checkFreeOrNot] == NO) {
        if (indexPath.row>=19&&[bought isEqualToString:@"0"]&&[productId length]>0) {
            [bookMarkTableView setUserInteractionEnabled:NO];
            return;
        }
    }
    if(![[[[BookManager sharedInstance]getBookInfoById:bookid] objectForKey:BEFORE_READ_CHAPTER] isEqualToString:[NSString stringWithFormat:@"%d",[indexPath row]]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"Aren't the Same", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Read", nil) otherButtonTitles:NSLocalizedString(@"don't read", nil), nil];
        [alertView show];
    }else {
        [[BookManager sharedInstance]saveValueWithBookId:bookid andKey:BEFORE_READ_CHAPTER andValue:[NSString stringWithFormat:@"%d",currentIndex]];
        ReadViewController *controller = [[ReadViewController alloc] initWithBookUID:bookid andShouldMoveToNew:YES andMoveIndex:[chaptersArray objectAtIndex:currentIndex] andNewText:nil];
        //controller.isBuy = [isBuy isEqualToString:@"1"]?YES:NO;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        [[BookManager sharedInstance]saveValueWithBookId:bookid andKey:BEFORE_READ_CHAPTER andValue:[NSString stringWithFormat:@"%d",currentIndex]];
        ReadViewController *controller = [[ReadViewController alloc] initWithBookUID:bookid andShouldMoveToNew:YES andMoveIndex:[chaptersArray objectAtIndex:currentIndex] andNewText:nil];
        //controller.isBuy = [isBuy isEqualToString:@"1"]?YES:NO;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//##############################################
//接收从app store抓取回来的产品，显示在表格上
- (void)getedProds:(NSNotification*)notification
{
    NSLog(@"通过NSNotificationCenter收到信息：%@,", [notification object]);
}

-(void) receivedProducts:(NSNotification*)notification
{
    products_ = [[NSArray alloc] initWithArray:[notification object]];
    if (!products_ || [products_ count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"Can't get product list", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] ;
        [alert show];
    }
}

// 注册IapHander的监听器，并不是所有监听器都需要注册，
// 这里可以根据业务需求和收据认证模式有选择的注册需要
- (void)registIapObservers
{
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(receivedProducts:)
//                                                name:IAPDidReceivedProducts
//                                              object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(failedTransaction:)
//                                                name:IAPDidFailedTransaction
//                                              object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(restoreTransaction:)
//                                                name:IAPDidRestoreTransaction
//                                              object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(completeTransaction:)
//                                                name:IAPDidCompleteTransaction object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeTransactionAndVerifySucceed:)
//                                                name:IAPDidCompleteTransactionAndVerifySucceed
//                                              object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(completeTransactionAndVerifyFailed:)
//                                                name:IAPDidCompleteTransactionAndVerifyFailed
//                                              object:nil];
}

-(void)showAlertWithMsg:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Transaction Info", nil)
                                                   message:message
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                         otherButtonTitles:nil, nil];
    [alert show];
}

-(void) failedTransaction:(NSNotification*)notification
{
    [self showAlertWithMsg:[NSString stringWithFormat:NSLocalizedString(@"Purchase Cancel", nil)]];
    [bookMarkTableView setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelResult"
                                                       object:nil];
}

-(void) restoreTransaction:(NSNotification*)notification
{
    [self showAlertWithMsg:[NSString stringWithFormat:NSLocalizedString(@"Restore Successed", nil)]];
    [bookMarkTableView setUserInteractionEnabled:YES];
}

-(void )completeTransaction:(NSNotification*)notification
{
    [self showAlertWithMsg:[NSString stringWithFormat:NSLocalizedString(@"Purchase Successed", nil)]];
    [bookMarkTableView setUserInteractionEnabled:YES];
}

-(void) completeTransactionAndVerifySucceed:(NSNotification*)notification
{
    NSString *proIdentifier = [notification object];
    [self showAlertWithMsg:[NSString stringWithFormat:@"%@，%@：%@",NSLocalizedString(@"Purchase Successed",nil),NSLocalizedString(@"Product Id",nil),proIdentifier]];
    [[BookManager sharedInstance] saveValueWithBookId:bookid andKey:BOUGHT_FLAG andValue:@"1"];
    bought = @"1";
    [self postNotification];
    [bookMarkTableView setUserInteractionEnabled:YES];
}

-(void) completeTransactionAndVerifyFailed:(NSNotification*)notification
{
    NSString *proIdentifier = [notification object];
    [self showAlertWithMsg:[NSString stringWithFormat:@"%@%@%@",NSLocalizedString(@"Product",nil),NSLocalizedString(@"Purchase failed",nil),proIdentifier]];
    [bookMarkTableView setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"failResult"
                                                       object:nil];
}

- (void)postNotification {
    NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
    [infoDict setObject:@"1" forKey:@"isBuy"];
    [infoDict setObject:@"1" forKey:@"canRead"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"receiveResult"
                                                       object:infoDict];
}

@end
