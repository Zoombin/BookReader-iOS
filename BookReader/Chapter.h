//
//  NonManagedChapter.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChapterInterface.h"

@interface Chapter : NSObject<ChapterInterface>

+ (id<ChapterInterface>)createChapterWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;

@end