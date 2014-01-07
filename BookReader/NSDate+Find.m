//
//  NSDate+Find.m
//  BookReader
//
//  Created by zhangbin on 12/15/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "NSDate+Find.h"

@implementation NSDate (Find)

+ (BOOL)reachThatDay
{
	NSString *stringDate = @"1/19/2014";//TODO
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSDate *dateCheck = [dateFormatter dateFromString:stringDate];
	NSDate *now = [NSDate date];
	//if (dateCheck == [now laterDate:dateCheck])
	//	return NO;
	return YES;
}

@end
