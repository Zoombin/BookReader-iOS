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
#import "BookMarkCell.h"

@implementation ChaptersViewController
{
    UITableView *infoTableView;
    NSMutableArray *infoArray;
	BOOL bBookmarks;
    UIButton *chapterlistBtn;
    UIButton *bookmarkBtn;
    UISlider *slider;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self removeGestureRecognizer];
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(4, 38, self.view.bounds.size.width-8, self.view.bounds.size.height-38-35) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView.layer setCornerRadius:5];
    [infoTableView setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:248.0/255.0 blue:245.0/255.0 alpha:1.0]];
    [infoTableView.layer setMasksToBounds:YES];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [infoTableView setDataSource:self];
    [self.view addSubview:infoTableView];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 260, self.view.bounds.size.height - 150, 20)];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [slider setMinimumTrackTintColor:[UIColor clearColor]];
    [slider setMaximumTrackTintColor:[UIColor clearColor]];
    [slider.layer setBorderColor:[UIColor clearColor].CGColor];
    [slider setMinimumValue:0];
    [slider setMaximumValue:100];
    [self.view addSubview:slider];
    
    for (int i = 0; i < [slider.subviews count]; i++) {
        if (i != 2) {
            UIView *view = slider.subviews[i];
            view.hidden = YES;
        }
    }
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI * (-1.5));
	[slider setTransform:rotation];
    
    CGRect CHAPTERS_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 90*2 , CGRectGetMaxY(infoTableView.frame) - 3, 85, 36);
    CGRect BOOKMARK_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 90, CGRectGetMaxY(infoTableView.frame) - 3, 85, 36);
    NSArray *rectStrings = @[NSStringFromCGRect(CHAPTERS_BUTTON_FRAME), NSStringFromCGRect(BOOKMARK_BUTTON_FRAME)];
    NSArray *selectorStrings = @[@"chaptersButtonClicked", @"bookmarksButtonClicked"];
    
#define UIIMAGE(x) [UIImage imageNamed:x]
    NSArray *images = @[UIIMAGE(@"chapterlist_btn"), UIIMAGE(@"bookmark_btn"), ];
    NSArray *disbleImages = @[UIIMAGE(@"chapterlist_btn_hl"), UIIMAGE(@"bookmark_btn_hl")];
    
    for (int i = 0; i < 2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:disbleImages[i] forState:UIControlStateNormal];
        [button setFrame: CGRectFromString(rectStrings[i])];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
        [button setBackgroundImage:images[i] forState:UIControlStateDisabled];
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
    slider.hidden = NO;
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
    slider.hidden = YES;
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
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        if (bBookmarks) {
            cell = [[BookMarkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyCell"];
            cell.textLabel.textColor = [UIColor blueColor];
            [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
			Mark *mark = [infoArray objectAtIndex:indexPath.row];
            [(BookMarkCell *)cell setMark:mark];
        } else {
            cell = [[ChapterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
			Chapter *chapter = [infoArray objectAtIndex:indexPath.row];
            
//            cell.detailTextLabel.text = chapter.bVip.boolValue ? @"v" : @"";
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

- (void)sliderValueChanged:(id)sender {
    if (bBookmarks) {
        return;
    }
	float offsetY = (slider.value / 100.0) * (infoTableView.contentSize.height - 460);
	[infoTableView setContentOffset:CGPointMake(0, offsetY)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (bBookmarks) {
        return;
    }
	[infoTableView setContentOffset:CGPointMake(0, infoTableView.contentOffset.y)];
	slider.value = 100.0 * infoTableView.contentOffset.y / (infoTableView.contentSize.height - 460);
}

@end
