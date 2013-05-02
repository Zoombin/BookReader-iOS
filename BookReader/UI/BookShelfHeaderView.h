//
//  HeaderView.h
//  BookReader
//
//  Created by 颜超 on 13-3-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kHeaderViewButtonDelete,
    kHeaderViewButtonEdit,
    kHeaderViewButtonFinishEditing,
    kHeaderViewButtonBookStore,
    kHeaderViewButtonMember
}HeaderViewButtonType;

@protocol BookShelfHeaderViewDelegate <NSObject>
- (void)headerButtonClicked:(NSNumber *)type;
@end

@interface BookShelfHeaderView : UIView {
    UIView *headerViewOne;
    UIView *headerViewTwo;
}
@property (nonatomic, weak) id<BookShelfHeaderViewDelegate> delegate;
@property (nonatomic, strong) UILabel *titleLabel;
@end


