//
//  SubscribeViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "SubscribeViewController.h"
#import "ServiceManager.h"
#import "Chapter.h"
#import "Mark.h"
#import "Book.h"
#import "UIViewController+HUD.h"
#import "BookReaderDefaultsManager.h"
#import "CoreTextViewController.h"
#import "UIColor+BookReader.h"
#import "UILabel+BookReader.h"
#import "Chapter+Setup.h"
#import "UIButton+BookReader.h"
#import "Book.h"

@implementation SubscribeViewController
{
    UITableView *infoTableView;
    NSMutableArray *infoArray;
	BOOL bBookmarks;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self removeGestureRecognizer];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setDataSource:self];
    [self.view addSubview:infoTableView];
    
    CGRect CHAPTERS_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 110, 4, 48, 32);
    CGRect BOOKMARK_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 60, 4, 48, 32);
    NSArray *titles = @[@"目录", @"书签"];
    NSArray *rectStrings = @[NSStringFromCGRect(CHAPTERS_BUTTON_FRAME), NSStringFromCGRect(BOOKMARK_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"chaptersButtonClicked", @"bookmarksButtonClicked"];
    
#define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"universal_btn"), UIIMAGE(@"universal_btn"), ];
    NSArray *highlightedImages = @[UIIMAGE(@"universal_btn_hl"), UIIMAGE(@"universal_btn_hl")];
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImages[i] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)chaptersButtonClicked
{
    self.title = @"目录";
	bBookmarks = NO;
	infoArray = [[Chapter chaptersRelatedToBook:_book.uid] mutableCopy];
	[infoTableView reloadData];
}

- (void)bookmarksButtonClicked
{
    self.title = @"书签";
	bBookmarks = YES;
	NSArray *chapters = [Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@", _book.uid]];
	NSMutableArray *marks = [NSMutableArray array];
	for (Chapter *chapter in chapters) {
		NSArray *mks = [Mark findAllWithPredicate:[NSPredicate predicateWithFormat:@"chapterID = %@", chapter.uid]];
		if (mks) {
			[marks addObjectsFromArray:mks];
		}
	}
	infoArray = marks;
	[infoTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self chaptersButtonClicked];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
		[cell.textLabel setFont:[UIFont systemFontOfSize:16]];
		cell.textLabel.textColor = [UIColor blueColor];
        if (bBookmarks) {
			Mark *mark = [infoArray objectAtIndex:indexPath.row];
            cell.textLabel.text = mark.reference;
        } else {
			Chapter *chapter = [infoArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [NSString stringWithFormat:@"(%d) %@", indexPath.row + 1, chapter.name];
			if (chapter.lastReadIndex == nil) {
				cell.textLabel.textColor = [UIColor blackColor];
			}
            cell.detailTextLabel.textColor = [UIColor redColor];
            cell.detailTextLabel.text = [chapter.bVip boolValue] ? @"v" : @"";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.navigationController popViewControllerAnimated:YES];
	[_delegate didSelect:infoArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Mark *mark = infoArray[indexPath.row];
			[mark deleteEntity];
			[infoArray removeObjectAtIndex:indexPath.row];
			[infoTableView reloadData];
		}];
	}
}

@end
