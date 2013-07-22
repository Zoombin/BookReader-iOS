//
//  Book.h
//  BookReader
//
//  Created by 颜超 on 13-6-21.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * authorID;
@property (nonatomic, retain) NSNumber * autoBuy;
@property (nonatomic, retain) NSNumber * bCover;
@property (nonatomic, retain) NSNumber * bFav;
@property (nonatomic, retain) NSString * bFinish;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSString * lastReadChapterID;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * monthTicket;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * nextUpdateTime;
@property (nonatomic, retain) NSNumber * recommendID;
@property (nonatomic, retain) NSString * recommendTitle;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSNumber * words;
@property (nonatomic, retain) NSString * lastChapterName;
@property (nonatomic, retain) NSNumber * bVip;
@property (nonatomic, retain) NSNumber * diamond;
@property (nonatomic, retain) NSNumber * comment;
@property (nonatomic, retain) NSNumber * commentPersons;
@property (nonatomic, retain) NSNumber * reward;
@property (nonatomic, retain) NSNumber * rewardPersons;
@property (nonatomic, retain) NSNumber * flower;

@end
