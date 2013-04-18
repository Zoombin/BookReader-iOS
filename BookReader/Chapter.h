//
//  Chapter.h
//  BookReader
//
//  Created by 颜超 on 13-4-15.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chapter : NSObject {
    NSString *bookID;
    NSString *uid;
    NSString *name;
    BOOL bVip;
    BOOL bRead;
    BOOL bBuy;
}
@property (nonatomic, strong) NSString *bookID;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL bVip;
@property (nonatomic, assign) BOOL bRead;
@property (nonatomic, assign) BOOL bBuy;
@end
