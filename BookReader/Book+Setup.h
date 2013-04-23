//
//  Book+Setup.h
//  BookReader
//
//  Created by zhangbin on 4/23/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Book.h"

@interface Book (Setup)
+ (Book *)createWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)booksWithAttributesArray:(NSArray *)array;
@end
