//
//  NonManagedBook.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookInterface.h"

@interface Book : NSObject<BookInterface>

+ (id<BookInterface>)createBookWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)booksWithAttributesArray:(NSArray *)array;
@end
