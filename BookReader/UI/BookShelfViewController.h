//
//  BookShelfViewController.h
//  BookReader
//
//  Created by ZoomBin on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BRViewController.h"
#import "BRNotificationView.h"
#import "PSTCollectionView.h"

@interface BookShelfViewController : BRViewController <PSUICollectionViewDataSource, PSUICollectionViewDelegate, PSUICollectionViewDelegateFlowLayout>

@end
