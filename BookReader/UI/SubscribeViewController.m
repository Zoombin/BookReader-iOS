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
#import <QuartzCore/QuartzCore.h>
#import "Book.h"

@implementation SubscribeViewController
{
    UITableView *infoTableView;
    NSMutableArray *infoArray;
	BOOL bBookmarks;
    UIButton *chapterlistBtn;
    UIButton *bookmarkBtn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self removeGestureRecognizer];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(4, 44, self.view.bounds.size.width-8, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView.layer setCornerRadius:5];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setDataSource:self];
    [self.view addSubview:infoTableView];
    
    CGRect CHAPTERS_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 110, 6, 48, 28);
    CGRect BOOKMARK_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 60, 6, 48, 28);
    NSArray *rectStrings = @[NSStringFromCGRect(CHAPTERS_BUTTON_FRAME), NSStringFromCGRect(BOOKMARK_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"chaptersButtonClicked", @"bookmarksButtonClicked"];
    
    #define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"chapterlist_btn"), UIIMAGE(@"bookmark_btn"), ];
    NSArray *disbleImages = @[UIIMAGE(@"chapterlist_btn_hl"), UIIMAGE(@"bookmark_btn_hl")];
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button setBackgroundImage:disbleImages[i] forState:UIControlStateDisabled];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        if (i==0) {
            chapterlistBtn =  button;
        } else {
            bookmarkBtn = button;
        }
    }
}

- (void)chaptersButtonClicked
{
    self.title = @"目录";
	bBookmarks = NO;
    [chapterlistBtn setEnabled:NO];
    [bookmarkBtn setEnabled:YES];
	infoArray = [[Chapter chaptersRelatedToBook:_book.uid] mutableCopy];
	[infoTableView reloadData];
}

- (void)bookmarksButtonClicked
{
    self.title = @"书签";
	bBookmarks = YES;
    [chapterlistBtn setEnabled:YES];
    [bookmarkBtn setEnabled:NO];
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
        if (bBookmarks) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyCell"];
            cell.textLabel.textColor = [UIColor blueColor];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
			Mark *mark = [infoArray objectAtIndex:indexPath.row];
            cell.textLabel.text = mark.reference;
			cell.detailTextLabel.textColor = [UIColor blackColor];
			cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
			cell.detailTextLabel.text = mark.chapterName;
			UILabel *progress = [[UILabel alloc] initWithFrame:cell.contentView.frame];
			progress.backgroundColor = [UIColor clearColor];
			progress.textAlignment = UITextAlignmentRight;
			progress.font = cell.detailTextLabel.font;
			progress.textColor = cell.detailTextLabel.textColor;
			progress.text = [NSString stringWithFormat:@"%.2f%%", mark.progress.floatValue];
			[cell.contentView addSubview:progress];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            cell.textLabel.text = @"";
            UILabel *chapterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, cell.contentView.frame.origin.y-3, cell.contentView.frame.size.width - 30, cell.contentView.frame.size.height-3)];
            [chapterNameLabel setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:chapterNameLabel];
            chapterNameLabel.textColor = [UIColor blueColor];
            
			Chapter *chapter = [infoArray objectAtIndex:indexPath.row];
            chapterNameLabel.text = [NSString stringWithFormat:@"(%d) %@", indexPath.row + 1, chapter.name];
			if (chapter.lastReadIndex == nil) {
				chapterNameLabel.textColor = [UIColor blackColor];
			}
            if (chapter.uid == _currentChapterID) {
                chapterNameLabel.textColor = [UIColor redColor];
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
