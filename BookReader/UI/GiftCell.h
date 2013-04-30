//
//  GiftCell.h
//  BookReader
//
//  Created by 颜超 on 13-4-28.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GiftCellDelegate <NSObject>
@required
- (void)sendButtonClick:(NSDictionary *)value;
@end

@interface GiftCell : UITableViewCell
@property (nonatomic ,weak) id<GiftCellDelegate> delegate;
- (void)setValue:(NSString *)value;
@end
