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

#define AUTHORBOOK      1
#define OTHERBOOK       2

@implementation BookDetailsViewController
{
    NSString *bookid;
    Book *book;
    int currentIndex;
    int currentType;
    
    UITextField *commitField;
    UIView *secondView;
    UIButton *sendCommitButton;
    UITextView *shortdescribeTextView;
    UITableView *infoTableView;
    UITableView *recommendTableView;
    
    NSMutableArray *infoArray;
    NSMutableArray *authorBookArray;
    NSMutableArray *sameTypeBookArray;
    BOOL bFav;
    
    UIButton *shortDescribe;
    UIButton *comment;
    UIButton *authorBook;
    UIButton *bookRecommend;
	
    UIButton *readButton;
	UIButton *favoriteButton;
    UIButton *giveDemand;
    UIButton *giveFlower;
    UIButton *giveMoney;
    UIButton *giveMonthTicket;
    UIButton *giveComment;
}

- (id)initWithBook:(NSString *)uid
{
    self = [super init];
    if (self) {
        bookid = uid;
        infoArray = [[NSMutableArray alloc] init];
        authorBookArray = [[NSMutableArray alloc] init];
        sameTypeBookArray = [[NSMutableArray alloc] init];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:book.name];
}

- (void)initBookDetailUI {
    UIView *firstBkgView = [[UIView alloc] initWithFrame:CGRectMake(5, 50, self.view.bounds.size.width-5*2, 180)];
    [firstBkgView.layer setCornerRadius:4];
    [firstBkgView.layer setMasksToBounds:YES];
    [firstBkgView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:firstBkgView];
    
    UIImageView *bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 90, 120)];
    NSURL *url = [NSURL URLWithString:book.coverURL];
    UIImageView *tmpImageView = bookCover;
    [bookCover setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:[UIImage imageNamed:@"book_placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [tmpImageView setImage:image];
        book.cover = UIImageJPEGRepresentation(image, 1.0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [firstBkgView addSubview:tmpImageView];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    UILabel *bookNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, firstBkgView.bounds.size.width-100, 30)];
    [bookNameLabel setText:[@"  " stringByAppendingString:book.name]];
    [bookNameLabel setBackgroundColor:[UIColor clearColor]];
    [firstBkgView addSubview:bookNameLabel];
    
    NSArray *labelTitles = @[@"  作者:  ", @"  类别:  ", @"  字数:  ", @"  更新时间:  "];
    NSArray *labelNames = @[book.author,book.category,book.words,book.lastUpdate];//TODO: 万一有nil呢？ 随时准备crash是吗? Orz...
    
    for (int i = 0; i<[labelNames count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 30+20*i, firstBkgView.bounds.size.width-100, 20)];
        [label setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:[NSString stringWithFormat:@"%@%@",labelTitles[i],labelNames[i]]];
        [firstBkgView addSubview:label];
    }
    NSArray *buttonTitles = @[@"阅读",@"收藏",@"推荐"];
    NSArray *imageNames = @[@"gift_demand" , @"gift_flower" ,@"gift_money" ,@"gift_monthticket" ,@"gift_comment"];
    NSArray *selStrings = @[@"readButtonClicked:", @"favButtonClicked:", @"smsShareButtonClicked:", @"buttonClicked:"];
	NSMutableArray *buttons = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        UIButton *button = nil;
        if (i >= 3) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(5*(i-3)+290/5*(i-3), 150, 290/5, 20)];
            [button setImage:[UIImage imageNamed:imageNames[i-3]] forState:UIControlStateNormal];
        }else {
            button = [UIButton createButtonWithFrame:CGRectMake(110+70*i, 120, 50, 20)];
            [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
        }
        [button addTarget:self action:NSSelectorFromString(i >= 3 ? selStrings[3] : selStrings[i]) forControlEvents:UIControlEventTouchUpInside];
        [firstBkgView addSubview:button];
		[buttons addObject:button];
    }
	
    readButton = buttons[0];
	favoriteButton = buttons[1];
    giveDemand = buttons[2];
    giveFlower = buttons[3];
    giveMoney = buttons[4];
    giveMonthTicket = buttons[5];
    giveComment = buttons[6];
	
    if ([ServiceManager userID] != nil) {
        [ServiceManager existsFavoriteWithBookID:bookid withBlock:^(BOOL isExist, NSError *error) {
            if (error) {
                
            } else {
                if (isExist) {
                    bFav = YES;
					[favoriteButton setDisabled:YES];
					[favoriteButton setTitle:@"已收藏" forState:UIControlStateNormal];
                }
            }
        }];
    }
    
    secondView = [[UIView alloc] initWithFrame:CGRectMake(5, 244 ,self.view.bounds.size.width-5*2 , self.view.bounds.size.height-244-20)];
    [secondView.layer setCornerRadius:4];
    [secondView.layer setMasksToBounds:YES];
    [secondView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:secondView];
    
    NSArray *btnNames = @[@"简介" ,@"评论" ,@"作者书籍", @"同类推荐"];
    NSArray *btnObjs = @[shortDescribe, comment ,authorBook, bookRecommend];
    for (int i = 0; i<[btnNames count]; i++) {
        UIButton *button = btnObjs[i];
        [button.layer setBorderWidth:0.5];
        [button.layer setBorderColor: i==0 ? [UIColor clearColor].CGColor : [UIColor blackColor].CGColor];
        [button setTitleColor:[UIColor hexRGB:0xfbbf90] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(i*secondView.frame.size.width/4, 0, secondView.frame.size.width/4, 30)];
        [button addTarget:self action:@selector(selectTabBar:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:btnNames[i] forState:UIControlStateNormal];
        [secondView addSubview:button];
    }
    currentType = AUTHORBOOK;
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30,secondView.frame.size.width , secondView.frame.size.height-60) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setDataSource:self];
    [secondView addSubview:infoTableView];
    [self loadCommitList];
    
    sendCommitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendCommitButton.layer setBorderWidth:0.5];
    [sendCommitButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [sendCommitButton.layer setCornerRadius:4];
    [sendCommitButton.layer setMasksToBounds:YES];
    [sendCommitButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sendCommitButton setFrame:CGRectMake(15, infoTableView.frame.size.height+30, secondView.frame.size.width-15*2, 30)];
    [sendCommitButton setTitle:@"+评论" forState:UIControlStateNormal];
    [sendCommitButton addTarget:self action:@selector(sendCommitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:sendCommitButton];
    
    recommendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30,secondView.frame.size.width , secondView.frame.size.height-30) style:UITableViewStylePlain];
    [recommendTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [recommendTableView setBackgroundColor:[UIColor whiteColor]];
    [recommendTableView setDelegate:self];
    [recommendTableView setDataSource:self];
    [secondView addSubview:recommendTableView];
    
    [self loadAuthorOtherBook];
    [self loadSameType];
    
    shortdescribeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 30,secondView.frame.size.width , secondView.frame.size.height-30)];
    [shortdescribeTextView setText:book.describe];
    [shortdescribeTextView setEditable:NO];
    [secondView addSubview:shortdescribeTextView];
    
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

