//
//  BookDetailViewController.m
//  BookReader
//
//  Created by ZoomBin on 13-3-27.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "ServiceManager.h"
#import "UIViewController+HUD.h"
#import "BookCell.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "UIButton+BookReader.h"
#import "BookShelfViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+XXSY.h"
#import "CoreTextViewController.h"
#import "BRComment.h"
#import "UIColor+Hex.h"
#import "UIView+BookReader.h"
#import "CommentCell.h"
#import "Mark.h"
#import "ChapterCell.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "WebViewController.h"

#define AUTHORBOOK      1
#define OTHERBOOK       2

@interface BookDetailsViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, PopLoginViewControllerDelegate, SignUpViewControllerDelegate>

@property (readwrite) NSString *bookid;
@property (readwrite) Book *book;
@property (readwrite) int currentIndex;
@property (readwrite) int currentType;
@property (readwrite) UIButton *coverButton;
@property (readwrite) UIButton *chapterButton;
@property (readwrite) UIButton *commentButton;
@property (readwrite) UIButton *authorButton;
@property (readwrite) UIScrollView *coverView;
@property (readwrite) UIView *chapterListView;
@property (readwrite) UIView *commentView;
@property (readwrite) UIView *authorBookView;
@property (readwrite) UITextView *commitField;
@property (readwrite) UIButton *sendCommitButton;
@property (readwrite) UITextView *shortdescribeTextView;
@property (readwrite) UITableView *infoTableView;
@property (readwrite) UITableView *shortInfoTableView;
@property (readwrite) UITableView *recommendTableView;
@property (readwrite) UITableView *authorBookTableView;
@property (readwrite) UITableView *chapterListTableView;
@property (readwrite) NSMutableArray *infoArray;
@property (readwrite) NSMutableArray *shortInfoArray;
@property (readwrite) NSMutableArray *authorBookArray;
@property (readwrite) NSMutableArray *sameTypeBookArray;
@property (readwrite) NSMutableArray *chapterArray;
@property (readwrite) BOOL bLoading;
@property (readwrite) BOOL bCommit;
@property (readwrite) BOOL bChapter;
@property (readwrite) UIButton *shortDescribe;
@property (readwrite) UIButton *comment;
@property (readwrite) UIButton *authorBook;
@property (readwrite) UIButton *bookRecommend;
@property (readwrite) UILabel *bookNameLabel;
@property (readwrite) UILabel *authorNameLabel;
@property (readwrite) UILabel *catagoryNameLabel;
@property (readwrite) UILabel *wordsLabel;
@property (readwrite) UILabel *monthTicket;
@property (readwrite) UILabel *lastUpdateLabel;
@property (readwrite) UILabel *shortDescribeTitle;
@property (readwrite) UILabel *commentTitle;
@property (readwrite) UILabel *recommendTitle;
@property (readwrite) UILabel *commentLabel;
@property (readwrite) UILabel *flowerLabel;
@property (readwrite) UILabel *diamondLabel;
@property (readwrite) UILabel *rewardLabel;
@property (readwrite) UIView *commitHeaderView;
@property (readwrite) UIImageView *bookCover;
@property (readwrite) UIImageView *finishMark;
@property (readwrite) UIButton *favButton;
@property (readwrite) UIButton *giftButton;
@property (readwrite) UILabel *emptyLabel;
@property (readwrite) UISlider *slider;

@end

@implementation BookDetailsViewController

- (id)initWithBook:(NSString *)uid
{
    self = [super init];
    if (self) {
        _bookid = uid;
        _infoArray = [[NSMutableArray alloc] init];
        _authorBookArray = [[NSMutableArray alloc] init];
        _sameTypeBookArray = [[NSMutableArray alloc] init];
        _shortInfoArray = [[NSMutableArray alloc] init];
        _chapterArray = [[NSMutableArray alloc] init];
        _bLoading = NO;
        _bCommit = NO;
        _bChapter = NO;
        _currentIndex = 1;
        
        _shortDescribe = [UIButton buttonWithType:UIButtonTypeCustom];
        _comment = [UIButton buttonWithType:UIButtonTypeCustom];
        _authorBook = [UIButton buttonWithType:UIButtonTypeCustom];
        _bookRecommend = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_book == nil) {
        [self displayHUD:@"加载中..."];
        [ServiceManager bookDetailsByBookId:_bookid andIntro:YES withBlock:^(BOOL success, NSError *error, Book *obj) {
			[self hideHUD:YES];
            if(success) {
				_book = obj;
                [self initBookDetailUI];
            }else {
                if (error) {
                    [self displayHUDTitle:nil message:NETWORK_ERROR];
                } else {
                    [self displayHUDTitle:nil message:@"获取书籍详情失败"];
                }
				[self performSelector:@selector(backOrClose) withObject:nil afterDelay:2.0f];
            }
        }];
    }
	
	if ([ServiceManager isSessionValid]) {
		[self checkExistsFav];
    }
}

