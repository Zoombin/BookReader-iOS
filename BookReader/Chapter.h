//
//  Chapter.h
//  BookReader
//
//  Created by zhangbin on 5/16/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSNumber * bBuy;
@property (nonatomic, retain) NSString * bid;
@property (nonatomic, retain) NSNumber * bRead;
@property (nonatomic, retain) NSNumber * bVip;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * lastReadIndex;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;

@end
