//
//  GiftViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "GiftViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GiftCell.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"
#import "UIColor+BookReader.h"
#import "UIButton+BookReader.h"
#import "UILabel+BookReader.h"



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
        newKeyWordsArray = [XXSYGiftTypesMap.allKeys mutableCopy];
		NSLog(@"newKeyWordsArray = %@", newKeyWordsArray);
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
    [self setTitle:@"赠送"];
    
    infoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 44, self.view.bounds.size.width-5*2, self.view.bounds.size.height-44-10) style:UITableViewStylePlain];
    [infoTableView.layer setCornerRadius:4];
    [infoTableView.layer setMasksToBounds:YES];
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
                   withBlock:^(NSString *message, NSError *error) {
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
        [cell setValue:newKeyWordsArray[indexPath.section]];
        [cell setDelegate:self];
    }
    return cell;
}


@end