- (void)coverButtonClicked:(id)sender
{
    NSLog(@"封面");
    _bCommit = NO;
    _bChapter = NO;
    [self resetButtons];
    [sender setSelected:YES];
    [self.view bringSubviewToFront:_coverView];
}

- (void)chapterButtonClicked:(id)sender
{
    NSLog(@"目录");
	[self resetButtons];
    _bChapter = YES;
    _bCommit = NO;
    [sender setSelected:YES];
	[self.view bringSubviewToFront:_chapterListView];
    if (!_chapterArray.count) {
		[self getChaptersDataWithBlock:^(void) {
			[_chapterListTableView reloadData];
		}];
    }
}

- (void)commentButtonClicked:(id)sender
{
    NSLog(@"书评");
    _bCommit = YES;
    _bChapter = NO;
	[self resetButtons];
    [sender setSelected:YES];
    [self.view bringSubviewToFront:_commentView];
    if (!_infoArray.count) {
        [self loadCommitList];
    }
}

- (void)authorButtonClicked:(id)sender
{
    NSLog(@"作者作品");
    _bCommit = NO;
    _bChapter = NO;
	[self resetButtons];
    [sender setSelected:YES];
    [self.view bringSubviewToFront:_authorBookView];
    if ([_authorBookArray count]==0) {
        [self loadAuthorOtherBook];
    }
}

