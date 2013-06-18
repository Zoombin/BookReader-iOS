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
#import "BookReader.h"

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
    
    UILabel *authorNameLabel;
    UILabel *catagoryNameLabel;
    UILabel *wordsLabel;
    UILabel *lastUpdateLabel;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:book.name];
     CGSize fullSize = self.view.bounds.size; 
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(4, 46, fullSize.width-8, self.view.bounds.size.height-56)];
    [backgroundView.layer setCornerRadius:5];
    [backgroundView.layer setMasksToBounds:YES];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:246.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [self.view addSubview:backgroundView];
    
     bookCover = [[UIImageView alloc] initWithFrame:CGRectMake(10, 54, 90/1.2, 115/1.2)];
    [bookCover setImage:[UIImage imageNamed:@"book_placeholder"]];
    [self.view addSubview:bookCover];
    
    UIButton *recommand = [UIButton buttonWithType:UIButtonTypeCustom];
    [recommand setBackgroundImage:[UIImage imageNamed:@"recommandtofriend"] forState:UIControlStateNormal];
    [recommand setFrame:CGRectMake(CGRectGetMinX(bookCover.frame), CGRectGetMaxY(bookCover.frame)-25, bookCover.frame.size.width, 25)];
    [recommand.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [recommand addTarget:self action:@selector(smsShareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [recommand setTitle:@"推荐给好友" forState:UIControlStateNormal];
    [self.view addSubview:recommand];
    
    UIButton *readButton = [UIButton custumButtonWithFrame:CGRectMake(fullSize.width-100, 6, 48, 32)];
    [readButton setTitle:@"阅读" forState:UIControlStateNormal];
    [readButton addTarget:self action:@selector(readButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readButton];
    
    favButton = [UIButton custumButtonWithFrame:CGRectMake(CGRectGetMaxX(readButton.frame), 6, 48, 32)];
    [favButton setTitle:@"收藏" forState:UIControlStateNormal];
    [favButton addTarget:self action:@selector(favButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:favButton];

    NSArray *labelTitles = @[@"作者:",@"类别:",@"字数:",@"更新时间:"];
    NSMutableArray *labelsArray = [NSMutableArray array];
    for (int i = 0; i<[labelTitles count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 85+15*i,fullSize.width-100, 15)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor grayColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setText:labelTitles[i]];
        [self.view addSubview:label];
        [labelsArray addObject:label];
    }
    authorNameLabel = labelsArray[0];
    catagoryNameLabel = labelsArray[1];
    wordsLabel = labelsArray[2];
    lastUpdateLabel = labelsArray[3];
    
    NSArray *imageNames = @[@"gift_demand" , @"gift_flower" ,@"gift_money" ,@"gift_monthticket" ,@"gift_comment"];
    NSArray *hightImages = @[@"gift_demand_hl" , @"gift_flower_hl" ,@"gift_money_hl" ,@"gift_monthticket_hl" ,@"gift_comment_hl"];
    for (int i = 0; i < 5; i++) {
        UIButton *button = nil;
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(8*(i+1)+(backgroundView.frame.size.width-6*8)/5*(i), 120, (backgroundView.frame.size.width-6*8)/5, 25)];
        [button setImage:[UIImage imageNamed:imageNames[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:hightImages[i]] forState:UIControlStateHighlighted];
        [button setTag:i];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:button];
    }
    
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(10, 155, backgroundView.frame.size.width - 20, 0.5)];
    [separateLine setBackgroundColor:[UIColor blackColor]];
    [backgroundView addSubview:separateLine];
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
    
    UILabel *bookNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 44, fullSize.width-100, 30)];
    [bookNameLabel setText:[@"  " stringByAppendingString:book.name]];
    [bookNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:bookNameLabel];
    
    NSString *authorName = [@"作者: " stringByAppendingString:book.author];
    NSString *catagoryName = [@"类别: " stringByAppendingString:book.category];
    NSString *words = [@"字数: " stringByAppendingString:[book.words stringValue]];
    NSString *lastUpdate = [@"更新时间: " stringByAppendingString:book.lastUpdate];
    NSArray *labelTitles = @[authorName,catagoryName,words,lastUpdate];
    NSArray *labels = @[authorNameLabel,catagoryNameLabel,wordsLabel,lastUpdateLabel];
    for (int i = 0; i<[labels count]; i++) {
        UILabel *label = (UILabel *)labels[i];
        [label setText:labelTitles[i]];
        [label setTextColor:[UIColor blackColor]];
        [self.view addSubview:label];
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
    
    secondView = [[UIView alloc] initWithFrame:CGRectMake(5, 234 ,self.view.bounds.size.width-5*2 , self.view.bounds.size.height-225-20)];
    [secondView.layer setCornerRadius:5];
    [secondView.layer setMasksToBounds:YES];
    [secondView.layer setBorderColor:[UIColor blackColor].CGColor];
    [secondView.layer setBorderWidth:0.5];
    [secondView setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:245.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [self.view addSubview:secondView];
    
    NSArray *btnNames = @[@"简介" ,@"评论" ,@"作者书籍", @"同类推荐"];
    NSArray *btnObjs = @[shortDescribe, comment ,authorBook, bookRecommend];
    for (int i = 0; i<[btnNames count]; i++) {
        UIButton *button = btnObjs[i];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        if (i==0) {
            [button setBackgroundImage:[UIImage imageNamed:@"bookdetail_btn"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        [button setFrame:CGRectMake(20+i*(self.view.frame.size.width-40)/4, 204, (self.view.frame.size.width-40)/4, 30)];
        [button addTarget:self action:@selector(selectTabBar:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:btnNames[i] forState:UIControlStateNormal];
        [self.view addSubview:button];
    }
    currentType = AUTHORBOOK;
    
    infoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,secondView.frame.size.width , secondView.frame.size.height) style:UITableViewStylePlain];
    [infoTableView setDelegate:self];
    [infoTableView setDataSource:self];
    [infoTableView setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:245.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [infoTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [secondView addSubview:infoTableView];
    [self loadCommitList];
    
    sendCommitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendCommitButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sendCommitButton setFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-50, 60, 50)];
    [sendCommitButton setBackgroundImage:[UIImage imageNamed:@"comment_btn"] forState:UIControlStateNormal];
    [sendCommitButton addTarget:self action:@selector(sendCommitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendCommitButton];
    [sendCommitButton setHidden:YES];
    
    recommendTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,secondView.frame.size.width , secondView.frame.size.height) style:UITableViewStylePlain];
    [recommendTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [recommendTableView setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:245.0/255.0 blue:241.0/255.0 alpha:1.0]];
    [recommendTableView setDelegate:self];
    [recommendTableView setDataSource:self];
    [secondView addSubview:recommendTableView];
    
    [self loadAuthorOtherBook];
    [self loadSameType];
    
    shortdescribeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,secondView.frame.size.width , secondView.frame.size.height)];
    [shortdescribeTextView setText:book.describe];
    [shortdescribeTextView setFont:[UIFont systemFontOfSize:17]];
    [shortdescribeTextView setEditable:NO];
    [shortdescribeTextView setBackgroundColor:[UIColor colorWithRed:250.0/255.0 green:245.0/255.0 blue:241.0/255.0 alpha:1.0]];
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
    [self pushToGiftViewWithIndex:@(sender.tag).stringValue];
}

- (void)selectTabBar:(UIButton *)sender
{
    [sendCommitButton setHidden:YES];
    NSArray *btnObjs = @[shortDescribe, comment ,authorBook, bookRecommend];
    for (int i = 0; i<4; i++) {
        UIButton *button = (UIButton *)btnObjs[i];
        if (sender == button) {
            [button setBackgroundImage:[UIImage imageNamed:@"bookdetail_btn"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    if (sender == shortDescribe) {
        [secondView bringSubviewToFront:shortdescribeTextView];
    } else if (sender == comment) {
        [self.view bringSubviewToFront:sendCommitButton];
        [sendCommitButton setHidden:NO];
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
	if (tableView != infoTableView) {
		BookCell *cell = (BookCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell height];
	} else {
        CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
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
    } else {
        if (cell == nil) {
            BookCellStyle style = BookCellStyleSmall;
            if (indexPath.row == 0) {
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
