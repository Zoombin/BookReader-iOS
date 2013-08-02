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
#import "Book.h"
#import "BookCell.h"
#import "UIImageView+AFNetworking.h"
#import "GiftViewController.h"
#import "AppDelegate.h"
#import "UIButton+BookReader.h"
#import "BookShelfViewController.h"
#import "BookReaderDefaultsManager.h"
#import "UIColor+BookReader.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+XXSY.h"
#import "CoreTextViewController.h"
#import "Book+Setup.h"
#import "Chapter+Setup.h"
#import "Comment.h"
#import "UIColor+Hex.h"
#import "UILabel+BookReader.h"
#import "UIView+BookReader.h"
#import "CommentCell.h"
#import "BookShelfButton.h"
#import "BookReader.h"
#import "Mark.h"
#import "ChapterCell.h"
#import "SignInViewController.h"

#define AUTHORBOOK      1
#define OTHERBOOK       2

@implementation BookDetailsViewController
{
    NSString *bookid;
    Book *book;
    int currentIndex;
    int currentType;
    
    UIButton *coverButton;
    UIButton *chapterButton;
    UIButton *commentButton;
    UIButton *authorButton;
    
    UIScrollView *coverView;
    UIView *chapterListView;
    UIView *commentView;
    UIView *authorBookView;
    
    UITextView *commitField;
    UIButton *sendCommitButton;
    UITextView *shortdescribeTextView;
    UITableView *infoTableView;
    UITableView *shortInfoTableView;
    UITableView *recommendTableView;
    UITableView *authorBookTableView;
    UITableView *chapterListTableView;
    
    NSMutableArray *infoArray;
    NSMutableArray *shortInfoArray;
    NSMutableArray *authorBookArray;
    NSMutableArray *sameTypeBookArray;
    NSMutableArray *chapterArray;
    BOOL bFav;
    BOOL bLoading;
    BOOL bCommit;
    BOOL bChapter;
    
    UIButton *shortDescribe;
    UIButton *comment;
    UIButton *authorBook;
    UIButton *bookRecommend;
    
    UILabel *bookNameLabel;
    UILabel *authorNameLabel;
    UILabel *catagoryNameLabel;
    UILabel *wordsLabel;
    UILabel *monthTicket;
    UILabel *lastUpdateLabel;
    
    UILabel *shortDescribeTitle;
    UILabel *commentTitle;
    UILabel *recommendTitle;
    
    UILabel *commentLabel;
    UILabel *flowerLabel;
    UILabel *diamondLabel;
    UILabel *rewardLabel;
    
    UIView *commitHeaderView;
    UIImageView *bookCover;
    UIImageView *finishMark;
    
    UIButton *favButton;
    UILabel *emptyLabel;
    
    UISlider *slider;
    //LoginViewController *loginView;
}

