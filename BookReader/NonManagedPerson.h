//
//  NonManagedPerson.h
//  BookReader
//
//  Created by zhangbin on 4/24/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonInterface.h"

@interface NonManagedPerson : NSObject <PersonInterface>

+ (id<PersonInterface>)createPerson;

@end
