//
//  Member.h
//  BookReader
//
//  Created by 颜超 on 13-3-28.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Member : NSObject {
    NSNumber *coin;
    NSString *uid;
    NSString *name;
    NSArray  *history;
}
@property (nonatomic,strong) NSNumber *coin;
@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSArray *history;
@property (nonatomic,strong) NSString *name;

@end
