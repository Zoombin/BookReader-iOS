//
//  Book.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chapter.h"

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
@property (nonatomic, retain) NSDate *rDate; //上次阅读时间
@property (nonatomic, retain) NSNumber *lastReadChapterIndex; //上次阅读章节的index
@property (nonatomic, retain) NSNumber *bFav;
@property (nonatomic, retain) NSNumber *bHistory;
@property (nonatomic, retain) NSNumber *lastReadIndex;

@end


@interface BookManaged : NSManagedObject <BookInterface>
@end



@interface Book : NSObject<BookInterface, ModelDelegate>

+ (Book *)createBookWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)booksWithAttributesArray:(NSArray *)array;
+ (NSArray *)booksWithAttributesArray:(NSArray *)array andFav:(BOOL)fav;

- (void)persistWithBlock:(dispatch_block_t)block;
- (BOOL)persisted;//check if exists in database already
- (NSNumber *)numberOfUnreadChapters;
+ (NSArray *)findAllAndSortedByDate;

@end


