//
//  BookDetailViewController.m
//  BookReader
//
//  Created by 颜超 on 13-3-27.
//  Copyright (c) 2013年 颜超. All rights reserved.
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

#define AUTHORBOOK      1
#define OTHERBOOK       2

@implementation BookDetailsViewController
{
    NSString *bookid;
    Book *book;
    int currentIndex;
    int currentType;
    
    UIScrollView *coverView;
    UIView *chapterListView;
    UIView *commentView;
    UIView *authorBookView;
    
    UITextField *commitField;
    UIView *secondView;
    UIButton *sendCommitButton;
    UITextView *shortdescribeTextView;
    UITableView *infoTableView;
    UITableView *shortInfoTableView;
    UITableView *recommendTableView;
    UITableView *authorBookTableView;
    
    NSMutableArray *infoArray;
    NSMutableArray *shortInfoArray;
    NSMutableArray *authorBookArray;
    NSMutableArray *sameTypeBookArray;
    BOOL bFav;
    
    UIButton *shortDescribe;
    UIButton *comment;
    UIButton *authorBook;
    UIButton *bookRecommend;
    
    UILabel *authorNameLabel;
    UILabel *catagoryNameLabel;
    UILabel *wordsLabel;
    UILabel *lastUpdateLabel;
    UILabel *lastChapterLabel;
    UILabel *bVipLabel;
    UILabel *bFinishLabel;
    
    UILabel *commentLabel;
    UILabel *flowerLabel;
    UILabel *diamondLabel;
    UILabel *rewardLabel;
    
    UIImageView *bookCover;
    
    UIButton *favButton;
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
        bFav = NO;
        currentIndex = 1;
        
        shortDescribe = [UIButton buttonWithType:UIButtonTypeCustom];
        comment = [UIButton buttonWithType:UIButtonTypeCustom];
        authorBook = [UIButton buttonWithType:UIButtonTypeCustom];
        bookRecommend = [UIButton buttonWithType:UIButtonTypeCustom];
        if([MFMessageComposeViewController canSendText]) {
            messageComposeViewController = [[MFMessageComposeViewController alloc] init];
        }
        // Custom initialization
    }
    return self;
}

