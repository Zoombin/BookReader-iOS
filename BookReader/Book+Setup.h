//
//  Book+Setup.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Book.h"
#import "ZBManagedObjectDelegate.h"

@interface Book (Setup) <ZBManagedObjectDelegate>

- (NSUInteger)countOfUnreadChapters;
+ (NSArray *)findAllAndSortedByDate;

@end
