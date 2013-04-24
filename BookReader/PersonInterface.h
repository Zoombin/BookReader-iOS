//
//  PersonInterface.h
//  BookReader
//
//  Created by zhangbin on 4/24/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PersonInterface <NSObject>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

@end
