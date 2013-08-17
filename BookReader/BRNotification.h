//
//  BRNotification.h
//  BookReader
//
//  Created by zhangbin on 8/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRNotification : NSObject

@property (nonatomic, strong) NSArray *books;
@property (nonatomic, strong) NSString *content;

- (BOOL)shouldDisplay;
- (void)didRead;
- (NSString *)displayedTitle;
- (NSString *)displayedContent;
- (BOOL)canRead;

@end
