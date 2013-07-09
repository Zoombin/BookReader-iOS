//
//  BookMarkCell.h
//  BookReader
//
//  Created by 颜超 on 13-7-9.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mark.h"

@interface BookMarkCell : UITableViewCell {
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)height;
- (void)setMark:(Mark *)mark;
@end