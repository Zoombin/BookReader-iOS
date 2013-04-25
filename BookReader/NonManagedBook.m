//
//  NonManagedBook.m
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "NonManagedBook.h"

#define XXSY_IMAGE_URL  @"http://images.xxsy.net/simg/"
@implementation NonManagedBook

@synthesize uid,author,authorID,autoBuy,category,categoryID,cover,coverURL,describe,lastUpdate,name,progress,recommandID,recommandTitle,words;

+ (id<BookInterface>)createBookWithAttributes:(NSDictionary *)attributes
{
    NonManagedBook *book = [[NonManagedBook alloc] init];
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
		NonManagedBook *book = [self createBookWithAttributes:attributes];
		[books addObject:book];
	}
	return books;
}
@end
