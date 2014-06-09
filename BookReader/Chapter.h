//
//  Chapter.h
//  BookReader
//
//  Created by zhangbin on 6/9/14.
//  Copyright (c) 2014 ZoomBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSString * bid;
@property (nonatomic, retain) NSNumber * bVip;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * hadBought;
@property (nonatomic, retain) NSNumber * lastReadIndex;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nextID;
@property (nonatomic, retain) NSString * previousID;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * rollID;
@property (nonatomic, retain) NSString * uid;

@end
