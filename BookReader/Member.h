//
//  Member.h
//  BookReader
//
//  Created by 颜超 on 13-4-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Member : NSManagedObject

@property (nonatomic, retain) NSNumber * coin;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * name;

@end
