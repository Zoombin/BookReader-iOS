//
//  Chapter+Setup.h
//  BookReader
//
//  Created by 颜超 on 13-4-24.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Chapter.h"

@interface Chapter (Setup)
+ (Chapter *)createWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
@end
