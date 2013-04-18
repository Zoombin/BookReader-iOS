//
//  Book.h
//  BookReader
//
//  Created by 颜超 on 13-3-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject {
    NSString *author;
    NSString *authorID;
    NSString *name;
    NSString *uid;
    NSString *category;
    NSString *catagoryID;
    NSNumber *progress;
    UIImage *cover;
    NSString *coverURL;
    NSNumber *words;
    NSDate *lastUpdate;
    NSString *describe;
    NSString *recommandID;
    NSString *recommandTitle;
    BOOL autoBuy;
}
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *authorID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *catagoryID;
@property (nonatomic, strong) NSNumber *progress;
@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSNumber *words;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSString *describe;
@property (nonatomic, strong) NSString *recommandID;
@property (nonatomic, strong) NSString *recommandTitle;
@property (nonatomic, assign) BOOL autoBuy;


@end
