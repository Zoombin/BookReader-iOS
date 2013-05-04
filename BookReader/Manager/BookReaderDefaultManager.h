//
//  BookReaderDefaultManager.h
//  BookReader
//
//  Created by 颜超 on 13-5-4.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserDefaultUserid   @"userid"

@interface BookReaderDefaultManager : NSObject
+ (void)saveUserid:(id)object;
+ (id)userid;
+ (void)deleteUserid;

+ (void)setObject:(id)object ForKey:(id)key;
+ (id)objectForKey:(id)key;
@end
