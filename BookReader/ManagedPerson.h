//
//  ManagedPerson.h
//  BookReader
//
//  Created by zhangbin on 4/24/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PersonInterface.h"

@interface ManagedPerson : NSManagedObject <PersonInterface>

+ (id<PersonInterface>)createPerson;

+ (id<PersonInterface>)createPersonWithNonManagedPerson:(id<PersonInterface>)nonManagedPerson;

@end
