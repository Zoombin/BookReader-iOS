//
//  Member.h
//  BookReader
//
//  Created by 颜超 on 13-4-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Member : NSObject

@property (nonatomic, strong) NSNumber * coin;
@property (nonatomic, strong) NSNumber * uid;
@property (nonatomic, strong) NSString * name;

+ (Member *)createWithAttributes:(NSDictionary *)attributes;

@end
