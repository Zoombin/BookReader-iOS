//
//  Chapter+Setup.m
//  BookReader
//
//  Created by 颜超 on 13-4-24.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Chapter+Setup.h"
#import "Chapter.h"

@implementation Chapter (Setup)

+ (Chapter *)createWithAttributes:(NSDictionary *)attributes 
{
    Chapter *chapter = [Chapter createEntity];
    chapter.name = attributes[@"chapterName"];
    chapter.uid = attributes[@"chapterId"];
    chapter.bVip = attributes[@"isVip"];
    chapter.bBuy = [NSNumber numberWithBool:NO];
	return chapter;
}

+ (NSArray *)chaptersWithAttributesArray:(NSArray *)array
                               andBookID:(NSString *)bookid
{
    NSArray *dataBaseArray = [Chapter findByAttribute:@"bid"
                                            withValue:bookid
                                           andOrderBy:@"index"
                                            ascending:YES];
    int i = 0;
    if ([dataBaseArray count]>0)
    {
        Chapter *obj = [dataBaseArray lastObject];
        i = [obj.index integerValue]+1;
    }
	NSMutableArray *chapters = [@[] mutableCopy];
	for (NSDictionary *attributes in array)
    {
		Chapter *chapter = [Chapter createWithAttributes:attributes];
        chapter.index = [NSNumber numberWithInteger:i];
        chapter.bid = bookid;
		[chapters addObject:chapter];
        i++;
	}
	return chapters;
}

@end