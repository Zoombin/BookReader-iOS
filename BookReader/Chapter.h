//
//  NonManagedChapter.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol ChapterInterface<NSObject>

@property (nonatomic, retain) NSString * bid;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * bVip;
@property (nonatomic, retain) NSNumber * bRead;
@property (nonatomic, retain) NSNumber * bBuy;
@property (nonatomic, retain) NSNumber *index;

@end

@interface ManagedChapter : NSManagedObject<ChapterInterface>
@end

@interface Chapter : NSObject<ChapterInterface>

+ (id<ChapterInterface>)createChapterWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;

- (void)sync:(ManagedChapter *)managed;
- (void)persist;
+ (void)persist:(NSArray *)array;

+ (NSArray *)findAll;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm;



@end