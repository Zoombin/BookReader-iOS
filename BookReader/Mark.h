//
//  Mark.h
//  BookReader
//
//  Created by zhangbin on 6/9/14.
//  Copyright (c) 2014 ZoomBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Mark : NSManagedObject

@property (nonatomic, retain) NSString * chapterID;
@property (nonatomic, retain) NSString * chapterName;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSString * reference;
@property (nonatomic, retain) NSNumber * startWordIndex;

@end
