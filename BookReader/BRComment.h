//
//  Commit.h
//  BookReader
//
//  Created by ZoomBin on 13-4-16.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRComment : NSObject {
    NSString *bookID;
    NSString *content;
    NSString *commentID;
    NSString *uid;
    NSString *userName;
    NSString *insertTime;
}
@property (nonatomic, strong) NSString *bookID;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *insertTime;
@end