- (id)initWithBook:(NSString *)uid
{
    self = [super init];
    if (self) {
        bookid = uid;
        infoArray = [[NSMutableArray alloc] init];
        authorBookArray = [[NSMutableArray alloc] init];
        sameTypeBookArray = [[NSMutableArray alloc] init];
        shortInfoArray = [[NSMutableArray alloc] init];
        chapterArray = [[NSMutableArray alloc] init];
        bFav = NO;
        bLoading = NO;
        bCommit = NO;
        bChapter = NO;
        currentIndex = 1;
        
        shortDescribe = [UIButton buttonWithType:UIButtonTypeCustom];
        comment = [UIButton buttonWithType:UIButtonTypeCustom];
        authorBook = [UIButton buttonWithType:UIButtonTypeCustom];
        bookRecommend = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (book == nil) {
        [self displayHUD:@"加载中..."];
        [ServiceManager bookDetailsByBookId:bookid andIntro:YES withBlock:^(BOOL success, NSError *error, Book *obj) {
            if(error) {
                NSLog(@"%@",error);
                [self displayHUDError:nil message:NETWORK_ERROR];
				[self.navigationController popViewControllerAnimated:YES];
            }else {
                book = obj;
                [self hideHUD:YES];
                [self initBookDetailUI];
            }
        }];
    }
}

- (void)coverButtonClicked:(id)sender
{
    NSLog(@"封面");
    bCommit = NO;
    bChapter = NO;
    [self resetButtons];
    [sender setSelected:YES];
    [self.view bringSubviewToFront:coverView];
}

- (void)chapterButtonClicked:(id)sender
{
    NSLog(@"章节");
    if (![chapterArray count]) {
		[self getChaptersDataWithBlock:nil];
    }
    [self resetButtons];
    bChapter = YES;
    bCommit = NO;
    [sender setSelected:YES];
    [self.view bringSubviewToFront:chapterListView];
}

- (void)commentButtonClicked:(id)sender
{
    NSLog(@"评论");
    bCommit = YES;
    bChapter = NO;
    if ([infoArray count]==0) {
        [self loadCommitList];
    }
    [self resetButtons];
    [sender setSelected:YES];
    [self.view bringSubviewToFront:commentView];
}

- (void)authorButtonClicked:(id)sender
{
    NSLog(@"作者书籍");
    bCommit = NO;
    bChapter = NO;
    if ([authorBookArray count]==0) {
        [self loadAuthorOtherBook];
    }
    [self resetButtons];
    [sender setSelected:YES];
    [self.view bringSubviewToFront:authorBookView];
}

- (void)resetButtons
{
    [commitField resignFirstResponder];
    coverButton.selected = NO;
    chapterButton.selected = NO;
    commentButton.selected = NO;
    authorButton.selected = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:book.name];
    CGSize fullSize = self.view.bounds.size;
    CGRect modelViewFrame = CGRectMake(5, 46 + 30, fullSize.width - 10, fullSize.height - 56 - 25);
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [bookShelfButton setFrame:CGRectMake(fullSize.width - 60, 3, 50, 32)];
    [self.view addSubview:bookShelfButton];
    
    UIButton *mainButton = [UIButton addButtonWithFrame:CGRectMake(CGRectGetMinX(bookShelfButton.frame) - 50 , 3, 50, 32) andStyle:BookReaderButtonStyleNormal];
    [mainButton setImage:[UIImage imageNamed:@"main_btn"] forState:UIControlStateNormal];
    [mainButton setImage:[UIImage imageNamed:@"main_btn_hl"] forState:UIControlStateHighlighted];
    [mainButton addTarget:self action:@selector(mainButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mainButton];
    
    emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fullSize.width, 30)];
    [emptyLabel setText:@"暂无其它书籍"];
    [emptyLabel setTextAlignment:UITextAlignmentCenter];
    
    for (int i = 0; i < 4; i++) {
        switch (i) {
            case 0:
                coverView = [[UIScrollView alloc] initWithFrame:modelViewFrame];
                [coverView setContentSize:CGSizeMake(coverView.frame.size.width, coverView.frame.size.height * 3)];
                [coverView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:coverView];
                break;
            case 1:
                chapterListView = [[UIView alloc] initWithFrame:modelViewFrame];
                [chapterListView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:chapterListView];
                break;
            case 2:
                commentView = [[UIView alloc] initWithFrame:modelViewFrame];
                [commentView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:commentView];
                break;
            case 3:
                authorBookView = [[UIView alloc] initWithFrame:modelViewFrame];
                [authorBookView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:authorBookView];
                break;
            default:
                break;
        }
    }
    [self.view bringSubviewToFront:coverView];
    
    NSMutableArray *headerBtns = [NSMutableArray array];
    NSArray *selectors =  @[@"coverButtonClicked:",@"chapterButtonClicked:",@"commentButtonClicked:",@"authorButtonClicked:"];
    NSInteger width = (fullSize.width-10)/4;
    NSArray *tabbarStrings = @[@"封\t\t\t面",@"目\t\t\t录",@"书\t\t\t评",@"作者作品"];
    for (int i = 0; i<[tabbarStrings count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:tabbarStrings[i] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button setTitleColor:[UIColor colorWithRed:138.0/255.0 green:124.0/255.0 blue:105.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:192.0/255.0 green:106.0/255.0 blue:46.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [button addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(5 + width * i, 46, width, 30)];
        [self.view addSubview:button];
        [headerBtns addObject:button];
    }
    coverButton = headerBtns[0];
    chapterButton = headerBtns[1];
    commentButton = headerBtns[2];
    authorButton = headerBtns[3];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 75, fullSize.width - 20, 1)];
    [line setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:line];
    
    coverButton.selected = YES;
    
    bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, BOOK_COVER_ORIGIN_SIZE.width / 1.2, BOOK_COVER_ORIGIN_SIZE.height / 1.2)];
    [bookCover setImage:[UIImage imageNamed:@"book_placeholder"]];
    [coverView addSubview:bookCover];
    
    finishMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [finishMark setImage:[UIImage imageNamed:@"finish_mark"]];
    [finishMark setBackgroundColor:[UIColor clearColor]];
    [bookCover addSubview:finishMark];
    [finishMark setHidden:YES];
    
    NSArray *labelTitles = @[@"",@"作者:",@"类别:",@"大小:",@"月票", @"更新:",@"",@"",@"",@""];
    NSArray *giftImages = @[@"demand" ,@"flower", @"money", @"comment"];
    NSMutableArray *labelsArray = [NSMutableArray array];
    int k = 0;
    float WIDTH = coverView.frame.size.width - 20;
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
        [coverView addSubview:label];
        [labelsArray addObject:label];
    }
    bookNameLabel = labelsArray[0];
    authorNameLabel = labelsArray[1];
    catagoryNameLabel = labelsArray[2];
    wordsLabel = labelsArray[3];
    monthTicket = labelsArray[4];
    lastUpdateLabel = labelsArray[5];
    diamondLabel = labelsArray[6];
    flowerLabel = labelsArray[7];
    rewardLabel = labelsArray[8];
    commentLabel = labelsArray[9];
    
    float three_btn_width = (coverView.frame.size.width - 4 * 5)/3;
    NSArray *buttonNames = @[@"阅读", @"收藏", @"投月票"];
    NSArray *selectorString = @[@"readButtonClicked:", @"favButtonClicked:", @"buttonClicked:"];
    for (int i = 0; i < [buttonNames count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(5 * (i + 1) + three_btn_width * i, CGRectGetMaxY(commentLabel.frame)+10, three_btn_width, 40)];
        [button addTarget:self action:NSSelectorFromString(selectorString[i]) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
        [button setTitle:buttonNames[i] forState:UIControlStateNormal];
        if (i==1) {
            favButton = button;
        }
        [coverView addSubview:button];
    }
    
    shortdescribeTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(favButton.frame)+10, coverView.frame.size.width-5 * 2, 150)];
    [shortdescribeTextView setEditable:NO];
    [shortdescribeTextView setTextColor:[UIColor bookStoreTxtColor]];
    [shortdescribeTextView setFont:[UIFont systemFontOfSize:15]];
    [shortdescribeTextView setBackgroundColor:[UIColor clearColor]];
    [coverView addSubview:shortdescribeTextView];
    
    commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(shortdescribeTextView.frame)+5, coverView.frame.size.width - 5 *2, 40)];
    [commentTitle setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [commentTitle setFont:[UIFont boldSystemFontOfSize:15]];
    [commentTitle.layer setBorderWidth:0.5];
    [commentTitle.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [commentTitle setText:@"\t\t书评"];
    [coverView addSubview:commentTitle];
    
    shortInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(commentTitle.frame) + 5, coverView.frame.size.width - 5 * 2, 320) style:UITableViewStylePlain];
    [shortInfoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin];
    [shortInfoTableView setDelegate:self];
    [shortInfoTableView setDataSource:self];
    [shortInfoTableView setBackgroundColor:[UIColor clearColor]];
    [shortInfoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [coverView addSubview:shortInfoTableView];
    
    recommendTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(shortInfoTableView.frame)+5, coverView.frame.size.width - 5 *2, 40)];
    [recommendTitle setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [recommendTitle setFont:[UIFont boldSystemFontOfSize:15]];
    [recommendTitle.layer setBorderWidth:0.5];
    [recommendTitle.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [recommendTitle setText:@"\t\t同类推荐"];
    [coverView addSubview:recommendTitle];
    
    recommendTableView = [[UITableView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(recommendTitle.frame) + 5, coverView.frame.size.width - 5 * 2, 260) style:UITableViewStylePlain];
    [recommendTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [recommendTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [recommendTableView setBackgroundColor:[UIColor clearColor]];
    [recommendTableView setDelegate:self];
    [recommendTableView setDataSource:self];
    [coverView addSubview:recommendTableView];
    
    infoTableView = [[UITableView alloc]initWithFrame:commentView.bounds style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setDataSource:self];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [commentView addSubview:infoTableView];
    
    UIView *commentHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoTableView.frame.size.width, 50 * 3.5)];
    [commentHeaderView setBackgroundColor:[UIColor clearColor]];
    
    commitField = [[UITextView alloc] initWithFrame:CGRectMake(12, 17.5, infoTableView.frame.size.width - 12 * 2, 35 * 3 * 0.8)];
    //    [commitField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [commitField.layer setCornerRadius:5];
    [commitField setDelegate:self];
    [commitField setReturnKeyType:UIReturnKeyDone];
    [commitField.layer setBorderColor:[UIColor blackColor].CGColor];
    [commitField.layer setBorderWidth:0.5];
    [commitField setBackgroundColor:[UIColor whiteColor]];
    [commentHeaderView addSubview:commitField];
    
    UIButton *sendCommitbutton = [UIButton createButtonWithFrame:CGRectMake(CGRectGetMaxX(commitField.frame) - 60, CGRectGetMaxY(commitField.frame) + 10, 60, 35)];
    [sendCommitbutton addTarget:self action:@selector(sendCommitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [sendCommitbutton setTitle:@"发表" forState:UIControlStateNormal];
    [sendCommitbutton setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
    [commentHeaderView addSubview:sendCommitbutton];
    
    [infoTableView setTableHeaderView:commentHeaderView];
    
    chapterListTableView = [[UITableView alloc]initWithFrame:chapterListView.bounds style:UITableViewStylePlain];
    [chapterListTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [chapterListTableView setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:248.0/255.0 blue:245.0/255.0 alpha:1.0]];
    [chapterListTableView setBackgroundColor:[UIColor whiteColor]];
    [chapterListTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [chapterListTableView setDelegate:self];
    [chapterListTableView setDataSource:self];
    [chapterListView addSubview:chapterListTableView];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 210, fullSize.height - 150, 20)];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth];
    [slider setThumbImage:[UIImage imageNamed:@"thumb_image"] forState:UIControlStateNormal];
    [slider setMinimumTrackTintColor:[UIColor clearColor]];
    [slider setMaximumTrackTintColor:[UIColor clearColor]];
    [slider.layer setBorderColor:[UIColor clearColor].CGColor];
    [slider setMinimumValue:0];
    [slider setMaximumValue:100];
    [chapterListView addSubview:slider];
    
    for (int i = 0; i < [slider.subviews count]; i++) {
        if (i != 2) {
            UIView *view = slider.subviews[i];
            view.hidden = YES;
        }
    }
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI * (-1.5));
	[slider setTransform:rotation];
    [slider setFrame:CGRectMake(CGRectGetMaxX(chapterListTableView.bounds) - 30, 0, 20, chapterListView.bounds.size.height)];
    
    authorBookTableView = [[UITableView alloc]initWithFrame:authorBookView.bounds style:UITableViewStylePlain];
    [authorBookTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [authorBookTableView setBackgroundColor:[UIColor clearColor]];
    [authorBookTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [authorBookTableView setDelegate:self];
    [authorBookTableView setDataSource:self];
    [authorBookView addSubview:authorBookTableView];
}

- (void)refreshCoverViewFrame
{
    [commentTitle setFrame:CGRectMake(5, CGRectGetMaxY(shortdescribeTextView.frame)+5, coverView.frame.size.width - 5 *2, 40)];
    [shortInfoTableView setFrame:CGRectMake(5, CGRectGetMaxY(commentTitle.frame) + 5, coverView.frame.size.width - 5 * 2, shortInfoTableView.contentSize.height)];
    [recommendTitle setFrame:CGRectMake(5, CGRectGetMaxY(shortInfoTableView.frame)+5, coverView.frame.size.width - 5 *2, 40)];
    [recommendTableView setFrame:CGRectMake(5, CGRectGetMaxY(recommendTitle.frame) + 5, coverView.frame.size.width - 5 * 2, recommendTableView.contentSize.height)];
    [coverView setContentSize:CGSizeMake(coverView.frame.size.width, CGRectGetMaxY(recommendTableView.frame))];
}

- (void)mainButtonClicked
{
    [APP_DELEGATE gotoRootController:kRootControllerTypeBookStore];
}

- (void)initBookDetailUI
{
    self.title = @"书籍详情";
    NSURL *url = [NSURL URLWithString:book.coverURL];
    UIImageView *tmpImageView = bookCover;
    [bookCover setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:[UIImage imageNamed:@"book_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [tmpImageView setImage:image];
        book.cover = UIImageJPEGRepresentation(image, 1.0);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    //    self.title = book.name;
    
    NSString *bookName = book.name;
    NSString *authorName = [@"作者: " stringByAppendingString:book.author];
    NSString *catagoryName = [@"类别: " stringByAppendingString:book.category];
    NSString *words = [@"大小: " stringByAppendingString:[book.words stringValue]];
    NSString *lastUpdate = [@"更新: " stringByAppendingString:book.lastUpdate];
    NSString *diamondAmount = [NSString stringWithFormat:@"%@",book.diamond];
    NSString *flowerAmount = [NSString stringWithFormat:@"%@",book.flower];
    NSString *rewardAmount = [NSString stringWithFormat:@"%@",book.reward];
    NSString *commentAmount = [NSString stringWithFormat:@"%@",book.comment];
    NSString *monthTicketAmount = [NSString stringWithFormat:@"月票: %@",book.monthTicket];
    
    NSArray *labelTitles = @[bookName,authorName,catagoryName,words,monthTicketAmount,lastUpdate,diamondAmount,flowerAmount,rewardAmount,commentAmount];
    NSArray *labels = @[bookNameLabel,authorNameLabel,catagoryNameLabel,wordsLabel,monthTicket,lastUpdateLabel,diamondLabel,flowerLabel,rewardLabel,commentLabel];
    for (int i = 0; i<[labels count]; i++) {
        UIButton *label = (UIButton *)labels[i];
        [label setTitle:labelTitles[i] forState:UIControlStateNormal];
    }
	
    if ([book.bFinish isEqualToString:@"已完成"]) {
        [finishMark setHidden:NO];
    }
    
    if ([ServiceManager userID] != nil) {
        [ServiceManager existsFavoriteWithBookID:bookid withBlock:^(BOOL isExist, NSError *error) {
            if (error) {
                
            } else {
                if (isExist) {
                    bFav = YES;
					[favButton setEnabled:NO];
					[favButton setTitle:@"已收藏" forState:UIControlStateNormal];
                }
            }
        }];
    }
    
    [shortdescribeTextView setText:book.describe];
    CGFloat height = shortdescribeTextView.contentSize.height;
    CGRect rect = shortdescribeTextView.frame;
    rect.size.height = height;
    [shortdescribeTextView setFrame:rect];
    
    [self loadShortCommitList];
    [self loadSameType];
	self.gestureRecognier.enabled = NO;
}

- (void)getChaptersDataWithBlock:(dispatch_block_t)block
{
    [book persistWithBlock:^(void) {//下载章节目录
        [self displayHUD:@"获取章节目录..."];
        [ServiceManager bookCatalogueList:book.uid withBlock:^(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime) {
			[self hideHUD:YES];
            if (!error) {
                NSLog(@"%@",nextUpdateTime);
                chapterArray = [resultArray mutableCopy];
                [chapterListTableView reloadData];
                if (block) block();
            } else {
                [self displayHUDError:@"获取章节目录失败" message:error.debugDescription];
            }
        }];
    }];
}

- (void)readButtonClicked:(id)sender
{
    if ([chapterArray count] > 0) {
        [self pushToReadView];
        return;
    } else {
        [self getChaptersDataWithBlock:^{
            [Chapter persist:chapterArray withBlock:^{
				[self hideHUD:YES];
                [self pushToReadView];
            }];
        }];
    }
}

- (void)favButtonClicked:(id)sender
{
    [self addFav];
}

- (void)buttonClicked:(id)sender
{
    [self pushToGiftViewWithIndex:@"0"];
}

- (void)loadAuthorOtherBook
{
    [ServiceManager otherBooksFromAuthor:book.authorID andCount:@"5" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (error) {
            
        }
        else
        {
            if ([authorBookArray count]>0) {
                [authorBookArray removeAllObjects];
            }
            for (int i = 0 ; i<[resultArray count]; i++) {
                Book *obj = [resultArray objectAtIndex:i];
                if([obj.uid integerValue]!=[bookid integerValue]) {
                    [authorBookArray addObject:obj];
                }
            }
            if ([authorBookArray count] == 0) {
                [authorBookTableView setTableHeaderView:emptyLabel];
            }
            [authorBookTableView reloadData];
        }
    }];
}

- (void)loadSameType
{
    [ServiceManager bookRecommend:book.categoryID.integerValue andCount:@"5" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (error) {
            
        }
        else {
            if ([sameTypeBookArray count]>0) {
                [sameTypeBookArray removeAllObjects];
            }
            for (int i = 0 ; i<[resultArray count]; i++) {
                Book *obj = [resultArray objectAtIndex:i];
                if([obj.uid integerValue]!=[bookid integerValue]) {
                    [sameTypeBookArray addObject:obj];
                }
            if ([sameTypeBookArray count]==4) {
                break;
            }
        }
        [recommendTableView reloadData];
        [self refreshCoverViewFrame];
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
    [commitField resignFirstResponder];
    if ([self checkLogin] == NO) {
        return;
    }
    if ([commitField.text length] <= 5) {
        [self displayHUDError:nil message:@"评论内容太短!"];
        return;
    }
	
    [ServiceManager disscussWithBookID:bookid andContent:commitField.text withBlock:^(BOOL success, NSError *error, NSString *message) {
        if (error) {
            
        }
        else {
            commitField.text = @"";
            [self displayHUDError:nil message:message];
            [self loadCommitList];
            [shortInfoArray removeAllObjects];
            [self loadShortCommitList];
        }
    }];
}

- (void)loadShortCommitList
{
    [ServiceManager bookDiccusssListByBookId:bookid size:@"6" andIndex:@"1" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (error){
        } else {
            [shortInfoArray addObjectsFromArray:resultArray];
            [shortInfoTableView reloadData];
            [self refreshCoverViewFrame];
        }
    }];
}

- (void)loadCommitList
{
	[infoArray removeAllObjects];
    [ServiceManager bookDiccusssListByBookId:bookid size:@"10" andIndex:@"1" withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (error){
        } else {
            if ([resultArray count] == 10) {
                [self addFootView];
                currentIndex++;
            }
            [infoArray addObjectsFromArray:resultArray];
            [infoTableView reloadData];
        }
    }];
}

- (void)pushToReadView
{
    CoreTextViewController *controller = [[CoreTextViewController alloc] init];
	controller.book = book;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushToReadViewWithChapter:(Chapter *)obj
{
    [Chapter persist:chapterArray withBlock:^{
        CoreTextViewController *controller = [[CoreTextViewController alloc] init];
        controller.book = book;
        controller.bDetail = YES;
        [controller gotoChapter:obj withReadIndex:nil];
        [self.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)pushToGiftViewWithIndex:(NSString *)index {
    if ([self checkLogin]) {
        GiftViewController *giftViewController = [[GiftViewController alloc] initWithIndex:index andBook:book];
        [self.navigationController pushViewController:giftViewController animated:YES];
    }
}

- (BOOL)checkLogin
{
    if (![ServiceManager userID]) {
        [self showLoginAlert];
        return NO;
    } else {
        return YES;
    }
}

- (void)addFav
{
    if ([self checkLogin]) {
		[self displayHUD:@"请稍等..."];
        [ServiceManager addFavoriteWithBookID:bookid On:YES withBlock:^(BOOL success, NSError *error,NSString *message) {
            if (!error) {
                if (success) {
                    bFav = YES;
					book.bFav = @(YES);
                    [favButton setTitle:@"已收藏" forState:UIControlStateNormal];
                    [favButton setEnabled:NO];
					[book persistWithBlock:^(void) {
						[self displayHUDError:nil message:message];
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:NEED_REFRESH_BOOKSHELF];
					}];
                }
            } else {
                [self displayHUDError:nil message:NETWORK_ERROR];
            }
        }];
    }
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == infoTableView) {
        return [infoArray count];
    } else if (tableView == shortInfoTableView) {
        return [shortInfoArray count];
    } else if (tableView == recommendTableView) {
        return [sameTypeBookArray count];
    } else if (tableView == chapterListTableView) {
        return [chapterArray count];
    } else if (tableView == authorBookTableView){
        return [authorBookArray count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == infoTableView||tableView == shortInfoTableView){
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
    
    if (tableView == infoTableView) {
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            Comment *obj = [infoArray objectAtIndex:[indexPath row]];
            [(CommentCell *)cell setComment:obj];
        }
    } else if (tableView == shortInfoTableView) {
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            Comment *obj = [shortInfoArray objectAtIndex:[indexPath row]];
            [(CommentCell *)cell setComment:obj];
        }
    } else if (tableView == chapterListTableView) {
        if (cell == nil) {
            cell = [[ChapterCell alloc] initWithStyle:BookCellStyleCatagory reuseIdentifier:@"MyCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            Chapter *obj = [chapterArray objectAtIndex:[indexPath row]];
            [(ChapterCell *)cell setChapter:obj andCurrent:NO];
            //            cell.detailTextLabel.text = chapter.bVip.boolValue ? @"v" : @"";
        }
    }
    else {
        if (cell == nil) {
            NSArray *tmpArray = [NSArray array];
            tmpArray = tableView == recommendTableView ? sameTypeBookArray : authorBookArray;
            cell = [[BookCell alloc] initWithStyle:BookCellStyleBig reuseIdentifier:@"MyCell"];
            Book *obj = [tmpArray objectAtIndex:[indexPath row]];
            //            obj.author = book.author;
            if (tableView == authorBookTableView) {
                obj.author = nil;
            }
            [(BookCell *)cell setBook:obj];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == recommendTableView||tableView == authorBookTableView) {
		NSArray *booksArray = tableView == authorBookTableView ? authorBookArray : sameTypeBookArray;
		Book *b = booksArray[indexPath.row];
		BookDetailsViewController *childViewController = [[BookDetailsViewController alloc] initWithBook:b.uid];
		[self.navigationController pushViewController:childViewController animated:YES];
	} else if (tableView == chapterListTableView) {
        [self pushToReadViewWithChapter:chapterArray[indexPath.row]];
    }
}

- (void)addFootView
{
    UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
    [infoTableView setTableFooterView:footview];
}

- (void)getMore
{
    //    [self displayHUD:@"加载中..."];
    [ServiceManager bookDiccusssListByBookId:bookid size:@"10" andIndex:[NSString stringWithFormat:@"%d",currentIndex] withBlock:^(BOOL success, NSError *error, NSArray *resultArray) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        } else {
            if ([infoArray count] == 0) {
                [infoTableView setTableFooterView:nil];
            }
            [infoArray addObjectsFromArray:resultArray];
            currentIndex++;
            [infoTableView reloadData];
            bLoading = NO;
            //            [self hideHUD:YES];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (bCommit) {
        if(scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height - 70) {
            if (!bLoading) {
                bLoading = YES;
                NSLog(@"可刷新");
                [self getMore];
            }
        }
    } else if (bChapter){
        [chapterListTableView setContentOffset:CGPointMake(0, chapterListTableView.contentOffset.y)];
        slider.value = 100.0 * chapterListTableView.contentOffset.y / (chapterListTableView.contentSize.height - 460);
    }
}

- (void)sliderValueChanged:(id)sender {
	float offsetY = (slider.value / 100.0) * (chapterListTableView.contentSize.height - 460);
	[chapterListTableView setContentOffset:CGPointMake(0, offsetY)];
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

- (void)showLoginAlert
{
	PopLoginViewController *popLoginViewController = [[PopLoginViewController alloc] init];
	[self addChildViewController:popLoginViewController];
	[self.view addSubview:popLoginViewController.view];
}

@end
