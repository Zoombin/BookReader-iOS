//
//  Book+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//


#import "Book+Setup.h"
#import "ContextManager.h"
#import "Chapter.h"

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

+ (NSArray *)createWithAttributesArray:(NSArray *)array andExtra:(id)extraInfo
{
	NSMutableArray *books = [@[] mutableCopy];
	for (NSDictionary *attributes in array) {
		Book *book = (Book *)[self createWithAttributes:attributes];
		if (extraInfo) {
			book.bFav = (NSNumber *)extraInfo;
		}
		[books addObject:book];
	}
	return books;
}

- (void)persistWithBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Book *persist = [Book findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (!persist) {
			persist = [Book createInContext:localContext];
		}
		[self clone:persist];
	} completion:^(BOOL success, NSError *error) {
		if (block) block();
	}];
}

+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[array enumerateObjectsUsingBlock:^(Book *book, NSUInteger idx, BOOL *stop) {
			Book *persist = [Book findFirstByAttribute:@"uid" withValue:book.uid inContext:localContext];
			if (!persist) {
				persist = [Book createInContext:localContext];
			}
			[book clone:persist];
		}];
	} completion:^(BOOL success, NSError *error) {
		if (block) block();
	}];
}


- (void)clone:(Book *)book
{
    book.author = self.author;
    book.authorID = self.authorID;
    book.autoBuy = self.autoBuy;
    book.bFav = self.bFav;
    //book.bHistory = self.bHistory;
    book.category = self.category;
    book.categoryID = self.categoryID;
    //book.cover = self.cover;
    book.coverURL = self.coverURL;
    book.describe = self.describe;
    //book.lastReadChapterID = self.lastReadChapterID;
    book.lastUpdate = self.lastUpdate;
    book.name = self.name;
    //book.progress = self.progress;
    //book.rDate = self.rDate;
    book.recommandID = self.recommandID;
    book.recommandTitle = self.recommandTitle;
    book.uid = self.uid;
    book.words = self.words;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(uid=%@, name=%@)", self.uid, self.name];
}

- (void)truncate
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Book *persist = [Book findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (persist) {
			[persist deleteInContext:localContext];
		}
	}];
}

+ (void)truncateAll
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[Book truncateAllInContext:localContext];
	}];
}

- (NSUInteger)countOfUnreadChapters
{
	return [Chapter countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"bid=%@ and bRead=nil", self.uid]];
}

+ (NSArray *)findAllAndSortedByDate
{
    return [Book findAllSortedBy:@"rDate" ascending:NO];
}

@end