- (void)resetButtons
{
    [_commitField resignFirstResponder];
    _coverButton.selected = NO;
    _chapterButton.selected = NO;
    _commentButton.selected = NO;
    _authorButton.selected = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.headerView.titleLabel.text = @"书籍详情";
    CGSize fullSize = self.view.bounds.size;
    CGRect modelViewFrame = CGRectMake(5, 46 + 30, fullSize.width - 10, fullSize.height - 56 - 25);
    
    UIButton *bookShelfButton = [UIButton bookShelfButtonWithStartPosition:CGPointMake(fullSize.width - 60, 3)];
    [self.view addSubview:bookShelfButton];
    
    UIButton *mainButton = [UIButton addButtonWithFrame:CGRectMake(CGRectGetMinX(bookShelfButton.frame) - 50 , 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
    [mainButton setImage:[UIImage imageNamed:@"main_btn"] forState:UIControlStateNormal];
    [mainButton setImage:[UIImage imageNamed:@"main_btn_hl"] forState:UIControlStateHighlighted];
    [mainButton addTarget:self action:@selector(mainButtonClicked) forControlEvents:UIControlEventTouchUpInside];
	mainButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:mainButton];
    
    _emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, 30)];
    [_emptyLabel setText:@"暂无其它书籍"];
    [_emptyLabel setTextAlignment:NSTextAlignmentCenter];
    
    for (int i = 0; i < 4; i++) {
        switch (i) {
            case 0:
                _coverView = [[UIScrollView alloc] initWithFrame:modelViewFrame];
                [_coverView setContentSize:CGSizeMake(_coverView.frame.size.width, _coverView.frame.size.height * 3)];
                [_coverView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:_coverView];
                break;
            case 1:
                _chapterListView = [[UIView alloc] initWithFrame:modelViewFrame];
                [_chapterListView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:_chapterListView];
                break;
            case 2:
                _commentView = [[UIView alloc] initWithFrame:modelViewFrame];
                [_commentView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:_commentView];
                break;
            case 3:
                _authorBookView = [[UIView alloc] initWithFrame:modelViewFrame];
                [_authorBookView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:_authorBookView];
                break;
            default:
                break;
        }
    }
    [self.view bringSubviewToFront:_coverView];
    
    NSMutableArray *headerBtns = [NSMutableArray array];
    NSArray *selectors =  @[@"coverButtonClicked:",@"chapterButtonClicked:",@"commentButtonClicked:",@"authorButtonClicked:"];
    NSInteger width = (fullSize.width-10)/4;
    NSArray *tabbarStrings = @[@"封　　面",@"目　　录",@"书　　评",@"作者作品"];
    for (int i = 0; i<[tabbarStrings count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.showsTouchWhenHighlighted = YES;
		[button setTitle:tabbarStrings[i] forState:UIControlStateNormal];
		[button.titleLabel setFont:[UIFont systemFontOfSize:15]];
		[button setTitleColor:[UIColor colorWithRed:138.0/255.0 green:124.0/255.0 blue:105.0/255.0 alpha:1.0] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor colorWithRed:192.0/255.0 green:106.0/255.0 blue:46.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [button addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(5 + width * i, 46, width, 30)];
        [self.view addSubview:button];
        [headerBtns addObject:button];
    }
    _coverButton = headerBtns[0];
    _chapterButton = headerBtns[1];
    _commentButton = headerBtns[2];
    _authorButton = headerBtns[3];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 75, fullSize.width - 20, 1)];
    [line setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:line];
    
    _coverButton.selected = YES;
    
    _bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, BOOK_COVER_ORIGIN_SIZE.width / 1.2, BOOK_COVER_ORIGIN_SIZE.height / 1.2)];
    [_bookCover setImage:[UIImage imageNamed:@"book_placeholder"]];
    [_coverView addSubview:_bookCover];
    
    _finishMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [_finishMark setImage:[UIImage imageNamed:@"finish_mark"]];
    [_finishMark setBackgroundColor:[UIColor clearColor]];
    [_bookCover addSubview:_finishMark];
    [_finishMark setHidden:YES];
    
    NSArray *labelTitles = @[@"",@"作者:",@"类别:",@"大小:",@"月票", @"更新:",@"",@"",@"",@""];
    NSArray *giftImages = @[@"demand" ,@"flower", @"money", @"comment"];
    NSMutableArray *labelsArray = [NSMutableArray array];
    int k = 0;
    float WIDTH = _coverView.frame.size.width - 20;
    float HEIGHT = 10;
    for (int i = 0; i<[labelTitles count]; i++) {
        UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
        [label setUserInteractionEnabled:NO];
        [label setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [label setFrame:CGRectMake(100, 20 + 20 * i, WIDTH, HEIGHT)];
        [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (i > 0 && i <= 5) {
            [label setFrame:CGRectMake(100, (i == 1 ? 5 : 0) + CGRectGetMaxY([(UILabel *)labelsArray[i - 1] frame]) + 5, WIDTH, HEIGHT)];
            [label.titleLabel setFont:[UIFont systemFontOfSize:12]];
        } else if ( i > 5) {
            [label setFrame:CGRectMake(k == 0 ? 10 : CGRectGetMaxX([(UILabel *)labelsArray[i - 1] frame])  , (k == 0 ? 20 : 0) + CGRectGetMinY([(UILabel *)labelsArray[i - 1] frame]), WIDTH/4, HEIGHT * 2)];
            [label.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [label setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
            [label setContentHorizontalAlignment:UIControlContentVerticalAlignmentCenter];
            [label.layer setBorderColor:[UIColor grayColor].CGColor];
            [label.layer setBorderWidth:0.5];
            [label setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0]];
            [label setImage:[self scaleToSize:[UIImage imageNamed:giftImages[k]] size:CGSizeMake(20, 20)] forState:UIControlStateNormal];
            k ++;
        }
        [label setTitle:labelTitles[i] forState:UIControlStateNormal];
        [_coverView addSubview:label];
        [labelsArray addObject:label];
    }
    _bookNameLabel = labelsArray[0];
    _authorNameLabel = labelsArray[1];
    _catagoryNameLabel = labelsArray[2];
    _wordsLabel = labelsArray[3];
    _monthTicket = labelsArray[4];
    _lastUpdateLabel = labelsArray[5];
    _diamondLabel = labelsArray[6];
    _flowerLabel = labelsArray[7];
    _rewardLabel = labelsArray[8];
    _commentLabel = labelsArray[9];
    
    float three_btn_width = (_coverView.frame.size.width - 4 * 5)/3;
    NSArray *buttonNames = @[@"阅读", @"收藏", @"投月票"];
    NSArray *selectorString = @[@"readButtonClicked:", @"addFav", @"buttonClicked:"];
    for (int i = 0; i < [buttonNames count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(5 * (i + 1) + three_btn_width * i, CGRectGetMaxY(_commentLabel.frame) + 10, three_btn_width, 40)];
        [button addTarget:self action:NSSelectorFromString(selectorString[i]) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        if (i == 1) {
            _favButton = button;
			[_favButton setTitle:@"已收藏" forState:UIControlStateDisabled | UIControlStateSelected];
        } else if (i == 2) {
			_giftButton = button;
		}
        [_coverView addSubview:button];
    }
    
    _shortdescribeTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_favButton.frame) + 10, _coverView.frame.size.width - 5 * 2, 150)];
    [_shortdescribeTextView setEditable:NO];
    [_shortdescribeTextView setScrollEnabled:NO];
    [_shortdescribeTextView setTextColor:[UIColor bookStoreTxtColor]];
    [_shortdescribeTextView setFont:[UIFont systemFontOfSize:15]];
    [_shortdescribeTextView setBackgroundColor:[UIColor clearColor]];
    [_coverView addSubview:_shortdescribeTextView];
    
    _commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_shortdescribeTextView.frame) + 5, _coverView.frame.size.width - 5 *2, 40)];
    [_commentTitle setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [_commentTitle setFont:[UIFont boldSystemFontOfSize:15]];
    [_commentTitle.layer setBorderWidth:0.5];
    [_commentTitle.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_commentTitle setText:@"　书评"];
    [_coverView addSubview:_commentTitle];
    
    _shortInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_commentTitle.frame) + 5, _coverView.frame.size.width - 5 * 2, 320) style:UITableViewStylePlain];
    [_shortInfoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin];
    [_shortInfoTableView setDelegate:self];
    [_shortInfoTableView setDataSource:self];
    [_shortInfoTableView setBackgroundColor:[UIColor clearColor]];
    [_shortInfoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_coverView addSubview:_shortInfoTableView];
    
    _recommendTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_shortInfoTableView.frame) + 5, _coverView.frame.size.width - 5 *2, 40)];
    [_recommendTitle setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [_recommendTitle setFont:[UIFont boldSystemFontOfSize:15]];
    [_recommendTitle.layer setBorderWidth:0.5];
    [_recommendTitle.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_recommendTitle setText:@"　同类推荐"];
    [_coverView addSubview:_recommendTitle];
    
    _recommendTableView = [[UITableView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(_recommendTitle.frame) + 5, _coverView.frame.size.width - 5 * 2, 260) style:UITableViewStylePlain];
    [_recommendTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_recommendTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_recommendTableView setBackgroundColor:[UIColor clearColor]];
    [_recommendTableView setDelegate:self];
    [_recommendTableView setDataSource:self];
    [_coverView addSubview:_recommendTableView];
    
    _infoTableView = [[UITableView alloc]initWithFrame:_commentView.bounds style:UITableViewStylePlain];
    [_infoTableView setDelegate:self];
    [_infoTableView setDataSource:self];
    [_infoTableView setBackgroundColor:[UIColor clearColor]];
    [_infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_commentView addSubview:_infoTableView];
    
    UIView *commentHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _infoTableView.frame.size.width, 50 * 3.5)];
    [commentHeaderView setBackgroundColor:[UIColor clearColor]];
    
    _commitField = [[UITextView alloc] initWithFrame:CGRectMake(12, 17.5, _infoTableView.frame.size.width - 12 * 2, 35 * 3 * 0.8)];
    //    [commitField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_commitField.layer setCornerRadius:5];
    [_commitField setDelegate:self];
    [_commitField setReturnKeyType:UIReturnKeyDone];
    [_commitField.layer setBorderColor:[UIColor blackColor].CGColor];
    [_commitField.layer setBorderWidth:0.5];
    [_commitField setBackgroundColor:[UIColor whiteColor]];
    [commentHeaderView addSubview:_commitField];
    
    UIButton *sendCommitbutton = [UIButton createButtonWithFrame:CGRectMake(CGRectGetMaxX(_commitField.frame) - 60, CGRectGetMaxY(_commitField.frame) + 10, 60, 35)];
    [sendCommitbutton addTarget:self action:@selector(sendCommitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [sendCommitbutton setTitle:@"发表" forState:UIControlStateNormal];
    [sendCommitbutton setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
    [commentHeaderView addSubview:sendCommitbutton];
    
    [_infoTableView setTableHeaderView:commentHeaderView];
    
    _chapterListTableView = [[UITableView alloc]initWithFrame:_chapterListView.bounds style:UITableViewStylePlain];
    [_chapterListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_chapterListTableView setBackgroundColor:[UIColor whiteColor]];
    [_chapterListTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_chapterListTableView setDelegate:self];
    [_chapterListTableView setDataSource:self];
    [_chapterListView addSubview:_chapterListTableView];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 210, fullSize.height - 150, 20)];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_slider setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [_slider setThumbImage:[UIImage imageNamed:@"thumb_image"] forState:UIControlStateNormal];
    [_slider setMinimumTrackTintColor:[UIColor clearColor]];
    [_slider setMaximumTrackTintColor:[UIColor clearColor]];
    [_slider.layer setBorderColor:[UIColor clearColor].CGColor];
    [_slider setMinimumValue:0];
    [_slider setMaximumValue:100];
    [_chapterListView addSubview:_slider];
    
    for (int i = 0; i < [_slider.subviews count]; i++) {
        if (i != 2) {
            UIView *view = _slider.subviews[i];
            view.hidden = YES;
        }
    }
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI * (-1.5));
	[_slider setTransform:rotation];
    [_slider setFrame:CGRectMake(CGRectGetMaxX(_chapterListTableView.bounds) - 30, 0, 20, _chapterListView.bounds.size.height)];
    
    _authorBookTableView = [[UITableView alloc]initWithFrame:_authorBookView.bounds style:UITableViewStylePlain];
    [_authorBookTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_authorBookTableView setBackgroundColor:[UIColor clearColor]];
    [_authorBookTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_authorBookTableView setDelegate:self];
    [_authorBookTableView setDataSource:self];
    [_authorBookView addSubview:_authorBookTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (![ServiceManager isSessionValid] && ![ServiceManager showDialogs]) {
		_favButton.hidden = YES;
		_giftButton.hidden = YES;
	} else {
		_favButton.hidden = NO;
		_giftButton.hidden = NO;
	}
}

