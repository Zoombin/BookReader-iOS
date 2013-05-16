//
//  Member.m
//  BookReader
//
//  Created by 颜超 on 13-4-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Member.h"


@implementation Member

@synthesize coin;
@synthesize uid;
@synthesize name;

+ (Member *)createWithAttributes:(NSDictionary *)attributes
{
    Member *member = [[Member alloc] init];
    member.uid = attributes[@"userid"];
    member.coin = attributes[@"account"];
    member.name = attributes[@"username"];
	return member;
}

@end
