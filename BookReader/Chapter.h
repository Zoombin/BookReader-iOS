//
//  Chapter.h
//  BookReader
//
//  Created by 颜超 on 13-4-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@protocol ModelDelegate <NSObject>

- (void)persistWithBlock:(dispatch_block_t)block;
+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block;

- (void)truncate;
+ (void)truncateAll;

+ (NSArray *)findAll;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)searchTerm;

@end

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

@interface ChapterManaged : NSManagedObject<ChapterInterface>
@end

@interface Chapter : NSObject<ChapterInterface, ModelDelegate>

+ (Chapter *)createChapterWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array andBookID:(NSString *)bookid;

+ (NSArray *)chaptersWithBookID:(NSString *)bookid;

@end