//
//  NotificationView.h
//  BookReader
//
//  Created by ZoomBin on 13-7-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"


@protocol NotificationViewDelegate <NSObject>
- (void)closeButtonClicked;
- (void)startReadButtonClicked:(Book *)book;
@end

@interface NotificationView : UIView {
    
}
@property (nonatomic, weak) id<NotificationViewDelegate> delegate;
@property (nonatomic, assign) BOOL bShouldLoad;
- (void)showInfoWithBook:(Book *)book
    andNotificateContent:(NSString *)content;
@end
