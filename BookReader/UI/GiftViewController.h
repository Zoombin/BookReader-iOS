//
//  GiftViewController.h
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NonManagedBook.h"

@interface GiftViewController : UIViewController
- (id)initWithIndex:(NSString *)index andBookObj:(id<BookInterface>)bookObject;
@end
