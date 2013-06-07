//
//  Chapter+Setup.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Chapter.h"
#import "ZBManagedObjectDelegate.h"

@interface Chapter (Setup) <ZBManagedObjectDelegate>

+ (NSArray *)chaptersRelatedToBook:(NSString *)bookid;
- (Chapter *)brotherWithIndex:(NSInteger)index;
- (Chapter *)previous;
- (Chapter *)next;

@end
