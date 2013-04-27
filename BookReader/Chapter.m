//
//  NonManagedChapter.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Chapter.h"

@implementation ManagedChapter
@dynamic uid,bid,name,bBuy,bRead,bVip,content,index;
@end

@implementation Chapter
@synthesize uid,bid,name,bBuy,bRead,bVip,content,index;
+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
{
	NSMutableArray *chapters = [@[] mutableCopy];
    int i = 0;
	for (NSDictionary *attributes in array)
    {
		Chapter *chapter = [Chapter createChapterWithAttributes:attributes];
        chapter.index = [NSNumber numberWithInteger:i];
        chapter.bid = bookid;
		[chapters addObject:chapter];
        i++;
	}
	return chapters;
}

+ (id<ChapterInterface>)createChapterWithAttributes:(NSDictionary *)attributes
{
    Chapter *chapter = [[Chapter alloc] init];
    chapter.name = attributes[@"chapterName"];
    chapter.uid = [attributes[@"chapterId"] stringValue];
    chapter.bVip = attributes[@"isVip"];
    chapter.bRead = [NSNumber numberWithBool:NO];
    chapter.bBuy = [NSNumber numberWithBool:NO];
	return chapter;
}

- (void)sync:(ManagedChapter *)managed
{
	managed.uid = uid;
	managed.bid = bid;
	managed.name = name;
	managed.bBuy = bBuy;
	managed.bRead = bRead;
	managed.bVip = bVip;
	managed.content = content;
	managed.index = index;
}

- (void)persist
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		ManagedChapter *managed = [ManagedChapter findFirstByAttribute:@"uid" withValue:uid inContext:localContext];
		if (!managed) {
			managed = [ManagedChapter createInContext:localContext];
		}
		[self sync:managed];
	}];
}

+ (void)persist:(NSArray *)array
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		for (Chapter *chapter in array) {
			ManagedChapter *managed = [ManagedChapter findFirstByAttribute:@"uid" withValue:chapter.uid inContext:localContext];
			if (!managed) {
				managed = [ManagedChapter createInContext:localContext];
			}
			[chapter sync:managed];
		}
	}];
}

+ (NSArray *)findAll
{
	NSArray *all = [ManagedChapter findAll];
	NSMutableArray *rtnAll = [@[] mutableCopy];
	for (ManagedChapter *manged in all) {
		[rtnAll addObject:[self createWithManaged:manged]];
	}
	return rtnAll;
}

+ (Chapter *)createWithManaged:(ManagedChapter *)managed
{
	Chapter *chapter = [[Chapter alloc] init];
	chapter.uid = managed.uid;
	chapter.bid = managed.bid;
	chapter.name = managed.name;
	chapter.bBuy = managed.bBuy;
	chapter.bRead = managed.bRead;
	chapter.bVip = managed.bVip;
	chapter.content = managed.content;
	chapter.index = managed.index;
	return chapter;
}

@end
