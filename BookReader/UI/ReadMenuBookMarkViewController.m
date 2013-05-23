//
//  ReadMenuBookMarkViewController.m
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//


#define TOP_BAR_IMAGE [UIImage imageNamed:@"read_top_bar.png"]
#define BACKGROUND_IMAGE [UIImage imageNamed:@"read_more_background.png"]

#import "ReadMenuBookMarkViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BookManager.h"

@implementation ReadMenuBookMarkViewController

@synthesize bookMarkTableView;
@synthesize readViewController;
@synthesize bookmarkArray;
@synthesize chaptersArray;

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [super viewDidLoad];
    isbookmark = YES;
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:BACKGROUND_IMAGE];
    [self.view setBackgroundColor:backgroundColor];

    UIImageView *topBarImageView = [[UIImageView alloc] initWithImage:TOP_BAR_IMAGE];
    [topBarImageView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 42)];
    [self.view addSubview:topBarImageView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_menu_top_view_back_button.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5, 5, 63, 29)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
//    [self.view setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:238.0/255 blue:214.0/255.0 alpha:1.0]];
    
    bookMarkTableView = [[UITableView alloc] initWithFrame:CGRectMake(6, 58, self.view.bounds.size.width-12, self.view.bounds.size.height-38-20-50) style:UITableViewStylePlain];
    [bookMarkTableView setBackgroundColor:[UIColor clearColor]];
    bookMarkTableView.delegate = self;
    bookMarkTableView.dataSource = self;
    [bookMarkTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:bookMarkTableView];
    currentRow = NSIntegerMax;
    
    self.bookmarkArray = [NSMutableArray arrayWithArray:[[BookManager sharedInstance]getBookMarkArrayByBookId:bookid]];
    self.chaptersArray = [NSMutableArray arrayWithArray:[[BookManager sharedInstance]getchaptersByBookId:bookid]];
    
    
    
   
}

- (void)buttonClick:(id)sender {
    UIButton *button1 = (UIButton *)[self.view viewWithTag:1];
    UIButton *button2 = (UIButton *)[self.view viewWithTag:2];
    if ([sender tag]==1) {
        [button1 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
        isbookmark = YES;
    }else {
        [button1 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateNormal];
        isbookmark = NO;
    }
    [bookMarkTableView reloadData];
}


- (id)initBookWithUID:(NSString *)uid andPageArray:(NSMutableArray *)pageArray andText:(NSString *)booktext{
    self = [super init];
    if (self) {
        bookid = uid;
        text = booktext;
        pageArr = [[NSMutableArray alloc] init];
        [pageArr addObjectsFromArray:pageArray];
    }
    return self;
}

- (NSString *)checkhasContainWithChapter:(NSString *)chapter {
    for (int i=0; i<[pageArr count]; i++) {
        NSRange range = NSRangeFromString([pageArr objectAtIndex:i]);
        NSString *tempStr = [text substringWithRange:range];
        if ([tempStr rangeOfString:chapter].location!=NSNotFound) {
            return [pageArr objectAtIndex:i];
        }
    }
    return nil;
}


- (void)backButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    UITableViewCell * cell = [bookMarkTableView dequeueReusableCellWithIdentifier:cellIdentifier];  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if (isbookmark) {
            int row = [indexPath row];
            NSLog(@"row = %d", [indexPath row]);
            if([indexPath row] <= [bookmarkArray count]) {
                NSDictionary *bookmarkdict = [bookmarkArray objectAtIndex:row];
                
                NSString *str = [NSString stringWithFormat:@""];
                str = [str stringByAppendingFormat:@"%.2f%%", [[bookmarkdict objectForKey:@"percentage" ] floatValue]];
                str = [str stringByAppendingFormat:@"  %@", [bookmarkdict objectForKey:@"context"]];
                
                UIImageView *backgroundView = [[UIImageView alloc] init];
                [backgroundView setFrame:CGRectMake(2,1, self.view.bounds.size.width-14, 54)];
                [backgroundView setImage:[UIImage imageNamed:@"read_settingcellback"]];
                [cell.contentView addSubview:backgroundView];
                
                
                
                UILabel *textLabel = [[UILabel alloc] init];
                [textLabel setText:str];
                [textLabel setFrame:CGRectMake(10, 15, self.view.bounds.size.width-80, 30)];
                [textLabel setBackgroundColor:[UIColor clearColor]];
                [textLabel setFont:[UIFont systemFontOfSize:12.0]];
                [backgroundView addSubview:textLabel];
            }
        }else {
            int row = [indexPath row];
            NSLog(@"row = %d", [indexPath row]);
            if([indexPath row] <= [chaptersArray count]) {
                NSString *str = [NSString stringWithFormat:@"%@",[chaptersArray objectAtIndex:row]];
                
                UIImageView *backgroundView = [[UIImageView alloc] init];
                [backgroundView setFrame:CGRectMake(2,2, self.view.bounds.size.width-14, 46)];
                [backgroundView setImage:[UIImage imageNamed:@"read_settingcellback"]];
                [cell.contentView addSubview:backgroundView];
                
                UILabel *textLabel = [[UILabel alloc] init];
                [textLabel setText:[self getChapterName:str]];
                [textLabel setFrame:CGRectMake(10, 5, self.view.bounds.size.width-20, 40)];
                [textLabel setBackgroundColor:[UIColor clearColor]];
                [textLabel setFont:[UIFont systemFontOfSize:17.0]];
                [textLabel setTextAlignment:NSTextAlignmentCenter];
                [backgroundView addSubview:textLabel];
            }
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (isbookmark) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isbookmark) {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        currentRow = [indexPath row];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Delete?", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil),NSLocalizedString(@"Cancel", nil),nil];
        [alert show];
    }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isbookmark) 
       return [bookmarkArray count];
    return [chaptersArray count];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"放弃删除!");
    } else if (buttonIndex == 0) {
        NSLog(@"确定删除!");
        [self confirmDelete];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)confirmDelete {
    if (currentRow != NSIntegerMax) {
        [[BookManager sharedInstance]deleteBookMarkWithBookid:bookid andObject:[bookmarkArray objectAtIndex:currentRow]];
        [bookmarkArray removeObjectAtIndex:currentRow];
        [self.bookMarkTableView reloadData];
        currentRow = NSIntegerMax;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isbookmark) {
        int row = [indexPath row];
        NSDictionary *bookmarkdict = [bookmarkArray objectAtIndex:row];
        int index = [[bookmarkdict objectForKey:@"bookidx"] intValue];
        ReadViewController *controller = (ReadViewController *)readViewController;
        [controller gotoIndex:index];
        [self dismissModalViewControllerAnimated:YES];
    }else {
        int row = [indexPath row];
        NSString *rangeStr = [self checkhasContainWithChapter:[chaptersArray objectAtIndex:row]];
        NSRange range = NSRangeFromString(rangeStr);
        NSInteger bookmarkIdx = range.location;
        NSLog(@"%d",bookmarkIdx);
        ReadViewController *controller = (ReadViewController *)readViewController;
        [controller gotoIndex:bookmarkIdx];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (NSString *)getChapterName:(NSString *)chaptername {
    NSString *flagString = @"章节名:";
    NSRange range = [chaptername rangeOfString:flagString];
    if(range.location == NSNotFound) {
        return chaptername;
    }
    else {
        NSString *rtnStr = [chaptername substringFromIndex:range.location + [flagString length]];
        return rtnStr;
    }
}



@end
