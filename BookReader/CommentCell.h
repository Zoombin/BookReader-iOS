//
//  CommentCell.h
//  BookReader
//
//  Created by ZoomBin on 13-5-22.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BRComment;

@interface CommentCell : UITableViewCell

- (void)setComment:(BRComment *)comment;
- (CGFloat)height;

@end
