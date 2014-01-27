//
//  ChaptersViewController.m
//  BookReader
//
//  Created by ZoomBin on 13-4-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "ChaptersViewController.h"
#import "ServiceManager.h"
#import "Mark.h"
#import "UIViewController+HUD.h"
#import "CoreTextViewController.h"
#import "UIButton+BookReader.h"
#import "UIButton+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "ChapterCell.h"
#import "BookMarkCell.h"

@interface ChaptersViewController ()

@property (readwrite) UITableView *infoTableView;
@property (readwrite) NSMutableArray *infoArray;
@property (readwrite) BOOL bBookmarks;
@property (readwrite) UIButton *chapterlistBtn;
@property (readwrite) UIButton *bookmarkBtn;
@property (readwrite) UISlider *slider;

@end

@implementation ChaptersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.hideKeyboardRecognzier.enabled = NO;
    
    _infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(4, 38, self.view.bounds.size.width - 8, self.view.bounds.size.height - 38 - 30) style:UITableViewStylePlain];
    [_infoTableView setDelegate:self];
    [_infoTableView.layer setCornerRadius:5];
    [_infoTableView setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:248.0/255.0 blue:245.0/255.0 alpha:1.0]];
    [_infoTableView.layer setMasksToBounds:YES];
    [_infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_infoTableView setDataSource:self];
    [self.view addSubview:_infoTableView];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 260, self.view.bounds.size.height - 150, 20)];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_slider setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [_slider setThumbImage:[UIImage imageNamed:@"thumb_image"] forState:UIControlStateNormal];
    [_slider setMinimumTrackTintColor:[UIColor clearColor]];
    [_slider setMaximumTrackTintColor:[UIColor clearColor]];
    [_slider.layer setBorderColor:[UIColor clearColor].CGColor];
    [_slider setMinimumValue:0];
    [_slider setMaximumValue:100];
    [self.view addSubview:_slider];
    
    for (int i = 0; i < _slider.subviews.count; i++) {
        if (i != 2) {
            UIView *view = _slider.subviews[i];
            view.hidden = YES;
        }
    }
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI * (-1.5));
	[_slider setTransform:rotation];
    [_slider setFrame:CGRectMake(CGRectGetMaxX(_infoTableView.bounds) - 20, 38, 20, _infoTableView.bounds.size.height)];
    
    CGRect BOOKMARK_BUTTON_FRAME = CGRectMake(self.view.bounds.size.width - 60, CGRectGetMaxY(_infoTableView.frame), 55, 30);
    CGRect CHAPTERS_BUTTON_FRAME = CGRectMake(CGRectGetMinX(BOOKMARK_BUTTON_FRAME) - 55 , CGRectGetMaxY(_infoTableView.frame), 55, 30);
    
	_chapterlistBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chapterlistBtn setFrame:CHAPTERS_BUTTON_FRAME];
    [_chapterlistBtn setBackgroundImage:[UIImage imageNamed:@"chapterlist_btn"] forState:UIControlStateNormal];
    [_chapterlistBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    [_chapterlistBtn addTarget:self action:@selector(chaptersButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chapterlistBtn];
    
	_bookmarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bookmarkBtn setFrame:BOOKMARK_BUTTON_FRAME];
    [_bookmarkBtn setBackgroundImage:[UIImage imageNamed:@"bookmark_btn"] forState:UIControlStateNormal];
    [_bookmarkBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    [_bookmarkBtn addTarget:self action:@selector(bookmarksButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bookmarkBtn];
    
    [self.backgroundView removeFromSuperview];
}

- (void)chaptersButtonClicked
{
	self.headerView.titleLabel.text = @"目录";
	_bBookmarks = NO;
    [_chapterlistBtn setEnabled:NO];
    [_bookmarkBtn setEnabled:YES];
	_infoArray = [[Chapter allChaptersOfBookID:_chapter.bid] mutableCopy];
	if (!_infoArray.count) {
		[self getChaptersDataWithBlock:^(void) {
			[_infoTableView reloadData];
		}];
	} else {
		[_infoTableView reloadData];
	}
    _slider.hidden = NO;
}

- (void)getChaptersDataWithBlock:(dispatch_block_t)block
{
	[self displayHUD:@"获取章节目录..."];
	[ServiceManager getDownChapterList:_chapter.bid andUserid:[[ServiceManager userID] stringValue] withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {	
		[self hideHUD:YES];
		if (success) {
			_infoArray = [resultArray mutableCopy];
		} else {
			_infoArray = [[Chapter allChaptersOfBookID:_chapter.bid] mutableCopy];
		}
		if (block) block();
	}];
}

- (void)bookmarksButtonClicked
{
	self.headerView.titleLabel.text = @"书签";
	_bBookmarks = YES;
    [_chapterlistBtn setEnabled:YES];
    [_bookmarkBtn setEnabled:NO];
	NSArray *chapters = [Chapter findAllWithPredicate:[NSPredicate predicateWithFormat:@"bid = %@", _chapter.bid]];
	NSMutableArray *marks = [NSMutableArray array];
	for (Chapter *chapter in chapters) {
		NSArray *mks = [Mark findAllWithPredicate:[NSPredicate predicateWithFormat:@"chapterID = %@", chapter.uid]];
		if (mks) {
			[marks addObjectsFromArray:mks];
		}
	}
	_infoArray = marks;
	[_infoTableView reloadData];
    _slider.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self chaptersButtonClicked];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_infoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (_bBookmarks) {
		if (!cell) {
			cell = [[BookMarkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyCell"];
		}
		cell.textLabel.textColor = [UIColor blueColor];
		[cell.textLabel setFont:[UIFont systemFontOfSize:16]];
		Mark *mark = _infoArray[indexPath.row];
		[(BookMarkCell *)cell setMark:mark];
	} else {
		if (!cell) {
			cell = [[ChapterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyCell"];
		}
		Chapter *chapter = _infoArray[indexPath.row];
		[(ChapterCell *)cell  setChapter:chapter isCurrent:[chapter.uid isEqualToString:_chapter.uid] andAllChapters:_infoArray];
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.navigationController popViewControllerAnimated:NO];
	[_delegate didSelect:_infoArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
			Mark *mark = _infoArray[indexPath.row];
			[mark deleteEntity];
			[_infoArray removeObjectAtIndex:indexPath.row];
			[_infoTableView reloadData];
		}];
	}
}

- (void)sliderValueChanged:(id)sender {
    if (_bBookmarks) {
        return;
    }
	float offsetY = (_slider.value / 100.0) * (_infoTableView.contentSize.height - 460);
	[_infoTableView setContentOffset:CGPointMake(0, offsetY)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_bBookmarks) {
        return;
    }
	[_infoTableView setContentOffset:CGPointMake(0, _infoTableView.contentOffset.y)];
	_slider.value = 100.0 * _infoTableView.contentOffset.y / (_infoTableView.contentSize.height - 460);
}

@end