- (void)refreshCoverViewFrame
{
    [_commentTitle setFrame:CGRectMake(5, CGRectGetMaxY(_shortdescribeTextView.frame) + 5, _coverView.frame.size.width - 5 * 2, 40)];
    [_shortInfoTableView setFrame:CGRectMake(5, CGRectGetMaxY(_commentTitle.frame) + 5, _coverView.frame.size.width - 5 * 2, _shortInfoTableView.contentSize.height)];
    [_recommendTitle setFrame:CGRectMake(5, CGRectGetMaxY(_shortInfoTableView.frame) + 5, _coverView.frame.size.width - 5 * 2, 40)];
    [_recommendTableView setFrame:CGRectMake(5, CGRectGetMaxY(_recommendTitle.frame) + 5, _coverView.frame.size.width - 5 * 2, _recommendTableView.contentSize.height)];
    [_coverView setContentSize:CGSizeMake(_coverView.frame.size.width, CGRectGetMaxY(_recommendTableView.frame))];
}

- (void)mainButtonClicked
{
    [APP_DELEGATE gotoRootController:kRootControllerIdentifierBookStore];
}

- (void)initBookDetailUI
{
    NSURL *url = [NSURL URLWithString:_book.coverURL];
    UIImageView *tmpImageView = _bookCover;
	
    [tmpImageView setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:[UIImage imageNamed:@"book_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        _book.cover = UIImageJPEGRepresentation(image, 1.0);
		_bookCover.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    NSString *bookName = _book.name;
    NSString *authorName = [@"作者: " stringByAppendingString:_book.author];
    NSString *catagoryName = [@"类别: " stringByAppendingString:_book.category];
    NSString *words = [@"大小: " stringByAppendingString:[_book.words stringValue]];
    NSString *lastUpdate = [@"更新: " stringByAppendingString:_book.lastUpdate];
    NSString *diamondAmount = [NSString stringWithFormat:@"%@", _book.diamond];
    NSString *flowerAmount = [NSString stringWithFormat:@"%@", _book.flower];
    NSString *rewardAmount = [NSString stringWithFormat:@"%@", _book.reward];
    NSString *commentAmount = [NSString stringWithFormat:@"%@", _book.comment];
    NSString *monthTicketAmount = [NSString stringWithFormat:@"月票: %@", _book.monthTicket];
    
    NSArray *labelTitles = @[bookName, authorName, catagoryName, words, monthTicketAmount, lastUpdate, diamondAmount, flowerAmount, rewardAmount, commentAmount];
    NSArray *labels = @[_bookNameLabel, _authorNameLabel, _catagoryNameLabel, _wordsLabel, _monthTicket, _lastUpdateLabel, _diamondLabel, _flowerLabel, _rewardLabel, _commentLabel];
    for (int i = 0; i<[labels count]; i++) {
        UIButton *label = (UIButton *)labels[i];
        [label setTitle:labelTitles[i] forState:UIControlStateNormal];
    }
	
    if ([_book.bFinish isEqualToString:BOOK_FINISH_IDENTIFIER]) {
        [_finishMark setHidden:NO];
    }
    
    if ([ServiceManager isSessionValid]) {
		[self checkExistsFav];
    }
    
    [_shortdescribeTextView setText:_book.describe];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
		[_shortdescribeTextView sizeToFit];
    } else {
        CGFloat height = _shortdescribeTextView.contentSize.height;
        CGRect frame = CGRectMake(_shortdescribeTextView.frame.origin.x, _shortdescribeTextView.frame.origin.y, _shortdescribeTextView.frame.size.width, height);
        [_shortdescribeTextView setFrame:frame];
    }
    
    [self loadCommitList];
    [self loadSameType];
	self.hideKeyboardRecognzier.enabled = NO;
}

- (void)getChaptersDataWithBlock:(dispatch_block_t)block
{
	[self displayHUD:@"获取章节目录..."];
	
	//lastChapterID = 0获取全部章节
	//[ServiceManager getDownChapter:book.uid lastChapterID:@"0" withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
	[ServiceManager getDownChapterList:_book.uid andUserid:[[ServiceManager userID] stringValue] withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
		[self hideHUD:YES];
		if (success) {
			_chapterArray = [resultArray mutableCopy];
			if (block) block();
		} else {
			[self displayHUDTitle:@"获取章节目录失败" message:error.description];
		}
	}];
}

