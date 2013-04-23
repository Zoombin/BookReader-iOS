//
//  Book+Setup.m
//  BookReader
//
//  Created by zhangbin on 4/23/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Book+Setup.h"
#import "Book.h"

#define XXSY_IMAGE_URL  @"http://images.xxsy.net/simg/"

@implementation Book (Setup)

+ (Book *)createWithAttributes:(NSDictionary *)attributes
{
	Book *book = [Book createEntity];
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
		book.uid = attributes[@"bookId"];
	} else if (attributes[@"bookid"]) {
		book.uid = attributes[@"bookid"];
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
		Book *book = [Book createWithAttributes:attributes];
		[books addObject:book];
	}
	return books;
}

@end
