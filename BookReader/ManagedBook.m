//
//  ManagedBook.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ManagedBook.h"

#define XXSY_IMAGE_URL  @"http://images.xxsy.net/simg/"
@implementation ManagedBook
@dynamic uid,author,authorID,autoBuy,category,categoryID,cover,coverURL,describe,lastUpdate,name,progress,recommandID,recommandTitle,words;

+ (id<BookInterface>)createBookWithAttributes:(NSDictionary *)attributes
{
    ManagedBook *book = [ManagedBook createEntity];
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

+ (id<BookInterface>)createBookWithNonManagedBook:(id<BookInterface>)nonManagedBook
{
    ManagedBook *book = [ManagedBook createEntity];
    book.name = nonManagedBook.name;
    book.progress = nonManagedBook.progress;
    book.uid = nonManagedBook.uid;
    book.author = nonManagedBook.author;
    book.authorID = nonManagedBook.authorID;
    book.autoBuy = nonManagedBook.autoBuy;
    book.cover = nonManagedBook.cover;
    book.coverURL = nonManagedBook.coverURL;
    book.category = nonManagedBook.category;
    book.categoryID =nonManagedBook.categoryID;
    book.words = nonManagedBook.words;
    book.lastUpdate = nonManagedBook.lastUpdate;
    book.describe = nonManagedBook.describe;
    book.recommandID = nonManagedBook.recommandID;
    book.recommandTitle = nonManagedBook.recommandTitle;
    return book;
}

+ (NSArray *)booksWithAttributesArray:(NSArray *)array
{
   	NSMutableArray *books = [@[] mutableCopy];
	for (NSDictionary *attributes in array) {
		ManagedBook *book = [self createBookWithAttributes:attributes];
		[books addObject:book];
	}
	return books;
}

@end
