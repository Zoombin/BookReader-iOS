//
//  CoreTextViewController.h
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookReadMenuView.h"
#import "NonManagedChapter.h"
#import "Book.h"
#import "BookInterface.h"

@interface CoreTextViewController : UIViewController<BookReadMenuViewDelegate>
{
    BOOL bFlipV;
    NSInteger startPointX;
    NSInteger startPointY;
}
- (id)initWithBook:(id<BookInterface>)bookObj andChapter:(id<ChapterInterface>)chapterObj;
@end
