//
//  PurchaseManager.h
//  BookReader
//
//  Created by 颜超 on 13-1-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseManager : NSObject {
}
+ (PurchaseManager *)sharedInstance;

//获取某个id
- (NSString *)getProductIdByIndex:(NSInteger)index;

//获取index
- (NSInteger)getIndexByProductId:(NSString *)pid;

//检查是否免费
- (BOOL)checkFreeOrNot;
@end
