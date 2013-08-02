//
//  ContextManager.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "ContextManager.h"

static NSManagedObjectContext *memoryOnlyContext;

@implementation ContextManager

+ (NSManagedObjectContext *)memoryOnlyContext
{
	if (!memoryOnlyContext) {
		memoryOnlyContext = [NSManagedObjectContext MR_context];
	}
	return memoryOnlyContext;
}

@end
