//
//  ZBManagedObjectDelegate.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZBManagedObjectDelegate <NSObject>

+ (NSManagedObject *)createWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)createWithAttributesArray:(NSArray *)array andExtra:(id)extraInfo;

- (void)persistWithBlock:(dispatch_block_t)block;
+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block;

- (void)truncate;
+ (void)truncateAll;

- (NSString *)description;

@end
