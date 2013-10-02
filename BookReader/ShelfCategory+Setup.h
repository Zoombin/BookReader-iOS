//
//  ShelfCategory+Setup.h
//  BookReader
//
//  Created by zhangbin on 9/28/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "ShelfCategory.h"

@interface ShelfCategory (Setup)

+ (void)createDefaultShelfCategoryWithCompletionBlock:(dispatch_block_t)block;
+ (void)createShelfCategoryWithName:(NSString *)name withCompletionBlock:(dispatch_block_t)block;

@end
