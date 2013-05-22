//
//  Book+Test.h
//  BookReader
//
//  Created by zhangbin on 3/27/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Book.h"

@interface Book (Test)

+ (NSArray *)testBooks;
+ (NSArray *)testRankingBooks;
+ (NSArray *)testRecommendBooks;
+ (NSArray *)testReachBooks;

@end