- (void)readButtonClicked:(id)sender
{
    if (_chapterArray.count) {
        [self pushToReadViewWithChapter:nil];
        return;
    } else {
        [self getChaptersDataWithBlock:^{
			Chapter *chapterShouldRead = [Chapter lastReadChapterOfBook:_book];
			if (!chapterShouldRead) {
				chapterShouldRead = _chapterArray[0];
			}
			[_chapterListTableView reloadData];
			[self pushToReadViewWithChapter:chapterShouldRead];
        }];
    }
}

- (void)buttonClicked:(id)sender
{
    [self pushToGiftViewWithIndex:@"0"];
}

- (void)loadAuthorOtherBook
{
	[self displayHUD:@"加载中..."];
    [ServiceManager otherBooksFromAuthor:_book.authorID andCount:@"5" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
		if (success) {
            [self hideHUD:YES];
            if ([_authorBookArray count]>0) {
                [_authorBookArray removeAllObjects];
                [_authorBookTableView reloadData];
            }
            for (int i = 0 ; i<[resultArray count]; i++) {
                Book *obj = [resultArray objectAtIndex:i];
                if([obj.uid integerValue] != [_bookid integerValue]) {
                    [_authorBookArray addObject:obj];
                    [_authorBookTableView reloadData];
                }
            }
            if (!_authorBookArray.count) {
                [_authorBookTableView setTableHeaderView:_emptyLabel];
            }
		} else {
            [self displayHUDTitle:nil message:error.description];
        }
    }];
}

