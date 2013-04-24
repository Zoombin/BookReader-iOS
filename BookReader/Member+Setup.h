//
//  Member+Setup.h
//  BookReader
//
//  Created by 颜超 on 13-4-24.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "Member.h"

@interface Member (Setup)
+ (Member *)createWithAttributes:(NSDictionary *)attributes;
@end