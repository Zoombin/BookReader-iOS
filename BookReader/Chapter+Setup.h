//
//  Chapter+Setup.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "Chapter.h"
#import "ZBManagedObjectDelegate.h"

@class Book;
@interface Chapter (Setup) <ZBManagedObjectDelegate>

+ (NSArray *)allChaptersOfBook:(Book *)book;
+ (NSUInteger)countOfUnreadChaptersOfBook:(Book *)book;
+ (Chapter *)firstChapterOfBook:(Book *)book;
- (Chapter *)previous;
- (Chapter *)next;



@end