- (void)loadSameType
{
    [ServiceManager bookRecommend:_book.categoryID.integerValue andCount:@"5" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
		if (success) {
			if (_sameTypeBookArray.count) {
                [_sameTypeBookArray removeAllObjects];
                [_recommendTableView reloadData];
            }
            for (int i = 0 ; i<[resultArray count]; i++) {
                Book *obj = [resultArray objectAtIndex:i];
                if([obj.uid integerValue] != [_bookid integerValue]) {
                    [_sameTypeBookArray addObject:obj];
                    [_recommendTableView reloadData];
                }
				if (_sameTypeBookArray.count == 4) {
					break;
				}
			}
			[self refreshCoverViewFrame];
		} else {
            [self displayHUDTitle:nil message:error.description];
        }
	}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self sendCommitButtonClicked];
        return NO;
    }
    return YES;
}

- (void)sendCommitButtonClicked
{
    [_commitField resignFirstResponder];
	if (![ServiceManager isSessionValid]) {
		[self displayHUDTitle:@"失败" message:@"发布评论失败"];
		return;
	}

    if ([_commitField.text length] <= 5) {
        [self displayHUDTitle:nil message:@"评论内容太短!"];
        return;
    }
	
    [ServiceManager disscussWithBookID:_bookid andContent:_commitField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
        if (success) {
            _commitField.text = @"";
            [self displayHUDTitle:nil message:message];
            [self performSelector:@selector(loadCommitList) withObject:nil afterDelay:3.0];
        } else {
            if (!error) {
                [self displayHUDTitle:nil message:message];
            } else {
                [self displayHUDTitle:nil message:error.description];
            }
        }
    }];
}

