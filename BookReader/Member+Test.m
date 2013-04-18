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
    member.uid = @"ycabc1989";
    member.coin = [NSNumber numberWithInt:99999];
    member.history = @[@"2013-3-23 6￥",@"2013-3-24 12￥",@"2013-3-27 18￥",@"2013-3-30 12￥",@"2013-3-31 18￥",@"2013-4-1 12￥"];
    return member;
}
@end
