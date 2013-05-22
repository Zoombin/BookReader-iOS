//
//  GiftCell.m
//  BookReader
//
//  Created by 颜超 on 13-4-28.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "GiftCell.h"
#import "BookReader.h"
#import "UIButton+BookReader.h"
#import <QuartzCore/QuartzCore.h>

#define DarkGrayColor   [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]
#define lightGrayColor  [UIColor colorWithRed:246.0/255.0 green:243.0/255.0 blue:236.0/255.0 alpha:1.0]



@implementation GiftCell {
    UITextField *numberTextField;
    NSString *currentValue;
    
    NSArray *integralArrays;
    NSMutableArray *keyWordsArray;
    NSArray *imageNamesArray;
    
    UIImageView *keywordImageView;
    
    NSString *currentIntegral;
    NSMutableArray *buttonsArray;
    
    NSArray *normalImages;
    NSArray *hlImages;
}
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
       andIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        // Initialization code
        currentValue = @"";
        integralArrays = @[@"不知所云",@"随便看看",@"值得一看",@"不容错过",@"经典必看"];
        keyWordsArray = [NSMutableArray arrayWithObjects:@"钻石",@"鲜花",@"打赏",@"月票",@"评价票", nil];
        imageNamesArray = @[@"demand",@"flower",@"money",@"monthticket",@"comment"];
        normalImages = @[@"integral_one",@"integral_two",@"integral_three",@"integral_four",@"integral_five"];
        hlImages = @[@"integral_one_hl",@"integral_two_hl",@"integral_three_hl",@"integral_four_hl",@"integral_five_hl"];
        
        buttonsArray = [[NSMutableArray alloc] init];
        
        numberTextField = [[UITextField alloc]initWithFrame:CGRectMake(70, 8, 45, 20)];
        [numberTextField setText:@"1"];
        [numberTextField.layer setBorderWidth:1];
        [numberTextField.layer setBorderColor:[UIColor colorWithRed:120.0/255.0 green:65.0/255.0 blue:47.0/255.0 alpha:1.0].CGColor];
        [numberTextField setUserInteractionEnabled:NO];
        [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [numberTextField setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:numberTextField];
    
        keywordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 70)];
        [keywordImageView setBackgroundColor:[indexPath section]%2!=0 ? DarkGrayColor:lightGrayColor];
        [self.contentView addSubview:keywordImageView];
        
        [self.contentView setBackgroundColor:[indexPath section]%2==0 ? DarkGrayColor:lightGrayColor];
        
        UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(70, 40, 160, 20)];
        [slider setMinimumValue:1];
        [slider setThumbTintColor:[UIColor colorWithRed:203.0/255.0 green:156.0/255.0 blue:133.0/255.0 alpha:1.0]];
        [slider setMaximumValue:1000];
        [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:slider];
    
        UIButton *sendButton = [UIButton createButtonWithFrame:CGRectMake(self.bounds.size.width-45*2, 25, 65, 20)];
        [sendButton addTarget:self action:@selector(sendButtonClickedAndSetDictValue) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setTitle:@"赠送" forState:UIControlStateNormal];
        [self.contentView addSubview:sendButton];
    }
    return self;
}

- (void)setMonthTicketButtonHidden:(BOOL)boolValue
{
    if ([buttonsArray count]==0) {
        for (int i = 0; i< [integralArrays count]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:i];
            [button setHidden:boolValue];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (i==0) {
                [button setImage:[UIImage imageNamed:hlImages[i]] forState:UIControlStateNormal]; 
                currentIntegral = @"1";
            }else {
                [button setImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
            }
            [button setFrame:CGRectMake(5+50*i+i*(self.bounds.size.width-20-50*5)/4, 80, 50, 50)];
            [self.contentView addSubview:button];
            [buttonsArray addObject:button];
        }
    } else {
        for (int i = 0; i<[buttonsArray count]; i++) {
            UIButton *button = [buttonsArray objectAtIndex:i];
            [button setHidden:boolValue];
        }
    }
}

- (void)buttonClicked:(id)sender
{
    currentIntegral = [NSString stringWithFormat:@"%d",[sender tag]+1];
    for (int i = 0; i < 5; i++) {
        UIButton *button = [buttonsArray objectAtIndex:i];
        if (i==[sender tag]) {
            [button setImage:[UIImage imageNamed:hlImages[i]] forState:UIControlStateNormal];
        }
        else {
            [button setImage:[UIImage imageNamed:normalImages[i]] forState:UIControlStateNormal];
        }
    }
}

- (void)valueChanged:(id)sender
{
    UISlider *slider = sender;
    int k = slider.value;
    [numberTextField setText:[NSString stringWithFormat:@"%d",k]];
}

- (void)setValue:(NSString *)value
{
    if ([currentValue length] == 0) {
        currentValue = value;
        int index = [keyWordsArray indexOfObject:currentValue];
        [keywordImageView setImage:[UIImage imageNamed:[imageNamesArray objectAtIndex:index]]];
        if (index == 4) {
            [self setMonthTicketButtonHidden:NO];
        }
    }
}

- (void)sendButtonClickedAndSetDictValue
{
    if ([self.delegate respondsToSelector:@selector(sendButtonClick:)]) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [tmpDict setObject:numberTextField.text forKey:@"count"];
        NSString *index = [NSString stringWithFormat:@"%d",[keyWordsArray indexOfObject:currentValue]+1];
        [tmpDict setObject:index forKey:@"index"];
        if ([index intValue] == 5) {
            [tmpDict setObject:currentIntegral forKey:@"integral"];
            NSLog(@"投评价票");
        }
        [self.delegate sendButtonClick:tmpDict];
    }
}

@end
