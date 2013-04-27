//
//  NonManagedChapter.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "NonManagedChapter.h"

@implementation NonManagedChapter
@synthesize uid,bid,name,bBuy,bRead,bVip,content,index;
+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
{
	NSMutableArray *chapters = [@[] mutableCopy];
    int i = 0;
	for (NSDictionary *attributes in array)
    {
		NonManagedChapter *chapter = [NonManagedChapter createChapterWithAttributes:attributes];
        chapter.index = [NSNumber numberWithInteger:i];
        chapter.bid = bookid;
		[chapters addObject:chapter];
        i++;
	}
	return chapters;
}

+ (id<ChapterInterface>)createChapterWithAttributes:(NSDictionary *)attributes
{
    NonManagedChapter *chapter = [[NonManagedChapter alloc] init];
    chapter.name = attributes[@"chapterName"];
    chapter.uid = [attributes[@"chapterId"] stringValue];
    chapter.bVip = attributes[@"isVip"];
    chapter.bRead = [NSNumber numberWithBool:NO];
    chapter.bBuy = [NSNumber numberWithBool:NO];
	return chapter;
}
@end
