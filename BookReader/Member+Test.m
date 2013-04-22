//
//  Member+Test.m
//  BookReader
//
//  Created by 颜超 on 13-3-28.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Member+Test.h"

@implementation Member (Test)

+(Member *)testMember {
    Member *member = [[Member alloc] init];
    member.uid = [NSNumber numberWithInteger:12345];
    member.coin = [NSNumber numberWithInt:99999];
    return member;
}
@end
