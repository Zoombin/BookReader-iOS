//
//  BRNotification.m
//  BookReader
//
//  Created by zhangbin on 8/16/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRNotification.h"

#define NOTIFICATION_USER_DEFAULT_KEY @"br_notification_user_default_key"

@implementation BRNotification

- (BOOL)shouldDisplay
{
	NSString *content = [[NSUserDefaults standardUserDefaults] objectForKey:NOTIFICATION_USER_DEFAULT_KEY];
	if (!content) {
		return YES;
	}
	if ([content isEqualToString:[self displayedContent]]) {
		return NO;
	}
	return YES;
}

- (void)didRead
{
	[[NSUserDefaults standardUserDefaults] setObject:[self displayedContent] forKey:NOTIFICATION_USER_DEFAULT_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)displayedTitle
{
	if (self.books.count) {
		Book *book = _books[0];
		return book.name;
	}
	return nil;
}

- (NSString *)displayedContent
{
	if (_books.count) {
		Book *book = _books[0];
		return book.describe;
	}
	return _content;
}

- (BOOL)canRead
{
	return (BOOL)_books.count;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"displayedTitle: %@, displayedContent: %@", [self displayedTitle], [self displayedContent]];
}

@end