- (void)loadCommitList
{
	[_infoArray removeAllObjects];
    [_infoTableView reloadData];
    _currentIndex = 1;
	[self displayHUD:@"加载中..."];
    [ServiceManager bookDiccusssListByBookId:_bookid size:@"10" andIndex:@"1" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
		[self hideHUD:YES];
		if (success) {
			if ([resultArray count] == 10) {
                [self addFootView];
            }
			_currentIndex++;
            [_infoArray addObjectsFromArray:resultArray];
            [_infoTableView reloadData];
            
            NSRange theRange;
            theRange.location = 0;
            theRange.length = [resultArray count] >= 6 ? 6 : resultArray.count;
            [_shortInfoArray removeAllObjects];
            [_shortInfoTableView reloadData];
            [_shortInfoArray addObjectsFromArray:[resultArray subarrayWithRange:theRange]];
            [_shortInfoTableView reloadData];
            [self refreshCoverViewFrame];
		} else {
            if (error) {
                [self displayHUDTitle:nil message:error.description];
            }
        }
    }];
}

- (void)pushToReadViewWithChapter:(Chapter *)chapter
{
	[self displayHUD:@"加载中..."];
	[_book persistWithBlock:^(void) {
		Chapter *c = chapter;
		if (!c) {
			c = [Chapter lastReadChapterOfBook:_book];
			if (!c) {
				NSLog(@"获取章节失败");
				return;
			}
		}
		
		[self hideHUD:YES];
		CoreTextViewController *controller = [[CoreTextViewController alloc] init];
		controller.chapter = c;
		controller.chapters = _chapterArray;
		controller.previousViewController = self;
		[self.navigationController pushViewController:controller animated:YES];
		
		[Chapter persist:_chapterArray withBlock:^(void) {
			[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
				Book *b = [Book findFirstByAttribute:@"uid" withValue:_book.uid inContext:localContext];
				if (b) {
					b.numberOfUnreadChapters = @([Chapter countOfUnreadChaptersOfBook:b]);
				}
			}];
		}];
	}];
}

