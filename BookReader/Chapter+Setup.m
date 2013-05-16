//
//  Chapter+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Chapter+Setup.h"
#import "ContextManager.h"

@implementation Chapter (Setup)

+ (Chapter *)createWithAttributes:(NSDictionary *)attributes
{
    Chapter *chapter = [Chapter createInContext:[ContextManager memoryOnlyContext]];
    chapter.name = attributes[@"chapterName"];
    chapter.uid = [attributes[@"chapterId"] stringValue];
    chapter.bVip = attributes[@"isVip"];
    chapter.bRead = [NSNumber numberWithBool:NO];
    chapter.bBuy = [NSNumber numberWithBool:NO];
	return chapter;
}

+ (NSArray *)createWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;
{
	NSMutableArray *chapters = [@[] mutableCopy];
    int i = 0;
	for (NSDictionary *attributes in array)
    {
		Chapter *chapter = (Chapter *)[Chapter createWithAttributes:attributes];
        chapter.index = [NSNumber numberWithInteger:i];
        chapter.bid = bookid;
		[chapters addObject:chapter];
        i++;
	}
	return chapters;
}

+ (NSArray *)chaptersWithBookID:(NSString *)bookid
{
    return [Chapter findByAttribute:@"bid" withValue:bookid andOrderBy:@"index" ascending:YES];
}

//
//- (void)sync:(ChapterManaged *)managed
//{
//	managed.uid = uid;
//	managed.bid = bid;
//	managed.name = name;
//	managed.bBuy = bBuy;
//	managed.bRead = bRead;
//	managed.bVip = bVip;
//	managed.content = content;
//	managed.index = index;
//}

//- (void)truncate
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		ChapterManaged *managed = [ChapterManaged findFirstByAttribute:@"uid" withValue:uid];
//		if (managed) {
//			[managed deleteInContext:localContext];
//		}
//	}];
//	[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
//}
//
//+ (void)truncateAll
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		[ChapterManaged truncateAllInContext:localContext];
//	}];
//	[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
//}
//
//- (void)persistWithBlock:(dispatch_block_t)block
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		ChapterManaged *managed = [ChapterManaged findFirstByAttribute:@"uid" withValue:uid inContext:localContext];
//		if (!managed) {
//			managed = [ChapterManaged createInContext:localContext];
//		}
//		[self sync:managed];
//		if (block) block();
//	}];
//}

//+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		for (Chapter *chapter in array) {
//			ChapterManaged *managed = [ChapterManaged findFirstByAttribute:@"uid" withValue:chapter.uid inContext:localContext];
//			if (!managed) {
//				managed = [ChapterManaged createInContext:localContext];
//			}
//			[chapter sync:managed];
//		}
//		if (block) block();
//	}];
//}
//
//+ (NSArray *)create:(NSArray *)mangedArray
//{
//	NSMutableArray *rtnAll = [@[] mutableCopy];
//	for (ChapterManaged *manged in mangedArray) {
//		[rtnAll addObject:[self createWithManaged:manged]];
//	}
//	return rtnAll;
//}

//+ (NSArray *)findAll
//{
//	NSArray *all = [ChapterManaged findAll];
//	return [self create:all];
//}
//

//
//+ (Chapter *)createWithManaged:(ChapterManaged *)managed
//{
//	Chapter *chapter = [[Chapter alloc] init];
//	chapter.uid = managed.uid;
//	chapter.bid = managed.bid;
//	chapter.name = managed.name;
//	chapter.bBuy = managed.bBuy;
//	chapter.bRead = managed.bRead;
//	chapter.bVip = managed.bVip;
//	chapter.content = managed.content;
//	chapter.index = managed.index;
//	return chapter;
//}
//
//+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm
//{
//	NSArray *all = [ChapterManaged findAllWithPredicate:searchTerm];
//	return [self create:all];
//}


@end
