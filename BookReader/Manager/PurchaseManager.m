//
//  PurchaseManager.m
//  BookReader
//
//  Created by 颜超 on 13-1-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "PurchaseManager.h"


#define PM_BOOK_ID @"BookId"
#define PM_PRODUCT_ID @"ProductId"
#define PM_IS_FREE @"是否免费"

@implementation PurchaseManager
static PurchaseManager *manager;
static NSDictionary *infoDict;

+(PurchaseManager *)sharedInstance {
    
    if (!manager) {
        manager = [[PurchaseManager alloc] init];
        
        NSString *pathName = [NSString stringWithFormat:@"BookDoc/Purchase"];
        NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:@"plist"];
        infoDict = [[NSDictionary alloc] initWithContentsOfFile:documentDir];
        
    }
    return manager;
}

- (NSString *)getProductIdByIndex:(NSInteger)index {
    NSString *bookId = [NSString stringWithFormat:@"%@",[infoDict objectForKey:PM_BOOK_ID]];
    NSArray *infoArray = [infoDict objectForKey:PM_PRODUCT_ID];
    return [bookId stringByAppendingString:[infoArray objectAtIndex:index]];
}

- (NSInteger)getIndexByProductId:(NSString *)pid {
    NSString *bookId = [NSString stringWithFormat:@"%@",[infoDict objectForKey:PM_BOOK_ID]];
    NSArray *infoArray = [infoDict objectForKey:PM_PRODUCT_ID];
    NSString *productId = [pid stringByReplacingOccurrencesOfString:bookId withString:@""];
    if([infoArray containsObject:productId]) {
        return [infoArray indexOfObject:productId];
    }
    else return 0;//如果查询不到就返回0避免后面的crash隐患。
}

- (BOOL)checkFreeOrNot {
    return [[infoDict objectForKey:PM_IS_FREE] boolValue];
}

@end
