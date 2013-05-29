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
		Chapter *persist = [Chapter findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (!persist) {
			persist = [Chapter createInContext:localContext];
		}
		[self clone:persist];
	} completion:^(BOOL success, NSError *error) {
		if (block) block();
	}];
}

+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[array enumerateObjectsUsingBlock:^(Chapter *chapter, NSUInteger idx, BOOL *stop) {
			Chapter *persist = [Chapter findFirstByAttribute:@"uid" withValue:chapter.uid inContext:localContext];
			if (!persist) {
				persist = [Chapter createInContext:localContext];
			}
			[chapter clone:persist];
		}];
	} completion:^(BOOL success, NSError *error) {
			if (block) block();
	}];
}

- (void)clone:(Chapter *)chapter
{
    chapter.bid = self.bid;
    //chapter.bRead = self.bRead;
    chapter.bVip = self.bVip;
    chapter.content = self.content;
    chapter.index = self.index;
    //chapter.lastReadIndex = self.lastReadIndex;
    chapter.name = self.name;
    chapter.uid = self.uid;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(uid=%@, bookID=%@)", self.uid, self.bid];
}

- (void)truncate
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Chapter *persist = [Chapter findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (persist) {
			[persist deleteInContext:localContext];
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

- (Chapter *)previous
{
	if (self.index.intValue == 0) return nil;
	return [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND index = %d", self.bid, self.index.intValue - 1]];
}

- (Chapter *)next
{
	return [Chapter findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@ AND index = %d", self.bid, self.index.intValue + 1]];
}

@end
