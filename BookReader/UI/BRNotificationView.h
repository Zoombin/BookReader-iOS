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
#import "BRNotification.h"

#define collectionHeaderViewIdentifier @"collection_header_view_identifier"

@protocol BRNotificationViewDelegate <NSObject>

- (void)willRead:(Book *)book;
- (void)willClose;

@end

@interface BRNotificationView : PSUICollectionReusableView

@property (nonatomic, weak) id<BRNotificationViewDelegate> delegate;
@property (nonatomic, strong) BRNotification *notification;

@end
