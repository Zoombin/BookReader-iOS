//
//  Chapter+Setup.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "Chapter.h"

@class Book;
@interface Chapter (Setup)

+ (NSManagedObject *)createWithAttributes:(NSDictionary *)attributes;
+ (NSArray *)createWithAttributesArray:(NSArray *)array andExtra:(id)extraInfo;
- (void)persistWithBlock:(dispatch_block_t)block;
+ (void)persist:(NSArray *)array withBlock:(dispatch_block_t)block;
- (void)truncate;

+ (NSArray *)allChaptersOfBookID:(NSString *)bookID;
+ (NSUInteger)countOfUnreadChaptersOfBook:(Book *)book;
+ (Chapter *)firstChapterOfBook:(Book *)book;
- (Chapter *)previous;
- (Chapter *)next;
+ (NSArray *)chaptersNeedFetchContentWhenWifiReachable:(BOOL)bWifi;
+ (NSArray *)chaptersNeedSubscribe;

+ (NSString *)lastChapterIDOfBook:(Book *)book;
+ (Chapter *)lastReadChapterOfBook:(Book *)book;

- (NSString *)displayName:(NSArray *)allChapters;

@end
