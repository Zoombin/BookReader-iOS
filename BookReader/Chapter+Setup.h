//
//  Chapter+Setup.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Chapter.h"

@interface Chapter (Setup)

+ (NSArray *)createWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
+ (NSArray *)chaptersWithBookID:(NSString *)bookid;

@end
