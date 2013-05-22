//
//  Book+Test.m
//  BookReader
//
//  Created by zhangbin on 3/27/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "Book+Test.h"

@implementation Book (Test)


//+ (NSArray *)testBooks
//{
//    NSMutableArray *books = [@[] mutableCopy];
//    NSArray *names = @[@"到古代做女皇", @"邪瞳", @"亲亲鬼老公", @"妖孽向善"];
//    NSArray *authors = @[@"张三", @"李四", @"王五", @"周六"];
//    NSArray *categorys = @[@"言情", @"短篇", @"玄幻", @"武侠"];
//    NSArray *progresses = @[@(0.9), @(0.8), @(0.7), @(0.6)];
//    NSArray *wordsArray = @[@(5000), @(6000), @(3200), @(1700)];
//    NSArray *lastupdates = @[[NSDate date],[NSDate date],[NSDate date],[NSDate date]];
//    NSString *shortdescribes = @"《三国演义》全名《三国志通俗演义》，元末明初小说家罗贯中所著，为中国第一部长篇章回体历史演义的小说，中国古典四大名著之一，历史演义小说的经典之作。";
//    NSAssert(names.count == authors.count, @"names.count can't match authors.cout...");
//    for (int i = 0; i < names.count; i++) {
//        Book *book = [[Book alloc] init];
//        book.uid = [NSString stringWithFormat:@"%d", i+1];
//        book.name = names[i];
//        book.author = authors[i];
//        book.category = categorys[i];
//        book.progress = progresses[i];
//        book.words = wordsArray[i];
//        book.lastUpdate = lastupdates[i];
//        book.describe = shortdescribes;
//        [books addObject:book];
//    }
//    return books;
//}
//
//+ (NSArray *)pop:(NSInteger)number
//{
//    NSInteger count = [self testBooks].count;
//    return ( number > count ? nil : [[self testBooks] subarrayWithRange:NSMakeRange(0, number)] );
//}
//
//+ (NSArray *)testRankingBooks
//{
//    return [self pop:2];
//}
//
//+ (NSArray *)testRecommendBooks
//{
//    return [self pop:3];
//}
//
//+ (NSArray *)testReachBooks
//{
//    return [self pop:1];
//}

@end
