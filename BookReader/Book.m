//
//  NonManagedBook.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Book.h"

#define XXSY_IMAGE_URL  @"http://images.xxsy.net/simg/"

@implementation ManagedBook
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

- (void)sync:(ManagedBook *)managedBook
{
	managedBook.name = name;
	managedBook.progress = progress;
	managedBook.uid = uid;
	managedBook.author = author;
	managedBook.authorID = authorID;
	managedBook.autoBuy = autoBuy;
	managedBook.cover = cover;
	managedBook.coverURL = coverURL;
	managedBook.category = category;
	managedBook.categoryID = categoryID;
	managedBook.words = words;
	managedBook.lastUpdate = lastUpdate;
	managedBook.describe = describe;
	managedBook.recommandID = recommandID;
	managedBook.recommandTitle = recommandTitle;
}

- (void)persist
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		ManagedBook *managedBook = [ManagedBook findFirstByAttribute:@"uid" withValue:uid inContext:localContext];
		if (!managedBook) {
			managedBook = [ManagedBook createInContext:localContext];
		}
		[self sync:managedBook];
		
	}];
}

+ (void)persist:(NSArray *)books
{
	[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
		for (Book *book in books) {
			ManagedBook *managedBook = [ManagedBook findFirstByAttribute:@"uid" withValue:book.uid inContext:localContext];
			if (!managedBook) {
				managedBook = [ManagedBook createInContext:localContext];
			}
			[book sync:managedBook];
		}
	}];
}
@end
