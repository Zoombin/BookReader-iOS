//
//  Member.m
//  BookReader
//
//  Created by ZoomBin on 13-4-22.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BRUser.h"


@implementation BRUser

@synthesize coin;
@synthesize uid;
@synthesize name;

+ (BRUser *)createWithAttributes:(NSDictionary *)attributes
{
    BRUser *member = [[BRUser alloc] init];
    member.uid = attributes[@"userid"];
    member.coin = attributes[@"account"];
    member.name = attributes[@"username"];
	return member;
}

@end
