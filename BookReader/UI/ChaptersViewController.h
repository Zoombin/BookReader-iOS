//
//  ChaptersViewController.h
//  BookReader
//
//  Created by ZoomBin on 13-4-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"
#import "Chapter.h"
#import "Book.h"
#import "Mark.h"

@protocol ChapterViewDelegate <NSObject>

- (void)didSelect:(id)selected;

@end

@interface ChaptersViewController : BRViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ChapterViewDelegate> delegate;
@property (nonatomic, strong) Chapter *chapter;

@end
