//
//  Book+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//


#import "Book+Setup.h"
#import "ContextManager.h"

#define XXSY_IMAGE_URL  @"http://images.xxsy.net/simg/"

@implementation Book (Setup)

+ (NSManagedObject *)createWithAttributes:(NSDictionary *)attributes
{
    Book *book = [Book createInContext:[ContextManager memoryOnlyContext]];
	book.author = attributes[@"authorName"];
	book.autoBuy = attributes[@"auto"];
	book.name = attributes[@"bookName"];
	book.category = attributes[@"className"];
	book.recommandID = attributes[@"recId"];
	book.recommandTitle = attributes[@"recTitle"];
	book.describe = attributes[@"intro"];
	book.words = attributes[@"length"];
	book.lastUpdate = attributes[@"lastUpdateTime"];
	book.categoryID = attributes[@"classId"];
    book.rDate = [NSDate date];
    book.lastReadChapterIndex = [NSNumber numberWithInt:0];
    book.lastReadIndex = [NSNumber numberWithInt:0];
	if (attributes[@"bookId"]) {
		book.uid = [attributes[@"bookId"] stringValue];
	} else if (attributes[@"bookid"]) {
		book.uid = [attributes[@"bookid"] stringValue];
	}
	
	if (attributes[@"authorId"]) {
		book.authorID = attributes[@"authorId"];
	} else if (attributes[@"authorid"]) {
		book.authorID = attributes[@"authorid"];
	}
	if (book.uid) {
		book.coverURL = [NSString stringWithFormat:@"%@%@.jpg", XXSY_IMAGE_URL, book.uid];
	}
	return book;
}

+ (NSArray *)createWithAttributesArray:(NSArray *)array
{
   	NSMutableArray *books = [@[] mutableCopy];
	for (NSDictionary *attributes in array) {
		Book *book = (Book *)[self createWithAttributes:attributes];
		[books addObject:book];
	}
	return books;
}

+ (NSArray *)createWithAttributesArray:(NSArray *)array andFav:(BOOL)fav
{
   	NSMutableArray *books = [@[] mutableCopy];
	for (NSDictionary *attributes in array) {
		Book *book = (Book *)[self createWithAttributes:attributes];
        book.bFav = [NSNumber numberWithBool:fav];
		[books addObject:book];
	}
	return books;
}

- (void)persistWithBlock:(dispatch_block_t)block
{
	dispatch_queue_t callerQueue = dispatch_get_current_queue();
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Book *persistBook = [Book findFirstByAttribute:@"uid" withValue:self.uid];
			if (!persistBook) {
				persistBook = [self cloneInContext:localContext];
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
			[array enumerateObjectsUsingBlock:^(Book *book, NSUInteger idx, BOOL *stop) {
				Book *persistBook = [Book findFirstByAttribute:@"uid" withValue:book.uid];
				if (!persistBook) {
					persistBook = [book cloneInContext:localContext];
				}
			}];
		} completion:^(BOOL success, NSError *error) {
			dispatch_async(callerQueue, ^(void) {
				if (block) block();
			});
		}];
	});
}


- (Book *)cloneInContext:(NSManagedObjectContext *)context
{
	Book *book = [Book createInContext:context];
	book.name = self.name;
	book.progress = self.progress;
	book.uid = self.uid;
	book.author = self.author;
	book.authorID = self.authorID;
	book.autoBuy = self.autoBuy;
	book.cover = self.cover;
	book.coverURL = self.coverURL;
	book.category = self.category;
	book.categoryID = self.categoryID;
	book.words = self.words;
	book.lastUpdate = self.lastUpdate;
	book.describe = self.describe;
	book.recommandID = self.recommandID;
	book.recommandTitle = self.recommandTitle;
	book.rDate = self.rDate;
	book.lastReadChapterIndex = self.lastReadChapterIndex;
    book.lastReadIndex = self.lastReadIndex;
	book.bFav = self.bFav;
	book.bHistory = self.bHistory;
	return book;
}

//- (void)truncate
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		BookManaged *managed = [BookManaged findFirstByAttribute:@"uid" withValue:uid];
//		if (managed) {
//			[managed deleteInContext:localContext];
//		}
//	}];
//	[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
//}
//
//+ (void)truncateAll
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		[BookManaged truncateAllInContext:localContext];
//	}];
//	[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
//}


//- (void)persistWithBlock:(dispatch_block_t)block
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		BookManaged *managed = [BookManaged findFirstByAttribute:@"uid" withValue:uid inContext:localContext];
//		if (!managed) {
//			managed = [BookManaged createInContext:localContext];
//		}
//		[self sync:managed];
//		if (block) block();
//	}];
//}

//- (BOOL)persisted
//{
//	//TODO: try to use countOfEntitiesWithPredicate improve performance?
//	NSArray *array = [[self class] findAllWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", uid]];
//	return array.count == 0 ? NO : YES;
//}

//+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
//{
//	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//		for (Book *book in array) {
//			BookManaged *managed = [BookManaged findFirstByAttribute:@"uid" withValue:book.uid inContext:localContext];
//			if (!managed) {
//				managed = [BookManaged createInContext:localContext];
//			}
//			[book sync:managed];
//		}
//		if (block) block();
//	}];
//}

//- (NSNumber *)numberOfUnreadChapters
//{
//	return [ChapterManaged numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ and bRead==NO",uid]];
//}
//
//+ (NSArray *)create:(NSArray *)mangedArray
//{
//	NSMutableArray *rtnAll = [@[] mutableCopy];
//	for (BookManaged *manged in mangedArray) {
//		[rtnAll addObject:[self createWithManaged:manged]];
//	}
//	return rtnAll;
//}
//
//+ (NSArray *)findAll
//{
//	NSArray *all = [BookManaged findAll];
//	return [self create:all];
//}
//
//+ (Book *)createWithManaged:(BookManaged *)managed
//{
//	Book *book = [[Book alloc] init];
//	book.name = managed.name;
//	book.progress = managed.progress;
//	book.uid = managed.uid;
//	book.author = managed.author;
//	book.authorID = managed.authorID;
//	book.autoBuy = managed.autoBuy;
//	book.cover = managed.cover;
//	book.coverURL = managed.coverURL;
//	book.category = managed.category;
//	book.categoryID = managed.categoryID;
//	book.words = managed.words;
//	book.lastUpdate = managed.lastUpdate;
//	book.describe = managed.describe;
//	book.recommandID = managed.recommandID;
//	book.recommandTitle = managed.recommandTitle;
//    book.rDate = managed.rDate;
//    book.lastReadChapterIndex = managed.lastReadChapterIndex;
//    book.bFav = managed.bFav;
//    book.bHistory = managed.bHistory;
//	return book;
//}

//+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm
//{
//	NSArray *all = [BookManaged findAllWithPredicate:searchTerm];
//	return [self create:all];
//}
//
//+ (NSArray *)findAllAndSortedByDate
//{
//    NSArray *all = [BookManaged findAllSortedBy:@"rDate" ascending:NO];
//    return [self create:all];
//}

@end
