//
//  Book.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Book.h"
#import "Chapter.h"

#define XXSY_IMAGE_URL  @"http://images.xxsy.net/simg/"

@implementation BookManaged
@dynamic uid,author,authorID,autoBuy,category,categoryID,cover,coverURL,describe,lastUpdate,name,progress,recommandID,recommandTitle,words;
@end



@implementation Book

@synthesize uid,author,authorID,autoBuy,category,categoryID,cover,coverURL,describe,lastUpdate,name,progress,recommandID,recommandTitle,words;

+ (Book *)createBookWithAttributes:(NSDictionary *)attributes
{
    Book *book = [[Book alloc] init];
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

+ (NSArray *)booksWithAttributesArray:(NSArray *)array
{
   	NSMutableArray *books = [@[] mutableCopy];
	for (NSDictionary *attributes in array) {
		Book *book = [self createBookWithAttributes:attributes];
		[books addObject:book];
	}
	return books;
}

- (void)sync:(BookManaged *)managed
{
	managed.name = name;
	managed.progress = progress;
	managed.uid = uid;
	managed.author = author;
	managed.authorID = authorID;
	managed.autoBuy = autoBuy;
	managed.cover = cover;
	managed.coverURL = coverURL;
	managed.category = category;
	managed.categoryID = categoryID;
	managed.words = words;
	managed.lastUpdate = lastUpdate;
	managed.describe = describe;
	managed.recommandID = recommandID;
	managed.recommandTitle = recommandTitle;
}

- (void)truncate
{
	BookManaged *managed = [BookManaged findFirstByAttribute:@"uid" withValue:uid];
	if (managed) {
		[managed deleteEntity];
	}
	[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}

+ (void)truncateAll
{
	[BookManaged truncateAll];
	[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}


- (void)persistWithBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		BookManaged *managed = [BookManaged findFirstByAttribute:@"uid" withValue:uid inContext:localContext];
		if (!managed) {
			managed = [BookManaged createInContext:localContext];
		}
		[self sync:managed];
		if (block) block();
	}];
}

- (BOOL)persisted
{
	//TODO: try to use countOfEntitiesWithPredicate improve performance?
	NSArray *array = [[self class] findAllWithPredicate:[NSPredicate predicateWithFormat:@"uid=%@", uid]];
	return array.count == 0 ? NO : YES;
}

+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		for (Book *book in array) {
			BookManaged *managed = [BookManaged findFirstByAttribute:@"uid" withValue:book.uid inContext:localContext];
			if (!managed) {
				managed = [BookManaged createInContext:localContext];
			}
			[book sync:managed];
		}
		if (block) block();
	}];
}

- (NSNumber *)numberOfUnreadChapters
{
	return [ChapterManaged numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ and bRead==NO",uid]];
}

+ (NSArray *)create:(NSArray *)mangedArray
{
	NSMutableArray *rtnAll = [@[] mutableCopy];
	for (BookManaged *manged in mangedArray) {
		[rtnAll addObject:[self createWithManaged:manged]];
	}
	return rtnAll;
}

+ (NSArray *)findAll
{
	NSArray *all = [BookManaged findAll];
	return [self create:all];
}

+ (Book *)createWithManaged:(BookManaged *)managed
{
	Book *book = [[Book alloc] init];
	book.name = managed.name;
	book.progress = managed.progress;
	book.uid = managed.uid;
	book.author = managed.author;
	book.authorID = managed.authorID;
	book.autoBuy = managed.autoBuy;
	book.cover = managed.cover;
	book.coverURL = managed.coverURL;
	book.category = managed.category;
	book.categoryID = managed.categoryID;
	book.words = managed.words;
	book.lastUpdate = managed.lastUpdate;
	book.describe = managed.describe;
	book.recommandID = managed.recommandID;
	book.recommandTitle = managed.recommandTitle;
	return book;
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm
{
	NSArray *all = [BookManaged findAllWithPredicate:searchTerm];
	return [self create:all];
}
@end
