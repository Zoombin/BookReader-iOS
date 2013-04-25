//
//  ManagedChapter.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ChapterInterface.h"

@interface ManagedChapter : NSManagedObject<ChapterInterface>

+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
+ (id<ChapterInterface>)createChapterWithAttributes:(NSDictionary *)attributes;
+ (id<ChapterInterface>)createChapterWithNonManagedBook:(id<ChapterInterface>)nonManagedBook;
@end
