//
//  ManagedChapter.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ManagedChapter.h"

@implementation ManagedChapter
@dynamic uid,bid,name,bBuy,bRead,bVip,content,index;

+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
{
    NSArray *dataBaseArray = [ManagedChapter findByAttribute:@"bid"
                                            withValue:bookid
                                           andOrderBy:@"index"
                                            ascending:YES];
    int i = 0;
    if ([dataBaseArray count]>0)
    {
        ManagedChapter *obj = [dataBaseArray lastObject];
        i = [obj.index integerValue]+1;
    }
	NSMutableArray *chapters = [@[] mutableCopy];
	for (NSDictionary *attributes in array)
    {
		ManagedChapter *chapter = [ManagedChapter createChapterWithAttributes:attributes];
        chapter.index = [NSNumber numberWithInteger:i];
        chapter.bid = bookid;
		[chapters addObject:chapter];
        i++;
	}
	return chapters;
}

+ (id<ChapterInterface>)createChapterWithAttributes:(NSDictionary *)attributes
{
    ManagedChapter *chapter = [ManagedChapter createEntity];
    chapter.name = attributes[@"chapterName"];
    chapter.uid = attributes[@"chapterId"];
    chapter.bVip = attributes[@"isVip"];
    chapter.bBuy = [NSNumber numberWithBool:NO];
	return chapter;
}

+ (id<ChapterInterface>)createChapterWithNonManagedBook:(id<ChapterInterface>)nonManagedBook
{
    ManagedChapter *chapter = [ManagedChapter createEntity];
    chapter.bid = nonManagedBook.bid;
    chapter.index = nonManagedBook.index;
    chapter.name = nonManagedBook.name;
    chapter.uid = nonManagedBook.uid;
    chapter.bVip = nonManagedBook.bVip;
    chapter.bBuy = nonManagedBook.bBuy;
    return chapter;
}
@end
