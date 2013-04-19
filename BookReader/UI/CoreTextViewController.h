//
//  CoreTextViewController.h
//  BookReader
//
//  Created by zhangbin on 4/12/13.
//  Copyright (c) 2013 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookReadMenuView.h"
#import "Chapter.h"
#import "Book.h"

@interface CoreTextViewController : UIViewController<ReadMenuViewDelegate>
{
    BOOL bFlipV;
    NSInteger startPointX;
    NSInteger startPointY;
}
- (id)initWithBook:(Book *)bookObj andChapter:(Chapter *)chapterObj;
@end
