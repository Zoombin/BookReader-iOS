//
//  ReadMoreViewController.m
//  iReader
//
//  Created by Archer on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define BACKGROUND_IMAGE [UIImage imageNamed:@"read_more_background.png"]
#define TOP_BAR_IMAGE [UIImage imageNamed:@"read_top_bar.png"]
#define TITLE @"设置"
#define BACK_BUTTON_IMAGE [UIImage imageNamed:@"read_menu_top_view_back_button.png"]
#define BACK_BUTTON_HIGHLIGHTED_IMAGE [UIImage imageNamed:@"read_menu_top_view_back_button_highlighted.png"]
#define TEXT @""
#define CELL_BACKGROUND_COLOR [UIColor colorWithRed:249.0/255.0 green:238.0/255 blue:214.0/255.0 alpha:1.0]
#define CELL_WIDTH 300
#define CELL_HEIGHT 60


#import <QuartzCore/QuartzCore.h>
#import "ReadMoreViewController.h"
#import "BookReader.h"
#import "UserDefaultsManager.h"
#import "ReadThemeViewController.h"
#import "ReadColorViewController.h"


@interface ReadMoreViewController ()

@end

@implementation ReadMoreViewController

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
    [titleLabel setText:TITLE];
    [titleLabel setTextColor:txtColor];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
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
    textView.textAlignment = UITextAlignmentLeft;
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.userInteractionEnabled = NO;
    [self.view addSubview:textView];
    
    buttonsMutableArray = [[NSMutableArray alloc] init];
    
    NSArray *cellsTitleArray = [NSArray arrayWithObjects:@"主题设置", @"背景颜色", @"字体颜色", @"翻页效果", @"默认恢复设置", nil];

    static CGFloat delta = 12.0;
    for (int i = 0; i < 5; ++i) {
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-CELL_WIDTH)/2, 70+i*CELL_HEIGHT+i*delta, CELL_WIDTH, CELL_HEIGHT)];
        [cellView.layer setCornerRadius:5];
        [cellView.layer setBorderWidth:1.0];
        cellView.tag = i;
        [self.view addSubview:cellView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cellView.frame.size.width, cellView.frame.size.height)];
        [imageView setImage:[UIImage imageNamed:@"read_settingcellback.png"]];
        [cellView addSubview:imageView];
        
        CGRect rect = cellView.bounds;
        rect.origin.x += 20;
        UILabel *label = [[UILabel alloc] initWithFrame:rect];
        label.textColor = txtColor;
        label.textAlignment = UITextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:17.0];
        label.backgroundColor = [UIColor clearColor];
        label.text = [cellsTitleArray objectAtIndex:i];
        [cellView addSubview:label];
        
        
        static CGFloat buttonWidth = 57;
        static CGFloat buttonHeight = 35;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (i!=1&&i!=2) {
            [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateHighlighted];
        }else {
            [button.layer setCornerRadius:5];
            [button.layer setMasksToBounds:YES];
            [button.layer setBorderWidth:1.0];
            [button setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:232.0/255 blue:191.0/255.0 alpha:1.0]];
        }
        
        //[button.layer setBorderColor:[UIColor brownColor].CGColor];
        [button setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [button setTitleColor:txtColor forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        button.tag = i;
        
        if (i == 0) {
            [button setCenter:CGPointMake(230, rect.size.height/2)];
            [button addTarget:self action:@selector(themeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsMutableArray addObject:button];
        }
        else if (i == 1) {
            [button setCenter:CGPointMake(230, rect.size.height/2)];
            [button addTarget:self action:@selector(backgroundColorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsMutableArray addObject:button];
        }
        else if (i == 2) {
            [button setCenter:CGPointMake(230, rect.size.height/2)];
            [button addTarget:self action:@selector(fontColorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsMutableArray addObject:button];
        }
        else if (i == 3) {
            [button setCenter:CGPointMake(195, rect.size.height/2)];
            [button setTitle:@"上下" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(flipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsMutableArray addObject:button];
            
            UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button2.layer setCornerRadius:5];
//            [button2.layer setMasksToBounds:YES];
            [button2.layer setBorderWidth:1.0];
//            [button2 setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:232.0/255 blue:191.0/255.0 alpha:1.0]];
            [button2.layer setBorderColor:[UIColor brownColor].CGColor];
            [button2 setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
            
            button2.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
            
            [button2 setCenter:CGPointMake(250, rect.size.height/2)];
            [button2 setTitle:@"左右" forState:UIControlStateNormal];
            [button2 setTitleColor:txtColor forState:UIControlStateNormal];
            [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [button2 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateNormal];
            [button2 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateHighlighted];
            button2.tag = 5;
            [button2 addTarget:self action:@selector(flipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cellView addSubview:button2];
            [buttonsMutableArray addObject:button2];
        }
        else if (i == 4) {
            [button setCenter:CGPointMake(250, rect.size.height/2)];
            [button setTitle:@"恢复" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [buttonsMutableArray addObject:button];
        }
        
        
        
        [cellView addSubview:button];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateButtons];
}

- (void)updateButtons {
    for (int i = 0; i < [buttonsMutableArray count]; ++i) {
        UIButton *button = [buttonsMutableArray objectAtIndex:i];
        if (i == 0) {//主题
            NSString *background = [UserDefaultsManager objectForKey:UserDefaultsKeyBackground];
            if ([background isEqualToString:UserDefaultsValueBackgroundSafe] || [background isEqualToString:UserDefaultsValueBackgroundOld] || [background isEqualToString:UserDefaultsValueBackgroundDream]) {
                [button setTitle:background forState:UIControlStateNormal];
            }
            else {
                [button setTitle:@"无" forState:UIControlStateNormal];
            }
        }
        else if (i == 1) {//背景
            NSString *backgrounColorStr = [UserDefaultsManager objectForKey:UserDefaultsKeyBackgroundColor];
            SEL selector = NSSelectorFromString(backgrounColorStr);
            [button setBackgroundColor:[UIColor performSelector:selector]];
//            [textView setBackgroundColor:[UIColor performSelector:selector]];
        }
        else if (i == 2){//字体
            NSString *backgrounColorStr = [UserDefaultsManager objectForKey:UserDefaultsKeyFontColor];
            SEL selector = NSSelectorFromString(backgrounColorStr);
            [button setBackgroundColor:[UIColor performSelector:selector]];
            [textView setTextColor:[UIColor performSelector:selector]];
        }
        else if (i == 3) {//上下翻页
            NSString *flip = [UserDefaultsManager objectForKey:UserDefaultsKeyFlipMode];
            if ([flip isEqualToString:UserDefaultsValueFlipModeVertical]) {
                [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateNormal];
            }
            else {
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
            }
        }
        else if (i == 4) {//左右翻页
            NSString *flip = [UserDefaultsManager objectForKey:UserDefaultsKeyFlipMode];
            if ([flip isEqualToString:UserDefaultsValueFlipModeHorizontal]) {
                [button setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateNormal];
            }
            else {
                [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
            }
        }
    }
    
    

}

- (void)themeButtonPressed:(id)sender {
    ReadThemeViewController *themeViewController = [[ReadThemeViewController alloc] init];
    [self.navigationController pushViewController:themeViewController animated:YES];
}

- (void)backgroundColorButtonPressed:(id)sender {
    ReadColorViewController *colorViewController = [[ReadColorViewController alloc] init];
    colorViewController.bFontColor = NO;
    [self.navigationController pushViewController:colorViewController animated:YES];
}

- (void)fontColorButtonPressed:(id)sender {
    ReadColorViewController *colorViewController = [[ReadColorViewController alloc] init];
    colorViewController.bFontColor = YES;
    [self.navigationController pushViewController:colorViewController animated:YES];
}

- (void)flipButtonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setTitleColor:txtColor forState:UIControlStateNormal];
     [button setBackgroundImage:[UIImage imageNamed:@"read_settingbutton_click"] forState:UIControlStateNormal];
    
    if ([button.titleLabel.text isEqualToString:@"上下"]) {
        UIButton *button2 = [buttonsMutableArray objectAtIndex:4];
        [button2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
        [UserDefaultsManager setObject:UserDefaultsValueFlipModeVertical forKey:UserDefaultsKeyFlipMode];
        NSLog(@"上下");
    }
    else if ([button.titleLabel.text isEqualToString:@"左右"]){
        UIButton *button2 = [buttonsMutableArray objectAtIndex:3];//
        [button2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button2 setBackgroundImage:[UIImage imageNamed:@"read_settingbutton"] forState:UIControlStateNormal];
        [UserDefaultsManager setObject:UserDefaultsValueFlipModeHorizontal forKey:UserDefaultsKeyFlipMode];
        NSLog(@"左右");
    }
}

- (void)resetButtonPressed:(id)sender {
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"注意" message:@"是否恢复为默认设置？" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        [UserDefaultsManager reset];
        [self updateButtons];
    }
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
