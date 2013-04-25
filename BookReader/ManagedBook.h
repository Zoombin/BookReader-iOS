//
//  ManagedBook.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "BookInterface.h"

@interface ManagedBook : NSManagedObject <BookInterface>

+ (NSArray *)booksWithAttributesArray:(NSArray *)array;
+ (id<BookInterface>)createBookWithAttributes:(NSDictionary *)attributes;
+ (id<BookInterface>)createBookWithNonManagedBook:(id<BookInterface>)nonManagedBook;
@end
