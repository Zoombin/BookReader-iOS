//
//  Book.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * authorID;
@property (nonatomic, retain) NSNumber * autoBuy;
@property (nonatomic, retain) NSNumber * bFav;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSString * lastReadChapterID;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * rDate;
@property (nonatomic, retain) NSNumber * recommendID;
@property (nonatomic, retain) NSString * recommendTitle;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * words;

@end
