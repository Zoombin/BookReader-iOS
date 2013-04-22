//
//  Chapter.h
//  BookReader
//
//  Created by 颜超 on 13-4-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSNumber * bookID;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * bVip;
@property (nonatomic, retain) NSNumber * bRead;
@property (nonatomic, retain) NSNumber * bBuy;

@end
