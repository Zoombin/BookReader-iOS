//
//  BookShelfBottomView.h
//  BookReader
//
//  Created by 颜超 on 13-4-18.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kBottomViewButtonDelete,
    kBottomViewButtonEdit,
    kBottomViewButtonFinishEditing,
    kBottomViewButtonRefresh,
    kBottomViewButtonShelf,
    kBottomViewButtonBookHistoroy,
}BottomViewButtonType;

@protocol BookShelfBottomViewDelegate <NSObject>
- (void)bottomButtonClicked:(NSNumber *)type;
@end
@interface BookShelfBottomView : UIView
{
    UIView *bottomViewOne;
    UIView *bottomViewTwo;
}
@property (nonatomic, weak) id<BookShelfBottomViewDelegate> delegate;
@end
