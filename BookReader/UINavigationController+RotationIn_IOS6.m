//
//  UINavigationController+RotationIn_IOS6.m
//  BookReader
//
//  Created by zhangbin on 9/23/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "UINavigationController+RotationIn_IOS6.h"

@implementation UINavigationController (RotationIn_IOS6)

-(BOOL)shouldAutorotate
{
	return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
	return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return [[self.viewControllers lastObject]  preferredInterfaceOrientationForPresentation];
}

@end
