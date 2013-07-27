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
//	chapter.nextID = attributes[@"nextId"];
//	chapter.previousID = attributes[@"prevId"];
	chapter.rollID = [attributes[@"rollId"] stringValue];
	return chapter;
}

+ (NSArray *)createWithAttributesArray:(NSArray *)array andExtra:(id)extraInfo
{
	NSMutableArray *chapters = [@[] mutableCopy];
    int i = 0;
	for (NSDictionary *attributes in array) {
		Chapter *chapter = (Chapter *)[Chapter createWithAttributes:attributes];
		chapter.index = @(i);
		if (extraInfo) {
			chapter.bid = (NSString *)extraInfo;
		}
		[chapters addObject:chapter];
        i++;
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
		[array enumerateObjectsUsingBlock:^(Chapter *chapter, NSUInteger idx, BOOL *stop) {
			Chapter *chapter = [Chapter findFirstByAttribute:@"uid" withValue:chapter.uid inContext:localContext];
			if (!chapter) {
				chapter = [Chapter createInContext:localContext];
			}
			[chapter clone:chapter];
		}];
	} completion:^(BOOL success, NSError *error) {
			if (block) block();
	}];
}

- (void)clone:(Chapter *)chapter
{
    chapter.bid = self.bid;
    chapter.bVip = self.bVip;
    //chapter.content = self.content;
    chapter.index = self.index;
    //chapter.lastReadIndex = self.lastReadIndex;
    chapter.name = self.name;
	//chapter.nextID = self.nextID;
	//chapter.previousID = self.previousID;
	chapter.rollID = self.rollID;
    chapter.uid = self.uid;
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
    return [Chapter findByAttribute:@"bid" withValue:bookid andOrderBy:@"index" ascending:YES];
}

- (Chapter *)brotherWithIndex:(NSInteger)index
{
	return [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND index = %d", self.bid, index]];
}

- (Chapter *)previous
{
	if (self.index.intValue == 0) return nil;
	return [self brotherWithIndex:self.index.intValue - 1];
}

- (Chapter *)next
{
	return [self brotherWithIndex:self.index.intValue + 1];
}

@end
