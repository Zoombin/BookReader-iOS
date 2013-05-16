//
//  ContextManager.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContextManager : NSObject

+ (NSManagedObjectContext *)memoryOnlyContext;

@end
