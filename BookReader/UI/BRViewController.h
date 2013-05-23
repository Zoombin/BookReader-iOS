//
//  BRViewController.h
//  BookReader
//
//  Created by 颜超 on 13-5-23.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRViewController : UIViewController

@property (nonatomic, assign) BOOL hideBackBtn;
@property (nonatomic, strong) NSArray *keyboardUsers;


- (void)hideKeyboard;
- (void)removeGestureRecognizer;


@end
