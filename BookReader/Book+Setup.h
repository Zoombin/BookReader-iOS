//
//  Book+Setup.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "Book.h"

@interface Book (Setup)

+ (NSManagedObject *)createWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)createWithAttributesArray:(NSArray *)array andExtra:(id)extraInfo;
- (void)persistWithBlock:(dispatch_block_t)block;
+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block;
- (void)truncate;

+ (NSArray *)allBooksOfUser:(NSNumber *)userID;
- (BOOL)needUpdate;
+ (NSArray *)helpBooks;

@end
