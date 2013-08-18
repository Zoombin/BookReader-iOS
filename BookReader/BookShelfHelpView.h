//
//  BookShelfHelpView.h
//  BookReader
//
//  Created by zhangbin on 8/18/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookShelfHelpViewDelegate <NSObject>

- (void)willAppearSecondHelpView;
- (void)willDismiss;

@end

@interface BookShelfHelpView : UIView

@property (nonatomic, weak) id<BookShelfHelpViewDelegate>delegate;

@end