- (void)smsShareButtonClicked:(id)sender {
    if([MFMessageComposeViewController canSendText]) {
        messageComposeViewController.messageComposeDelegate = self;
        NSString *message =  [NSString stringWithFormat:@"书名:%@ 作者:%@ 下载地址:http://www.xxsy.net",book.name,book.author];
        [messageComposeViewController setBody:[NSString stringWithString:message]];
        [self presentModalViewController:messageComposeViewController animated:YES];
    }
    else {
        [self displayHUDError:nil message:@"您的设备不能用来发短信！"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
		case MessageComposeResultCancelled:
			break;
		case MessageComposeResultSent:
			break;
		case MessageComposeResultFailed:
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (book == nil) {
        [self displayHUD:@"加载中..."];
        [ServiceManager bookDetailsByBookId:bookid andIntro:YES withBlock:^(Book *obj, NSError *error) {
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

- (void)coverButtonClicked
{
    NSLog(@"封面");
    [self.view bringSubviewToFront:coverView];
}

- (void)chapterButtonClicked
{
    NSLog(@"章节");
    [self.view bringSubviewToFront:chapterListView];
}

- (void)commentButtonClicked
{
    NSLog(@"评论");
    [self.view bringSubviewToFront:commentView];
}

- (void)authorButtonClicked
{
    NSLog(@"作者书籍");
    [self.view bringSubviewToFront:authorBookView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:book.name];
    CGSize fullSize = self.view.bounds.size;
    CGRect modelViewFrame = CGRectMake(4, 46 + 30, fullSize.width-8, self.view.bounds.size.height-56 - 30);
    
    BookShelfButton *bookShelfButton = [[BookShelfButton alloc] init];
    [bookShelfButton setFrame:CGRectMake(260, 3, 50, 32)];
    [self.view addSubview:bookShelfButton];
    
    for (int i = 0; i < 4; i++) {
        switch (i) {
            case 0:
                coverView = [[UIScrollView alloc] initWithFrame:modelViewFrame];
                [coverView setContentSize:CGSizeMake(coverView.frame.size.width, coverView.frame.size.height * 2)];
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
 
    NSArray *selectors =  @[@"coverButtonClicked",@"chapterButtonClicked",@"commentButtonClicked",@"authorButtonClicked"];
    NSInteger width = (fullSize.width-8)/4;
    NSArray *tabbarStrings = @[@"封面",@"目录",@"书评",@"作者作品"];
    for (int i = 0; i<[tabbarStrings count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:tabbarStrings[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor grayColor]];
        [button addTarget:self action:NSSelectorFromString(selectors[i]) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(4 + width * i, 46, width, 30)];
        [self.view addSubview:button];
    }
    
    bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 90/1.2, 115/1.2)];
    [bookCover setImage:[UIImage imageNamed:@"book_placeholder"]];
    [coverView addSubview:bookCover];
    
    NSArray *labelTitles = @[@"作者:",@"类别:",@"大小:",@"性质:",@"作品状态:",@"最新章节:",@"更新时间:",@"收到钻石",@"收到鲜花",@"收到打赏",@"收到评价"];
    NSMutableArray *labelsArray = [NSMutableArray array];
    for (int i = 0; i<[labelTitles count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i > 4 ? 10 : 100, 15 + 20 * i,fullSize.width-50, 15)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setText:labelTitles[i]];
        [coverView addSubview:label];
        [labelsArray addObject:label];
    }
    authorNameLabel = labelsArray[0];
    catagoryNameLabel = labelsArray[1];
    wordsLabel = labelsArray[2];
    bVipLabel = labelsArray[3];
    bFinishLabel = labelsArray[4];
    lastChapterLabel = labelsArray[5];
    lastUpdateLabel = labelsArray[6];
    diamondLabel = labelsArray[7];
    flowerLabel = labelsArray[8];
    rewardLabel = labelsArray[9];
    commentLabel = labelsArray[10];
    
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
    
    shortdescribeTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(favButton.frame)+10, coverView.frame.size.width-5 * 2, 100)];
    [shortdescribeTextView setEditable:NO];
    [shortdescribeTextView setFont:[UIFont systemFontOfSize:15]];
    [shortdescribeTextView setBackgroundColor:[UIColor clearColor]];
    [coverView addSubview:shortdescribeTextView];
    
    UILabel *commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(shortdescribeTextView.frame)+5, coverView.frame.size.width - 5 *2, 40)];
    [commentTitle setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [commentTitle setFont:[UIFont boldSystemFontOfSize:15]];
    [commentTitle.layer setBorderWidth:0.5];
    [commentTitle.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [commentTitle setText:@"\t\t评论"];
    [coverView addSubview:commentTitle];
    
     shortInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(commentTitle.frame) + 5, coverView.frame.size.width - 5 * 2, 200) style:UITableViewStylePlain];
    [shortInfoTableView setDelegate:self];
    [shortInfoTableView setDataSource:self];
    [shortInfoTableView setBackgroundColor:[UIColor clearColor]];
    [shortInfoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [coverView addSubview:shortInfoTableView];
    
    UILabel *recommendTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(shortInfoTableView.frame)+5, coverView.frame.size.width - 5 *2, 40)];
    [recommendTitle setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:245.0/255.0 blue:238.0/255.0 alpha:1.0]];
    [recommendTitle setFont:[UIFont boldSystemFontOfSize:15]];
    [recommendTitle.layer setBorderWidth:0.5];
    [recommendTitle.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [recommendTitle setText:@"\t\t推荐"];
    [coverView addSubview:recommendTitle];
    
    recommendTableView = [[UITableView alloc]initWithFrame:CGRectMake(5, CGRectGetMaxY(recommendTitle.frame) + 5, coverView.frame.size.width - 5 * 2, 210) style:UITableViewStylePlain];
    [recommendTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [recommendTableView setBackgroundColor:[UIColor clearColor]];
    [recommendTableView setDelegate:self];
    [recommendTableView setDataSource:self];
    [coverView addSubview:recommendTableView];
    
    infoTableView = [[UITableView alloc]initWithFrame:commentView.bounds style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setDataSource:self];
    [infoTableView setBackgroundColor:[UIColor clearColor]];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [commentView addSubview:infoTableView];
    

    
    authorBookTableView = [[UITableView alloc]initWithFrame:authorBookView.bounds style:UITableViewStylePlain];
    [authorBookTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [authorBookTableView setBackgroundColor:[UIColor clearColor]];
    [authorBookTableView setDelegate:self];
    [authorBookTableView setDataSource:self];
    [authorBookView addSubview:authorBookTableView];
}

- (void)initBookDetailUI {
    self.title = @"图书详情";
    CGSize fullSize = self.view.bounds.size;
    
    NSURL *url = [NSURL URLWithString:book.coverURL];
    UIImageView *tmpImageView = bookCover;
    [bookCover setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:[UIImage imageNamed:@"book_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [tmpImageView setImage:image];
        book.cover = UIImageJPEGRepresentation(image, 1.0);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    self.title = book.name;
    
    NSString *authorName = [@"作者: " stringByAppendingString:book.author];
    NSString *catagoryName = [@"类别: " stringByAppendingString:book.category];
    NSString *words = [@"大小: " stringByAppendingString:[book.words stringValue]];
    NSString *lastUpdate = [@"更新时间: " stringByAppendingString:book.lastUpdate];
    NSString *lastChapterName = [@"最新章节:" stringByAppendingString:book.lastChapterName];
    NSString *bVipName = [@"性质:" stringByAppendingString:[book.bVip boolValue] ? @"VIP作品" : @"普通作品"];
    NSString *bFinishName = [@"作品状态:" stringByAppendingString:book.bFinish];
    NSString *diamondAmount = [NSString stringWithFormat:@"收到钻石%@颗",book.diamond];
    NSString *flowerAmount = [NSString stringWithFormat:@"收到鲜花%@朵",book.flower];
    NSString *rewardAmount = [NSString stringWithFormat:@"有%@打赏%@潇湘币",book.rewardPersons,book.reward];
    NSString *commentAmount = [NSString stringWithFormat:@"有%@人评价本书,总得分%@分",book.commentPersons,book.comment];
    
    NSArray *labelTitles = @[authorName,catagoryName,words,lastUpdate,lastChapterName,bVipName,bFinishName,diamondAmount,flowerAmount,rewardAmount,commentAmount];
    NSArray *labels = @[authorNameLabel,catagoryNameLabel,wordsLabel,lastUpdateLabel,lastChapterLabel,bVipLabel,bFinishLabel,diamondLabel,flowerLabel,rewardLabel,commentLabel];
    for (int i = 0; i<[labels count]; i++) {
        UILabel *label = (UILabel *)labels[i];
        [label setText:labelTitles[i]];
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
    
   
    [self loadShortCommitList];
    [self loadCommitList];
    

    
    [shortdescribeTextView setText:book.describe];
    
    [self loadAuthorOtherBook];
    [self loadSameType];
    [self removeGestureRecognizer];
}

- (void)readButtonClicked:(id)sender
{
   	[book persistWithBlock:^(void) {//下载章节目录
        [self displayHUD:@"获取章节目录..."];
        [ServiceManager bookCatalogueList:book.uid withBlock:^(NSArray *resultArray, NSError *error) {
            if (!error) {
                [Chapter persist:resultArray withBlock:^(void) {
					[self hideHUD:YES];
					[self pushToReadView];
                }];
            } else {
				[self hideHUD:YES];
                [self displayHUDError:@"获取章节目录失败" message:error.debugDescription];
            }
        }];
    }];
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
    [ServiceManager otherBooksFromAuthor:book.authorID andCount:@"5" withBlock:^(NSArray *resultArray, NSError *error) {
        if (error)
        {
            
        }
        else
        {
            if ([authorBookArray count]>0) {
                [authorBookArray removeAllObjects];
            }
            for (int i = 0 ; i<[resultArray count]; i++) {
                Book *obj = [resultArray objectAtIndex:i];
                if([obj.uid integerValue]!=[bookid integerValue])
                {
                    [authorBookArray addObject:obj];
                }
            }
            [authorBookTableView reloadData];
        }
    }];
}

- (void)loadSameType
{
    [ServiceManager bookRecommend:book.categoryID.integerValue andCount:@"5" withBlock:^(NSArray *resultArray, NSError *error) {
        if (error) {
            
        }
        else
        {
            if ([sameTypeBookArray count]>0) {
                [sameTypeBookArray removeAllObjects];
            }
            for (int i = 0 ; i<[resultArray count]; i++) {
                Book *obj = [resultArray objectAtIndex:i];
                if([obj.uid integerValue]!=[bookid integerValue])
                {
                    [sameTypeBookArray addObject:obj];
                }
            }
            [recommendTableView reloadData];
        }
    }];
}

- (void)sendCommitButtonClicked
{
    if ([self checkLogin] == NO)
        return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入评论内容"
                                                    message:@"评论内容在此输入"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"发送", nil];
    commitField = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    [commitField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:commitField];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [ServiceManager disscussWithBookID:bookid andContent:commitField.text withBlock:^(NSString *message, NSError *error)
         {
             if (error)
             {
                 
             }
             else
             {
                 [self showAlertWithMessage:message];
                 [self loadCommitList];
             }
         }];
    }
}

- (void)loadShortCommitList
{
    [ServiceManager bookDiccusssListByBookId:bookid size:@"6" andIndex:@"1" withBlock:^(NSArray *resultArray, NSError *error) {
        if (error){
        } else {
            [shortInfoArray addObjectsFromArray:resultArray];
            [shortInfoTableView reloadData];
        }
    }];
}

- (void)loadCommitList
{
	[infoArray removeAllObjects];
    [ServiceManager bookDiccusssListByBookId:bookid size:@"10" andIndex:@"1" withBlock:^(NSArray *resultArray, NSError *error) {
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

- (void)pushToGiftViewWithIndex:(NSString *)index {
    if ([self checkLogin]) {
        GiftViewController *giftViewController = [[GiftViewController alloc] initWithIndex:index andBook:book];
        [self.navigationController pushViewController:giftViewController animated:YES];
    }
}

- (BOOL)checkLogin
{
    if ([ServiceManager userID]==nil)
    {
        [self displayHUDError:nil message:@"您尚未登录!"];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)addFav
{
    if ([self checkLogin]) {
		[self displayHUD:@"请稍等..."];
        [ServiceManager addFavoriteWithBookID:bookid On:YES withBlock:^(BOOL success,NSString *message, NSError *error) {
            if (!error) {
                if (success) {
                    bFav = YES;
					book.bFav = @(YES);
                    [favButton setTitle:@"已收藏" forState:UIControlStateNormal];
                    [favButton setEnabled:NO];
					[book persistWithBlock:^(void) {
						[self displayHUDError:nil message:message];
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNeedRefreshBookShelf];
					}];
                }
            } else {
                [self displayHUDError:nil message:NETWORK_ERROR];
            }
        }];
    }
}

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
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
    }
    else if (tableView == authorBookTableView){
        
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
	if (tableView == recommendTableView) {
		BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell height];
	} else if (tableView == infoTableView||tableView == shortInfoTableView){
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
    }
    else {
        if (cell == nil) {
            NSArray *tmpArray = [NSArray array];
            tmpArray = tableView == recommendTableView ? sameTypeBookArray : authorBookArray;
            BookCellStyle style = BookCellStyleSmall;
            if (indexPath.row == 0) {
                style = BookCellStyleBig;
            }
            cell = [[BookCell alloc] initWithStyle:style reuseIdentifier:@"MyCell"];
            Book *obj = [tmpArray objectAtIndex:[indexPath row]];
            obj.author = book.author;
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
	}
}

- (void)addFootView
{
    UIView *footview = [UIView tableViewFootView:CGRectMake(-4, 0, 316, 26) andSel:NSSelectorFromString(@"getMore") andTarget:self];
    [infoTableView setTableFooterView:footview];
}

- (void)getMore
{
    [self displayHUD:@"加载中..."];
    [ServiceManager bookDiccusssListByBookId:bookid size:@"10" andIndex:[NSString stringWithFormat:@"%d",currentIndex] withBlock:^(NSArray *resultArray, NSError *error) {
        if (error) {
            [self displayHUDError:nil message:NETWORK_ERROR];
        } else {
            if ([infoArray count] == 0) {
                [infoTableView setTableFooterView:nil];
            }
            [infoArray addObjectsFromArray:resultArray];
            currentIndex++;
            [infoTableView reloadData];
            [self hideHUD:YES];
        }
    }];
}

@end
