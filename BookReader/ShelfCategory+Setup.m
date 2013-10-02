//
//  ShelfCategory+Setup.m
//  BookReader
//
//  Created by zhangbin on 9/28/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "ShelfCategory+Setup.h"

@implementation ShelfCategory (Setup)

+ (void)createDefaultShelfCategoryWithCompletionBlock:(dispatch_block_t)block
{
	[self createShelfCategoryWithName:@"默认" withCompletionBlock:block];
}

+ (void)createShelfCategoryWithName:(NSString *)name withCompletionBlock:(dispatch_block_t)block
{
	if (!name) return;
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		ShelfCategory *shelfCategory = [ShelfCategory findFirstByAttribute:@"name" withValue:name inContext:localContext];
		if (!shelfCategory) {
			shelfCategory = [ShelfCategory createInContext:localContext];
			shelfCategory.name = name;
		}
	} completion:^(BOOL success, NSError *error) {
		if (block) block ();
	}];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<name: %@>", self.name];
}

@end
