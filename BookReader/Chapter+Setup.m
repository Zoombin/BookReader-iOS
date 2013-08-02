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
		[self clone:chapter];
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

+ (NSArray *)chaptersRelatedToBook:(NSString *)bookid
{
    return [Chapter findByAttribute:@"bid" withValue:bookid];
}

- (Chapter *)previous
{
	if (!self.previousID) return nil;
	return [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", self.previousID]];
}

- (Chapter *)next
{
	if (!self.nextID) return nil;
	return [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@", self.nextID]];
}

@end
