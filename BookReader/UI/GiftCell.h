//
//  GiftCell.h
//  BookReader
//
//  Created by ZoomBin on 13-4-28.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    GiftCellStyleDiamond = 0,
    GiftCellStyleFlower = 1,
    GiftCellStyleTicket = 2,
    GiftCellStyleComment = 3,
    GiftCellStyleMoney = 4,
} GiftCellStyle;

@protocol GiftCellDelegate <NSObject>
@required
- (void)sendButtonClick:(NSDictionary *)value;
@end

@interface GiftCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic ,weak) id<GiftCellDelegate> delegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath *)indexPath andStyle:(GiftCellStyle)cellStyle;
- (CGFloat)height;
@end
