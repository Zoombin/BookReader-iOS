//
//  NavViewController.m
//  MyTest
//
//  Created by 颜超 on 13-7-1.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "NavViewController.h"

@interface NavViewController ()

@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;

@end

@implementation NavViewController
@synthesize interfaceOrientationMask= _interfaceOrientationMask;

- (void)changeSupportedInterfaceOrientations:(UIInterfaceOrientationMask)interfaceOrientation{
    
    _interfaceOrientationMask = interfaceOrientation;
}

-(BOOL)shouldAutorotate{
    
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    
    return _interfaceOrientationMask;
}

@end
