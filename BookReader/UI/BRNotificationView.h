//
//  NotificationView.h
//  BookReader
//
//  Created by ZoomBin on 13-7-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "PSTCollectionView.h"

#define collectionHeaderViewIdentifier @"collection_header_view_identifier"

@protocol BRNotificationViewDelegate <NSObject>
- (void)closeButtonClicked;
- (void)startReadButtonClicked:(Book *)book;
@end

@interface BRNotificationView : PSUICollectionReusableView

@property (nonatomic, weak) id<BRNotificationViewDelegate> delegate;
@property (nonatomic, assign) BOOL bShouldLoad;

- (void)showInfoWithBook:(Book *)book andNotificateContent:(NSString *)content;

@end
