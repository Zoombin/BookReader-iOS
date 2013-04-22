//
//  Book.h
//  BookReader
//
//  Created by 颜超 on 13-4-20.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * authorID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSString * lastUpdate;
@property (nonatomic, retain) NSString * describe;
@property (nonatomic, retain) NSNumber * recommandID;
@property (nonatomic, retain) NSString * recommandTitle;
@property (nonatomic, retain) NSNumber * autoBuy;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSNumber * words;

@end
