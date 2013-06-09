//
//  CommentCell.h
//  BookReader
//
//  Created by 颜超 on 13-5-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;

@interface CommentCell : UITableViewCell

- (void)setComment:(Comment *)comment;
- (CGFloat)height;
@end
