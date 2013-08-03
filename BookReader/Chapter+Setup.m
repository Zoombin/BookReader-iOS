//
//  Chapter+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "Chapter+Setup.h"
#import "ContextManager.h"
#import "Book.h"

@implementation Chapter (Setup)

+ (Chapter *)createWithAttributes:(NSDictionary *)attributes
{
    Chapter *chapter = [Chapter createInContext:[ContextManager memoryOnlyContext]];
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
	return [NSString stringWithFormat:@"(uid=%@, bookID=%@)", self.uid, self.bid];
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

+ (void)truncateAll
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[Chapter truncateAllInContext:localContext];
	}];
}

#pragma mark -

+ (NSArray *)allChaptersOfBook:(Book *)book
{
	return [Chapter findByAttribute:@"bid" withValue:book.uid andOrderBy:@"rollID, uid" ascending:YES];
}

+ (NSUInteger)countOfUnreadChaptersOfBook:(Book *)book//TODO: count method wrong
{
	Chapter *biggestReadChapter = [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND lastReadIndex != nil", book.uid] sortedBy:@"uid" ascending:NO];
	if (biggestReadChapter) {
		return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND uid > %@ AND rollID >= %@", book.uid, biggestReadChapter.uid, biggestReadChapter.rollID]];
	} else {
		return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@", book.uid]];
	}
	//[Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND lastReadIndex = nil", book.uid]];
	//return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND lastReadIndex = nil", book.uid]];
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




@end
