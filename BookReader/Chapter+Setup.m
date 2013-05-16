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
	dispatch_queue_t callerQueue = dispatch_get_current_queue();
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Chapter *persist = [Chapter findFirstByAttribute:@"uid" withValue:self.uid];
			if (!persist) {
				persist = [self cloneInContext:localContext];
			}
		} completion:^(BOOL success, NSError *error) {
			dispatch_async(callerQueue, ^(void) {
				if (block) block();
			});
		}];
	});
}

+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
{
	dispatch_queue_t callerQueue = dispatch_get_current_queue();
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			[array enumerateObjectsUsingBlock:^(Chapter *chapter, NSUInteger idx, BOOL *stop) {
				Chapter *persist = [Chapter findFirstByAttribute:@"uid" withValue:chapter.uid];
				if (!persist) {
					persist = [chapter cloneInContext:localContext];
				}
			}];
		} completion:^(BOOL success, NSError *error) {
			dispatch_async(callerQueue, ^(void) {
				if (block) block();
			});
		}];
	});
}

- (Chapter *)cloneInContext:(NSManagedObjectContext *)context
{
	Chapter *chapter = [Chapter createInContext:context];
	chapter.uid = self.uid;
	chapter.bid = self.bid;
	chapter.name = self.name;
	chapter.bBuy = self.bBuy;
	chapter.bRead = self.bRead;
	chapter.bVip = self.bVip;
	chapter.content = self.content;
	chapter.index = self.index;
	return chapter;
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

@end
