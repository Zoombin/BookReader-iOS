//
//  Book+Test.h
//  BookReader
//
//  Created by zhangbin on 3/27/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "NonManagedBook.h"

@interface NonManagedBook (Test)

+ (NSArray *)testBooks;
+ (NSArray *)testRankingBooks;
+ (NSArray *)testRecommandBooks;
+ (NSArray *)testReachBooks;

@end
