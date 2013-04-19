//
//  ReadStatusView.h
//  iReader
//
//  Created by Archer on 12-1-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadStatusView : UIView {
    UILabel *title;
    UILabel *percentage;
    UIScrollView *booknameScroll;
}

@property (nonatomic, strong)UILabel *title;
@property (nonatomic, strong)UILabel *percentage;
@property (nonatomic, strong)UIScrollView *booknameScroll;
@end


