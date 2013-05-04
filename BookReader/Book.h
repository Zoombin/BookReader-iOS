//
//  Book.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol BookInterface <NSObject>

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * authorID;
@property (nonatomic, retain) NSNumber * autoBuy;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSNumber * recommandID;
@property (nonatomic, retain) NSString * recommandTitle;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * words;

@end


@interface BookManaged : NSManagedObject <BookInterface>
@end



@interface Book : NSObject<BookInterface>

+ (Book *)createBookWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)booksWithAttributesArray:(NSArray *)array;

- (void)sync:(BookManaged *)managed;
- (void)persist;
- (BOOL)persisted;//check if exists in database already
+ (void)persist:(NSArray *)books;

- (NSNumber *)numberOfUnreadChapters;
+ (NSArray *)findAll;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm;



@end


