//
//  ReadColorViewController.m
//  iReader
//
//  Created by Archer on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#define BACKGROUND_IMAGE [UIImage imageNamed:@"read_more_background.png"]
#define TOP_BAR_IMAGE [UIImage imageNamed:@"read_top_bar.png"]
#define TITLE @"背景颜色"
#define TITLE2 @"字体颜色"
#define BACK_BUTTON_IMAGE [UIImage imageNamed:@"read_menu_top_view_back_button.png"]
#define BACK_BUTTON_HIGHLIGHTED_IMAGE [UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"]
#define TEXT @""
//
#define CELL_BACKGROUND_COLOR [UIColor colorWithRed:249.0/255.0 green:238.0/255 blue:214.0/255.0 alpha:1.0]
#define CELL_WIDTH 300
#define CELL_HEIGHT 55

#define MARK_IMAGE [UIImage imageNamed:@"read_selected_mark.png"]

#import <QuartzCore/QuartzCore.h>
#import "ReadColorViewController.h"
#import "BookReader.h"
#import "UserDefaultsManager.h"


@interface ReadColorViewController ()

@end

@implementation ReadColorViewController
@synthesize bFontColor;
@synthesize marksMutableArray;
//@synthesize sampleColor;
@synthesize colorSelectorStrArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:BACKGROUND_IMAGE];
    [self.view setBackgroundColor:backgroundColor];
    
    UIImageView *topBarImageView = [[UIImageView alloc] initWithImage:TOP_BAR_IMAGE];
    [topBarImageView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [self.view addSubview:topBarImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:topBarImageView.frame];
    if (bFontColor) {
        [titleLabel setText:TITLE2];
    }
    else {
        [titleLabel setText:TITLE];
    }

    [titleLabel setTextColor:txtColor];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:BACK_BUTTON_IMAGE forState:UIControlStateNormal];
    [backButton setBackgroundImage:BACK_BUTTON_HIGHLIGHTED_IMAGE forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5, 5, 63, 29)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, topBarImageView.frame.size.height, [[UIScreen mainScreen] bounds].size.width, 100)];
    textView.text = TEXT;
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.userInteractionEnabled = NO;
    [self.view addSubview:textView];
//    UIColor lightGrayColor
    cellsTitleArray = [NSArray arrayWithObjects:@"黄色", @"棕色", @"橙色", @"白色", @"黑色", @"深灰色",nil];
    
    colorSelectorStrArray = [NSArray arrayWithObjects:@"yellowColor", @"brownColor", @"orangeColor", @"whiteColor",@"blackColor", @"darkGrayColor",nil];
    
    //sampleColor = [[NSArray arrayWithObjects:[UIColor redColor], [UIColor yellowColor], [UIColor brownColor], [UIColor orangeColor], [UIColor whiteColor], nil] retain];
    
    marksMutableArray = [[NSMutableArray alloc] init];
    
    
    colorSelectTableView = [[UITableView alloc] initWithFrame:CGRectMake(6, 70, [[UIScreen mainScreen] bounds].size.width-12, 480-38-20-40) style:UITableViewStylePlain];
    [colorSelectTableView setBackgroundColor:[UIColor clearColor]];
    [colorSelectTableView setScrollEnabled:NO];
    colorSelectTableView.delegate = self;
    colorSelectTableView.dataSource = self;
    [colorSelectTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:colorSelectTableView];
}

- (void)showSelectedMark:(NSInteger)tag {
    UIImageView *mark = [marksMutableArray objectAtIndex:tag];
    mark.hidden = NO;
//    SEL selector = NSSelectorFromString([colorSelectorStrArray objectAtIndex:tag]);
//    if (bFontColor) {
//       [textView setTextColor:[UIColor performSelector:selector]];
//    }
//    else {
//        [textView setBackgroundColor:[UIColor performSelector:selector]];
//    }
}

- (void)hideAllMarks {
    for (UIImageView *mark in marksMutableArray) {
        mark.hidden = YES;
    }
}

- (void)cellButtonPressed:(id)sender {
    [self hideAllMarks];
    [self showSelectedMark:[sender tag]];
    
    if (bFontColor) {
        [UserDefaultsManager setObject:[colorSelectorStrArray objectAtIndex:[sender tag]] forKey:UserDefaultsKeyFontColor];
    }
    else {
        [UserDefaultsManager setObject:UserDefaultsValueBackgroundNone forKey:UserDefaultsKeyBackground];
        [UserDefaultsManager setObject:[colorSelectorStrArray objectAtIndex:[sender tag]] forKey:UserDefaultsKeyBackgroundColor];
    }
}


- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark tableview dataSource and delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [colorSelectorStrArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellIdentifier = [NSString stringWithFormat:@"Cell%d", [indexPath row]];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cellButton setFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-292)/2-8, 1, 292, CELL_HEIGHT)];
        [cellButton.layer setCornerRadius:5];
        [cellButton.layer setBorderWidth:1.0];
        cellButton.tag = [indexPath row];
        [cellButton setTitle:[cellsTitleArray objectAtIndex:[indexPath row]] forState:UIControlStateNormal];
        [cellButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cellButton addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:cellButton];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellButton.frame.size.width, cellButton.frame.size.height)];
        [imageView setImage:[UIImage imageNamed:@"read_settingcellback.png"]];
        [cellButton addSubview:imageView];
        
        UIImageView *markImageView = [[UIImageView alloc] initWithImage:MARK_IMAGE];
        [markImageView setCenter:CGPointMake(250, cellButton.frame.size.height/2)];
        [cellButton addSubview:markImageView];
        markImageView.hidden = YES;
        [marksMutableArray addObject:markImageView];
        
        SEL selector = NSSelectorFromString([colorSelectorStrArray objectAtIndex:[indexPath row]]);
        
        UIView *sampleColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, cellButton.frame.size.height/2)];
        [sampleColorView setCenter:CGPointMake(60, cellButton.frame.size.height/2)];
        [sampleColorView setBackgroundColor:[UIColor performSelector:selector]];
        [sampleColorView.layer setCornerRadius:3.0];
//        [sampleColorView.layer setMasksToBounds:YES];
        [sampleColorView.layer setBorderWidth:1.0];
        [sampleColorView.layer setBorderColor:[UIColor brownColor].CGColor];
        [cellButton addSubview:sampleColorView];
        NSString *colorStr = nil;
        if (bFontColor) {
            colorStr = [UserDefaultsManager objectForKey:UserDefaultsKeyFontColor];
        }
        else {
            colorStr = [UserDefaultsManager objectForKey:UserDefaultsKeyBackgroundColor];
        }
        if ([colorStr isEqualToString:[colorSelectorStrArray objectAtIndex:[indexPath row]]]) {
            [self showSelectedMark:[indexPath row]];
        }
    } 
    return cell;
}

@end
