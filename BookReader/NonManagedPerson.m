//
//  NonManagedPerson.m
//  BookReader
//
//  Created by zhangbin on 4/24/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "NonManagedPerson.h"

@implementation NonManagedPerson

@synthesize firstName, lastName;

+ (id<PersonInterface>)createPerson
{
	NonManagedPerson *person = [[NonManagedPerson alloc] init];
	person.firstName = @"123";
	person.lastName = @"456";
	return person;
}

@end
