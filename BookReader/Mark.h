//
//  Mark.h
//  BookReader
//
//  Created by zhangbin on 8/2/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
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