- (void)buttonClicked:(UIButton *)sender
{
	NSInteger index = 0;
    if (sender == giveDemand) {
        index = 0;
    } else if (sender == giveFlower) {
        index = 1;
    } else if (sender == giveMoney) {
        index = 2;
    } else if (sender == giveMonthTicket) {
        index = 3;
    } else if (sender == giveComment) {
        index = 4;
    }
    [self pushToGiftViewWithIndex:@(index).stringValue];
}

- (void)selectTabBar:(UIButton *)sender
{
    
    NSArray *btnObjs = @[shortDescribe, comment ,authorBook, bookRecommend];
    for (int i = 0; i<4; i++) {
        UIButton *button = (UIButton *)btnObjs[i];
        [button.layer setBorderColor:sender==button ? [UIColor clearColor].CGColor : [UIColor blackColor].CGColor];
    }
    if (sender == shortDescribe) {
        [secondView bringSubviewToFront:shortdescribeTextView];
    } else if (sender == comment) {
        [secondView bringSubviewToFront:sendCommitButton];
        [secondView bringSubviewToFront:infoTableView];
    } else if (sender == authorBook) {
        currentType = AUTHORBOOK;
        [recommendTableView reloadData];
        [secondView bringSubviewToFront:recommendTableView];
    } else if (sender == bookRecommend) {
        currentType = OTHERBOOK;
        [recommendTableView reloadData];
        [secondView bringSubviewToFront:recommendTableView];
    }
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
            [recommendTableView reloadData];
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
					favoriteButton.enabled = YES;
					[favoriteButton setTitle:@"已经收藏" forState:UIControlStateNormal];
					book.bFav = @(YES);
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
    } else {
        if (currentType == AUTHORBOOK) {
            return [authorBookArray count];
        } else {
            return [sameTypeBookArray count];
        }
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == infoTableView) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    } else if (indexPath.row == 0) {
        return [BookCell height];
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
            Comment *obj = [infoArray objectAtIndex:[indexPath row]];
            [(CommentCell *)cell setComment:obj];
        }
    } else {
        if (cell == nil) {
            BookCellStyle style = BookCellStyleSmall;
            if (indexPath.row ==0) {
                style = BookCellStyleBig;
            }
            if (currentType == AUTHORBOOK) {
                cell = [[BookCell alloc] initWithStyle:style reuseIdentifier:@"MyCell"];
                Book *obj = [authorBookArray objectAtIndex:[indexPath row]];
                obj.author = book.author;
                [(BookCell *)cell setBook:obj];
            } else {
                cell = [[BookCell alloc] initWithStyle:style reuseIdentifier:@"MyCell"];
                Book *obj = [sameTypeBookArray objectAtIndex:[indexPath row]];
                [(BookCell *)cell setBook:obj];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView != infoTableView) {
		NSArray *booksArray = currentType == AUTHORBOOK ? authorBookArray : sameTypeBookArray;
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
