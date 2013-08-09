//
//  CommentView.h
//  BookReader
//
//  Created by 颜超 on 13-8-7.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentDelegate <NSObject>
@optional
- (void)sendButtonClicked;
@end

@interface CommentView : UIAlertView {
    
}
@property(readwrite, strong) UITextField *textField;
@property(nonatomic, weak) id CommentDelegate;
- (id)init;
@end
