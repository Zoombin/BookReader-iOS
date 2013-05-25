//
//  Mark.h
//  BookReader
//
//  Created by zhangbin on 5/25/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Mark : NSManagedObject

@property (nonatomic, retain) NSString * chapterID;
@property (nonatomic, retain) NSNumber * startWordIndex;
@property (nonatomic, retain) NSString * reference;

@end
