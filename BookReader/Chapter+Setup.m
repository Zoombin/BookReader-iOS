//
//  Chapter+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "Chapter+Setup.h"
#import "BRContextManager.h"
#import "Book.h"
#import "Book+Setup.h"
#import "ServiceManager.h"

@implementation Chapter (Setup)

+ (Chapter *)createWithAttributes:(NSDictionary *)attributes
{
    Chapter *chapter = [Chapter createInContext:[BRContextManager memoryOnlyContext]];
    chapter.name = attributes[@"chapterName"];
    chapter.uid = [attributes[@"chapterId"] stringValue];
    chapter.bVip = attributes[@"isVip"];
	//chapter.nextID = [attributes[@"nextId"] stringValue];
	//chapter.previousID = [attributes[@"prevId"] stringValue];
	chapter.rollID = [attributes[@"rollId"] stringValue];
	return chapter;
}

+ (NSArray *)createWithAttributesArray:(NSArray *)array andExtra:(id)extraInfo
{
	NSMutableArray *chapters = [@[] mutableCopy];
	for (NSDictionary *attributes in array) {
		Chapter *chapter = (Chapter *)[Chapter createWithAttributes:attributes];
		if (extraInfo) {
			chapter.bid = (NSString *)extraInfo;
		}
		[chapters addObject:chapter];
	}
	return chapters;

}

- (void)persistWithBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Chapter *chapter = [Chapter findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (!chapter) {
			chapter = [Chapter createInContext:localContext];
		}
		[chapter clone:self];
	} completion:^(BOOL success, NSError *error) {
		if (block) block();
	}];
}

+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[array enumerateObjectsUsingBlock:^(Chapter *c, NSUInteger idx, BOOL *stop) {
			Chapter *chapter = [Chapter findFirstByAttribute:@"uid" withValue:c.uid inContext:localContext];
			if (!chapter) {
				chapter = [Chapter createInContext:localContext];
			}
			[chapter clone:c];
		}];
	} completion:^(BOOL success, NSError *error) {
			if (block) block();
	}];
}

- (void)clone:(Chapter *)chapter
{	
	self.bid = chapter.bid;
	self.bVip = chapter.bVip;
//	self.content = chapter.content;
//	self.lastReadIndex = chapter.lastReadIndex;
	self.name = chapter.name;
//	self.nextID = chapter.nextID;
//	self.previousID = chapter.previousID;
	self.rollID = chapter.rollID;
	self.uid = chapter.uid;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(uid: %@, bookID: %@, bVip: %@, name: %@)", self.uid, self.bid, self.bVip, self.name];
}

- (void)truncate
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Chapter *chapter = [Chapter findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (chapter) {
			[chapter deleteInContext:localContext];
		}
	}];
}

//+ (void)truncateAll
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		[Chapter truncateAllInContext:localContext];
//	}];
//}

#pragma mark -

+ (NSArray *)allChaptersOfBookID:(NSString *)bookID
{
	return [Chapter findByAttribute:@"bid" withValue:bookID andOrderBy:@"rollID,uid" ascending:YES];
}

+ (NSUInteger)countOfUnreadChaptersOfBook:(Book *)book//TODO: count method wrong
{
//	Chapter *biggestReadChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND lastReadIndex != nil", book.uid] sortedBy:@"rollID, uid" ascending:NO];
//	if (biggestReadChapter) {
//		return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND uid > %@ AND rollID >= %@", book.uid, biggestReadChapter.uid, biggestReadChapter.rollID]];
//	} else {
//		return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@", book.uid]];
//	}

	return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND lastReadIndex = nil", book.uid]];
}

+ (Chapter *)firstChapterOfBook:(Book *)book
{
	return [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND rollID = 1", book.uid] sortedBy:@"uid" ascending:YES];
}

- (Chapter *)previous
{
	if (!self.previousID) return nil;
	return [Chapter findFirstByAttribute:@"uid" withValue:self.previousID];
}

- (Chapter *)next
{
	if (!self.nextID) return nil;
	return [Chapter findFirstByAttribute:@"uid" withValue:self.nextID];
}

+ (NSArray *)contentNilChapters
{
	return [Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"content = nil"]];
}

+ (NSArray *)chaptersNeedFetchContentWhenWifiReachable:(BOOL)bWifi
{
	NSArray *allContentNilChapters = [self contentNilChapters];
	if (bWifi) {
		return allContentNilChapters;
	}
	NSMutableArray *chaptersNeedFetchContent = [NSMutableArray array];
	[allContentNilChapters enumerateObjectsUsingBlock:^(Chapter *chapter, NSUInteger idx, BOOL *stop) {
		Book *b = [Book findFirstByAttribute:@"uid" withValue:chapter.bid];
		if (b) {
			if (b.autoBuy.boolValue) {
				[chaptersNeedFetchContent addObject:chapter];
			} else {
				if (b.lastReadChapterID != nil) {
					[chaptersNeedFetchContent addObject:chapter];
				}
			}
		}
	}];
	return chaptersNeedFetchContent;
}

+ (NSArray *)chaptersNeedSubscribe
{
	NSArray *allContentNilChapters = [self contentNilChapters];
	NSMutableArray *chaptersNeedSubscribe = [NSMutableArray array];
	[allContentNilChapters enumerateObjectsUsingBlock:^(Chapter *chapter, NSUInteger idx, BOOL *stop) {
		Book *b = [Book findFirstByAttribute:@"uid" withValue:chapter.bid];
		if (b) {
			if (b.autoBuy.boolValue) {
				[chaptersNeedSubscribe addObject:chapter];
			}
		}
	}];
	return chaptersNeedSubscribe;
}

+ (NSString *)lastChapterIDOfBook:(Book *)book
{
	NSArray *allChapters = [Chapter findByAttribute:@"bid" withValue:book.uid andOrderBy:@"rollID,uid" ascending:NO];
	if (allChapters.count) {
		return [allChapters[0] uid];
	}
	return @"0";
}

+ (Chapter *)lastReadChapterOfBook:(Book *)book//如果没找到就返回第一章
{
	Book *b = [Book findFirstByAttribute:@"uid" withValue:book.uid];
	if (b) {
		if (b.lastReadChapterID) {
			return [Chapter findFirstByAttribute:@"uid" withValue:b.lastReadChapterID];
		} else {
			return [Chapter firstChapterOfBook:book];
		}
	}
	return nil;
}

@end
