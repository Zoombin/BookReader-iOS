//
//  Member+Setup.m
//  BookReader
//
//  Created by 颜超 on 13-4-24.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Member+Setup.h"

@implementation Member (Setup)

+ (Member *)createWithAttributes:(NSDictionary *)attributes
{
    Member *member = [Member createEntity];
    member.uid = attributes[@"userid"];
    member.coin = attributes[@"account"];
    member.name = attributes[@"username"];
	return member;
}


@end