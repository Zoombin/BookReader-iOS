//
//  ReadThemeViewController.m
//  iReader
//
//  Created by Archer on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#define BACKGROUND_IMAGE [UIImage imageNamed:@"read_more_background.png"]
#define TOP_BAR_IMAGE [UIImage imageNamed:@"read_top_bar.png"]
#define TITLE @"主题设置"
#define BACK_BUTTON_IMAGE [UIImage imageNamed:@"read_menu_top_view_back_button.png"]
#define BACK_BUTTON_HIGHLIGHTED_IMAGE [UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"]
#define TEXT @""

#define MARK_IMAGE [UIImage imageNamed:@"read_selected_mark.png"]

#define SAFE_BUTTON_IMAGE [UIImage imageNamed:@"read_theme_button_safe.png"]
#define OLD_BUTTON_IMAGE [UIImage imageNamed:@"read_theme_button_old.png"]
#define DREAM_BUTTON_IMAGE [UIImage imageNamed:@"read_theme_button_dream.png"]
#define CANCEL_BUTTON_IMAGE [UIImage imageNamed:@"read_theme_button_cancel.png"]



#import <QuartzCore/QuartzCore.h>
#import "ReadThemeViewController.h"
#import "UserDefaultsManager.h"
#import "BookReader.h"
#import "UILabel+BookReader.h"
#import "UIColor+BookReader.h"

@interface ReadThemeViewController ()

@end

@implementation ReadThemeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:BACKGROUND_IMAGE];
    [self.view setBackgroundColor:backgroundColor];
    
    UIImageView *topBarImageView = [[UIImageView alloc] initWithImage:TOP_BAR_IMAGE];
    [topBarImageView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    [self.view addSubview:topBarImageView];
    
    UILabel *titleLabel = [UILabel titleLableWithFrame:topBarImageView.frame];
    [titleLabel setText:TITLE];
    [titleLabel setTextColor:[UIColor txtColor]];
    [self.view addSubview:titleLabel];
    
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:BACK_BUTTON_IMAGE forState:UIControlStateNormal];
    [backButton setBackgroundImage:BACK_BUTTON_HIGHLIGHTED_IMAGE forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(5, 5, 63, 29)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    marksMutableArray = [[NSMutableArray alloc] init];
    
    static CGFloat delta = 5;
    NSArray *nameArray = [NSArray arrayWithObjects:@"护眼",@"怀旧",@"梦幻",@"取消主题",nil];
    NSArray *buttonsImageArray = [NSArray arrayWithObjects:SAFE_BUTTON_IMAGE, OLD_BUTTON_IMAGE, DREAM_BUTTON_IMAGE, CANCEL_BUTTON_IMAGE, nil];
    for (int i = 0; i < [buttonsImageArray count]; ++i) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, SAFE_BUTTON_IMAGE.size.width/2, SAFE_BUTTON_IMAGE.size.height/2)];
        [button setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, 150+i*SAFE_BUTTON_IMAGE.size.height/2+i*delta)];
        [button setBackgroundImage:[buttonsImageArray objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor txtColor] forState:UIControlStateNormal];
        [button setTitle:[nameArray objectAtIndex:i] forState:UIControlStateNormal];
        button.tag = i;
        [self.view addSubview:button];
        
        UIImageView *markImageView = [[UIImageView alloc] initWithImage:MARK_IMAGE];
        [markImageView setCenter:CGPointMake(250, button.frame.size.height/2)];
        markImageView.hidden = YES;
        [button addSubview:markImageView];
        [marksMutableArray addObject:markImageView];
    }
    
    
    NSString *themeStr = [UserDefaultsManager objectForKey:UserDefaultsKeyBackground];
    if ([themeStr isEqualToString:UserDefaultsValueBackgroundDay] || [themeStr isEqualToString:UserDefaultsValueBackgroundNight]) {
        [self hideAllMarks];
    }
    else if ([themeStr isEqualToString:UserDefaultsValueBackgroundSafe]) {
        [self showSelectedMark:0];
    }
    else if ([themeStr isEqualToString:UserDefaultsValueBackgroundOld]) {
        [self showSelectedMark:1];
    }
    else if ([themeStr isEqualToString:UserDefaultsValueBackgroundDream]) {
        [self showSelectedMark:2];
    }
}

- (void)buttonPressed:(id)sender {
    [self hideAllMarks];
    
    NSString *backgroundvalue = UserDefaultsValueBackgroundColorDefault;
    [UserDefaultsManager setObject:backgroundvalue forKey:UserDefaultsKeyBackgroundColor];
    
    NSInteger tag = [sender tag];
    if (tag == 0) {
        [UserDefaultsManager setObject:UserDefaultsValueBackgroundSafe forKey:UserDefaultsKeyBackground];
    }
    else if(tag == 1) {
        [UserDefaultsManager setObject:UserDefaultsValueBackgroundOld forKey:UserDefaultsKeyBackground];
    }
    else if(tag == 2) {
        [UserDefaultsManager setObject:UserDefaultsValueBackgroundDream forKey:UserDefaultsKeyBackground];
    }
    else if(tag == 3) {
        [UserDefaultsManager setObject:UserDefaultsValueBackgroundDay forKey:UserDefaultsKeyBackground];
    }
    
    
    if (tag != 3) {//取消按钮
        [self showSelectedMark:tag];
    }
}

- (void)showSelectedMark:(NSInteger)tag {
    UIImageView *mark = [marksMutableArray objectAtIndex:tag];
    mark.hidden = NO;
}

- (void)hideAllMarks {
    for (UIImageView *mark in marksMutableArray) {
        mark.hidden = YES;
    }
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
