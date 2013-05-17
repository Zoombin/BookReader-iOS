//
//  CoreTextViewController.h
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookReadMenuView.h"
#import "SubscribeViewController.h"

@class Book;
@class Chapter;
@interface CoreTextViewController : UIViewController<BookReadMenuViewDelegate,SubscribeViewDelegate>
- (id)initWithBook:(Book *)bookObj
           chapter:(Chapter *)chapterObj
     chaptersArray:(NSArray *)array
         andOnline:(BOOL)online;


@end
