//
//  ReMyAccountViewController.h
//  BookReader
//
//  Created by 颜超 on 13-3-23.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRViewController.h"
#import "iVersion.h"
#import "BRUser.h"

@interface MemberViewController: BRViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, iVersionDelegate>

@property (nonatomic ,strong) BRUser *userinfo;
@property (nonatomic ,assign) BOOL bReg;
@end
