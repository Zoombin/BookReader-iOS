//
//  Book.h
//  BookReader
//
//  Created by zhangbin on 6/9/14.
//  Copyright (c) 2014 ZoomBin. All rights reserved.
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
@property (nonatomic, retain) NSNumber * bVip;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSNumber * comment;
@property (nonatomic, retain) NSNumber * commentPersons;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSNumber * diamond;
@property (nonatomic, retain) NSNumber * flower;
@property (nonatomic, retain) NSString * lastChapterName;
@property (nonatomic, retain) NSString * lastReadChapterID;
@property (nonatomic, retain) NSDate * lastReadDate;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSDate * localUpdateDate;
@property (nonatomic, retain) NSNumber * monthTicket;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * nextUpdateTime;
@property (nonatomic, retain) NSNumber * numberOfUnreadChapters;
@property (nonatomic, retain) NSNumber * recommendID;
@property (nonatomic, retain) NSString * recommendTitle;
@property (nonatomic, retain) NSNumber * reward;
@property (nonatomic, retain) NSNumber * rewardPersons;
@property (nonatomic, retain) NSString * shelfCategoryName;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSNumber * words;

@end
