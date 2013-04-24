//
//  ManagedPerson.m
//  BookReader
//
//  Created by zhangbin on 4/24/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import "ManagedPerson.h"

@implementation ManagedPerson

@dynamic firstName, lastName;

+ (id<PersonInterface>)createPerson
{
	ManagedPerson *person = [ManagedPerson createEntity];
	person.firstName = @"abc";
	person.lastName = @"efg";
	return person;
}

+ (id<PersonInterface>)createPersonWithNonManagedPerson:(id<PersonInterface>)nonManagedPerson
{
	ManagedPerson *person = [ManagedPerson createEntity];
	person.firstName = nonManagedPerson.firstName;
	person.lastName = nonManagedPerson.lastName;
	return person;
}

@end
