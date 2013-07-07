//
//  ChaptersViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ChaptersViewController.h"
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
#import "ChapterCell.h"

@implementation ChaptersViewController
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
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width-8, self.view.bounds.size.height-38-50)];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [imageView setImage:[UIImage imageNamed:@"chapter_background"]];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(4, 38, self.view.bounds.size.width-8, self.view.bounds.size.height-38-50) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView.layer setCornerRadius:5];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setBackgroundView:imageView];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [infoTableView setDataSource:self];
    [self.view addSubview:infoTableView];
    
    CGRect CHAPTERS_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 85*2 , CGRectGetMaxY(infoTableView.frame), 85, 36);
    CGRect BOOKMARK_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 85, CGRectGetMaxY(infoTableView.frame), 85, 36);
    NSArray *rectStrings = @[NSStringFromCGRect(CHAPTERS_BUTTON_FRAME), NSStringFromCGRect(BOOKMARK_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"chaptersButtonClicked", @"bookmarksButtonClicked"];
    
#define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"chapterlist_btn"), UIIMAGE(@"bookmark_btn"), ];
    NSArray *disbleImages = @[UIIMAGE(@"chapterlist_btn_hl"), UIIMAGE(@"bookmark_btn_hl")];
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:images[i] forState:UIControlStateNormal];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [button setBackgroundImage:disbleImages[i] forState:UIControlStateDisabled];
        [button addTarget:self action:NSSelectorFromString(selectorStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        if (i==0) {
            chapterlistBtn =  button;
        } else {
            bookmarkBtn = button;
        }
    }
    [[self backgroundImage] removeFromSuperview];
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
    if (!bBookmarks) {
    ChapterCell *cell = (ChapterCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell height];
    }
    return 30;
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
            
            UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(10,  cell.contentView.frame.size.height-1, cell.contentView.frame.size.width - 30, 1)];
            [separateLine setBackgroundColor:[UIColor lightGrayColor]];
            [cell.contentView addSubview:separateLine];
        } else {
            cell = [[ChapterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
			Chapter *chapter = [infoArray objectAtIndex:indexPath.row];
            [(ChapterCell *)cell  setChapter:chapter andCurrent:[chapter.uid isEqualToString:_currentChapterID]];
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
