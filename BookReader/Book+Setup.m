//
//  Book+Setup.m
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
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
    book.bVip = attributes[@"isVip"];
	book.recommendID = attributes[@"recId"];
	book.recommendTitle = attributes[@"recTitle"];
	book.describe = attributes[@"intro"];
	book.words = attributes[@"length"];
    book.lastChapterName = attributes[@"lastChapterName"];
	book.lastUpdate = attributes[@"lastUpdateTime"];
	book.categoryID = attributes[@"classId"];
	book.updateDate = [NSDate date];
	book.bCover = attributes[@"cover"];
    book.bFinish = attributes[@"undone"];
    book.status = attributes[@"status"];
    book.monthTicket = attributes[@"monthTicket"];
    if (attributes[@"typeName"]) {
        book.category = attributes[@"typeName"];
    }
    if (attributes[@"props"]) {
        book.comment = attributes[@"props"][@"comment"];
        book.commentPersons = attributes[@"props"][@"commentPersons"];
        book.diamond = attributes[@"props"][@"diamond"];
        book.flower = attributes[@"props"][@"flower"];
        book.reward = attributes[@"props"][@"reward"];
        book.rewardPersons = attributes[@"props"][@"rewardPersons"];
    }
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
		Book *book = [Book findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (!book) {
			book = [Book createInContext:localContext];
		}
		[book clone:self];
	} completion:^(BOOL success, NSError *error) {
		if (block) block();
	}];
}

+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[array enumerateObjectsUsingBlock:^(Book *b, NSUInteger idx, BOOL *stop) {
			Book *book = [Book findFirstByAttribute:@"uid" withValue:b.uid inContext:localContext];
			if (!book) {
				book = [Book createInContext:localContext];
			}
			[book clone:b];
		}];
	} completion:^(BOOL success, NSError *error) {
		if (block) block();
	}];
}


- (void)clone:(Book *)book
{	
	self.author = book.author;
	self.authorID = book.authorID;
	self.autoBuy = book.autoBuy;
	self.bCover = book.bCover;
	self.bFav = book.bFav;
	self.bVip = book.bVip;
	self.bFinish = book.bFinish;
	self.category = book.category;
	self.categoryID = book.categoryID;
    self.comment = book.comment;
	self.commentPersons = book.commentPersons;
//	self.cover = book.cover;
	self.coverURL = book.coverURL;
	self.describe = book.describe;
	self.diamond = book.diamond;
	self.flower = book.flower;
	self.lastChapterName = book.lastChapterName;
//	self.lastReadChapterID = book.lastReadChapterID;
	self.lastUpdate = book.lastUpdate;
	self.monthTicket = book.monthTicket;
	self.name = book.name;
//	self.nextUpdateTime = book.nextUpdateTime;
	self.recommendID = book.recommendID;
	self.recommendTitle = book.recommendTitle;
	self.reward = book.reward;
	self.rewardPersons = book.rewardPersons;
	self.status = book.status;
	self.uid = book.uid;
//	self.updateDate = book.updateDate;
	self.words = book.words;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"(uid=%@, name=%@)", self.uid, self.name];
}

- (void)truncate
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		Book *book = [Book findFirstByAttribute:@"uid" withValue:self.uid inContext:localContext];
		if (book) {
			[book deleteInContext:localContext];
		}
	}];
}

+ (void)truncateAll
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		[Book truncateAllInContext:localContext];
	}];
}

@end