- (void)pushToGiftViewWithIndex:(NSString *)index
{
	NSNumber *userID = [ServiceManager isSessionValid] ? [ServiceManager userID] : @(0);
	WebViewController *webViewController = [[WebViewController alloc] init];
	webViewController.urlString = [NSString stringWithFormat:@"%@?userid=%@&bookid=%@&version=%@", kXXSYGiftsUrlString, userID, _book.uid, [NSString appVersion]];
	webViewController.book = _book;
	webViewController.fromWhere = kFromGift;
	//GiftViewController *giftViewController = [[GiftViewController alloc] initWithBook:book];
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)addFav
{
	if (![ServiceManager isSessionValid]) {
		WebViewController *webViewController = [[WebViewController alloc] init];
		webViewController.fromWhere = kFromLogin;
		webViewController.urlString = [NSString stringWithFormat:@"%@?version=%@", kXXSYLoginUrlString, [NSString appVersion]];
		[self.navigationController pushViewController:webViewController animated:YES];
		return;
	}
	
	[self displayHUD:@"正在收藏..."];
	[ServiceManager addFavoriteWithBookID:_bookid On:YES withBlock:^(BOOL success, NSError *error,NSString *message) {
		if (success) {
			[self hideHUD:YES];
			_book.bFav = @(YES);
			_favButton.selected = YES;
			[_favButton setEnabled:NO];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
			[[NSUserDefaults standardUserDefaults] synchronize];
			[_book persistWithBlock:^(void) {
				[MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
					Book *b = [Book findFirstByAttribute:@"uid" withValue:_book.uid inContext:localContext];
					b.bFav = @(YES);
				} completion:^(BOOL success, NSError *error) {
					if (_chapterArray) {
						[Chapter persist:_chapterArray withBlock:nil];
					}
				}];
			}];
		} else {
			[self displayHUDTitle:nil message:message];
		}
	}];
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _infoTableView) {
        return _infoArray.count;
    } else if (tableView == _shortInfoTableView) {
        return _shortInfoArray.count;
    } else if (tableView == _recommendTableView) {
        return _sameTypeBookArray.count;
    } else if (tableView == _chapterListTableView) {
        return _chapterArray.count;
    } else if (tableView == _authorBookTableView){
        return _authorBookArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _infoTableView || tableView == _shortInfoTableView){
        CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell height];
    } else {
        BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell height];
    }
	return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (tableView == _infoTableView) {
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            BRComment *obj = [_infoArray objectAtIndex:[indexPath row]];
            [(CommentCell *)cell setComment:obj];
        }
    } else if (tableView == _shortInfoTableView) {
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            BRComment *obj = [_shortInfoArray objectAtIndex:[indexPath row]];
            [(CommentCell *)cell setComment:obj];
        }
    } else if (tableView == _chapterListTableView) {
        if (!cell) {
            cell = [[ChapterCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"MyCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		}
		Chapter *chapter = [_chapterArray objectAtIndex:[indexPath row]];
		Chapter *lastReadChapter = [Chapter	lastReadChapterOfBookID:chapter.bid];
		BOOL isCurrent = NO;
		if (lastReadChapter) {
			isCurrent = [chapter.uid isEqualToString:lastReadChapter.uid];
			if (isCurrent) {
				NSLog(@"same chapter");
			}
		}
		[(ChapterCell *)cell setChapter:chapter isCurrent:isCurrent andAllChapters:_chapterArray];
    }
    else {
        if (cell == nil) {
            NSArray *tmpArray = tableView == _recommendTableView ? _sameTypeBookArray : _authorBookArray;
            cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
            Book *b = [tmpArray objectAtIndex:[indexPath row]];
            if (tableView == _authorBookTableView) {
                b.author = nil;
            }
            [(BookCell *)cell setBook:b];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == _recommendTableView || tableView == _authorBookTableView) {
		NSArray *booksArray = tableView == _authorBookTableView ? _authorBookArray : _sameTypeBookArray;
		Book *b = booksArray[indexPath.row];
		BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:b.uid];
		[self.navigationController pushViewController:childViewController animated:YES];
	} else if (tableView == _chapterListTableView) {
        [self pushToReadViewWithChapter:_chapterArray[indexPath.row]];
    }
}

- (void)addFootView
{
    UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
    [_infoTableView setTableFooterView:footview];
}

- (void)getMore
{
    [ServiceManager bookDiccusssListByBookId:_bookid size:@"10" andIndex:[NSString stringWithFormat:@"%d", _currentIndex] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (success) {
			if (!_infoArray.count) {
                [_infoTableView setTableFooterView:nil];
            }
            [_infoArray addObjectsFromArray:resultArray];
            _currentIndex++;
            [_infoTableView reloadData];
            _bLoading = NO;
        } else {
            [self displayHUDTitle:nil message:error.description];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_bCommit) {
        if(scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height - 70) {
            if (!_bLoading) {
                _bLoading = YES;
                NSLog(@"可刷新");
                [self getMore];
            }
        }
    } else if (_bChapter){
        [_chapterListTableView setContentOffset:CGPointMake(0, _chapterListTableView.contentOffset.y)];
        _slider.value = 100.0 * _chapterListTableView.contentOffset.y / (_chapterListTableView.contentSize.height - 460);
    }
}

- (void)sliderValueChanged:(id)sender {
	float offsetY = (_slider.value / 100.0) * (_chapterListTableView.contentSize.height - 460);
	[_chapterListTableView setContentOffset:CGPointMake(0, offsetY)];
}

- (UIImage*)scaleToSize:(UIImage*)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (void)showPopLogin
{
//	PopLoginViewController *popLoginViewController = [[PopLoginViewController alloc] initWithFrame:self.view.frame];
//	popLoginViewController.delegate = self;
//	[self addChildViewController:popLoginViewController];
//	[self.view addSubview:popLoginViewController.view];
}

- (void)checkExistsFav
{
	[ServiceManager existsFavoriteWithBookID:_bookid withBlock:^(BOOL isExist, NSError *error) {
		if (!error) {
			if (isExist) {
				[_favButton setEnabled:NO];
				_favButton.selected = YES;
			}
		}
	}];
}

#pragma mark - PopLoginViewControllerDelegate

- (void)popLoginDidLogin
{
	[self checkExistsFav];
}

- (void)popLoginDidCancel
{
	;
}

- (void)popLoginWillSignup
{
	WebViewController *webViewController = [[WebViewController alloc] init];
	webViewController.fromWhere = kFromLogin;
	webViewController.urlString = [NSString stringWithFormat:@"%@?version=%@", kXXSYRegisterUrlString, [NSString appVersion]];
	NSLog(@"urlString: %@", webViewController.urlString);
	[self.navigationController pushViewController:webViewController animated:YES];
	//SignUpViewController *signUpViewController = [[SignUpViewController alloc] init];
	//signUpViewController.delegate = self;
	//[self.navigationController pushViewController:signUpViewController animated:YES];
}

#pragma mark - SignUpViewControllerDelegate

- (void)signUpDone:(SignUpViewController *)signUpViewController
{
	[signUpViewController backOrClose];
}

@end
