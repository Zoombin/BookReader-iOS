//
//  Chapter+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "Chapter+Setup.h"

#import "BRContextManager.h"
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
	chapter.rollID = attributes[@"rollId"];
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

#pragma mark -

+ (NSArray *)allChaptersOfBookID:(NSString *)bookID
{
	return [Chapter findByAttribute:@"bid" withValue:bookID andOrderBy:@"rollID,uid" ascending:YES];
}

+ (NSUInteger)countOfUnreadChaptersOfBook:(Book *)book
{
	NSArray *allSortedReadBeforeChapters = [Chapter findAllSortedBy:@"rollID,uid" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND lastReadIndex != nil", book.uid]];
	Chapter *theChapter = allSortedReadBeforeChapters.count ? allSortedReadBeforeChapters[0] : nil;
	if (theChapter) {
		return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"rollID >= %@ AND uid > %@ AND bid = %@", theChapter.rollID, theChapter.uid, book.uid]];
	} else {
		return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@", book.uid]];
	}
}

+ (Chapter *)firstChapterOfBook:(Book *)book
{
	return [self firstChapterOfBookID:book.uid];
}

+ (Chapter *)firstChapterOfBookID:(NSString *)bookID
{
	NSArray *all = [Chapter allChaptersOfBookID:bookID];
	if (all.count) {
		return all[0];
	}
	return nil;
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
	NSArray *allChapters = [Chapter findByAttribute:@"bid" withValue:book.uid andOrderBy:@"uid" ascending:NO];//不用考虑rollid，只要传递最大章节id即可
	if (allChapters.count) {
		return [allChapters[0] uid];
	}
	return @"0";
}

+ (Chapter *)lastReadChapterOfBook:(Book *)book//如果没找到就返回第一章
{
	return [self lastReadChapterOfBookID:book.uid];
}

+ (Chapter *)lastReadChapterOfBookID:(NSString *)bookID
{
	Book *b = [Book findFirstByAttribute:@"uid" withValue:bookID];
	if (b) {
		if (b.lastReadChapterID) {
			return [Chapter findFirstByAttribute:@"uid" withValue:b.lastReadChapterID];
		} else {
			return [Chapter firstChapterOfBookID:bookID];
		}
	}
	return nil;
}

- (NSString *)displayName:(NSArray *)allChapters
{
#ifdef DISPLAY_V_FLAG
	return [NSString stringWithFormat:@"%@ 卷%@:%@", self.bVip.boolValue ? @"v" : @"", [self displayRollID:allChapters], self.name];
#endif
	return [NSString stringWithFormat:@"卷%@:%@", [self displayRollID:allChapters], self.name];
}

- (NSNumber *)displayRollID:(NSArray *)allChapters
{
	if (!allChapters) {
		allChapters = [Chapter allChaptersOfBookID:self.bid];
	}
	NSMutableArray *rollIDs = [NSMutableArray array];
	for (Chapter *c in allChapters) {
		if (![rollIDs containsObject:c.rollID]) {
			[rollIDs addObject:c.rollID];
		}
	}
	
	for (int i = 0; i < rollIDs.count; i++) {
		if (self.rollID.intValue == [rollIDs[i] intValue]) {
			return @(i+1);
		}
	}
	return @(1);
}

@end
