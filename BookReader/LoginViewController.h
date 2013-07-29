//
//  LoginViewController.h
//  BookReader
//
//  Created by 颜超 on 13-7-29.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginDelegate <NSObject>
@required
- (void)loginWithAccount:(NSString *)account andPassword:(NSString *)password;
@end

@interface LoginViewController : UIViewController

@property (nonatomic ,weak) id<LoginDelegate> delegate;
@end
