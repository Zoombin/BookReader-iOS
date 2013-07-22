//
//  GiftCell.m
//  BookReader
//
//  Created by 颜超 on 13-4-28.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "GiftCell.h"
#import "UIButton+BookReader.h"
#import "ServiceManager.h"
#import <QuartzCore/QuartzCore.h>

#define DarkGrayColor   [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]
#define lightGrayColor  [UIColor colorWithRed:246.0/255.0 green:243.0/255.0 blue:236.0/255.0 alpha:1.0]

@implementation GiftCell {
    UITextField *numberTextField;
    NSString *currentValue;
    
    NSArray *integralArrays;
    NSMutableArray *keyWordsArray;
    NSArray *imageNamesArray;
    NSArray *rewardNum;
    
    UIImageView *keywordImageView;
    
    NSString *currentIntegral;
    NSMutableArray *buttonsArray;
    NSMutableArray *rewardBtnsArray;
    
    UISlider *_slider;
    UIButton *reductBtn;
    UIButton *addBtn;
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
        keyWordsArray = [[NSMutableArray alloc] initWithArray:XXSYGiftTypesMap.allKeys];
        imageNamesArray = @[@"demand",@"flower",@"money",@"monthticket",@"comment"];
        rewardNum = @[@"188",@"388",@"888",@"1888",@"8888"];

        buttonsArray = [[NSMutableArray alloc] init];
        rewardBtnsArray = [[NSMutableArray alloc] init];
        
         reductBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [reductBtn cooldownButtonFrame:CGRectMake(70, 20, 40, 20) andEnableCooldown:NO];
        [reductBtn setTitle:@"-" forState:UIControlStateNormal];
        [reductBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [reductBtn addTarget:self action:@selector(reductBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:reductBtn];
        
        numberTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 20, 80, 20)];
        [numberTextField setText:@"1"];
        [numberTextField setDelegate:self];
        [numberTextField.layer setBorderWidth:1.0];
        [numberTextField setTextAlignment:NSTextAlignmentCenter];
        [numberTextField.layer setBorderColor:[UIColor colorWithRed:193.0/255.0 green:157.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor];
//        [numberTextField setUserInteractionEnabled:NO];
        [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [numberTextField setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:numberTextField];
        
         addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn cooldownButtonFrame:CGRectMake(190, 20, 40, 20) andEnableCooldown:NO];
        [addBtn setTitle:@"+" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:addBtn];
    
        keywordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12.5, 35, 35)];
        [self.contentView addSubview:keywordImageView];
        
         _slider = [[UISlider alloc]initWithFrame:CGRectMake(80, 54, 120, 20)];
        [_slider setMinimumValue:1];
        [_slider setMaximumValue:10000];
        [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendButton setFrame:CGRectMake(self.bounds.size.width-70, 17.5, 45, 25)];
        [sendButton addTarget:self action:@selector(sendButtonClickedAndSetDictValue) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
        [sendButton setTitle:@"赠送" forState:UIControlStateNormal];
        [self.contentView addSubview:sendButton];
    }
    return self;
}

- (void)addBtnClicked
{
    _slider.value = _slider.value + 1;
    int k = _slider.value;
    [numberTextField resignFirstResponder];
    [numberTextField setText:[NSString stringWithFormat:@"%d",k]];
}

- (void)reductBtnClicked
{
    _slider.value = _slider.value - 1;
    int k = _slider.value;
    [numberTextField resignFirstResponder];
    [numberTextField setText:[NSString stringWithFormat:@"%d",k]];
}

- (void)setRewardButtonHidden:(BOOL)boolValue
{
    if ([rewardBtnsArray count]==0) {
        reductBtn.hidden = YES;
        addBtn.hidden = YES;
        numberTextField.hidden = YES;
        float width = (self.contentView.frame.size.width - 120 - 10 - 10*4)/3;
        for (int i = 0; i< 5; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:i];
            [button setHidden:boolValue];
            [button addTarget:self action:@selector(rewardbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:rewardNum[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            if (i==0) {
                [button.layer setBorderColor:[UIColor colorWithRed:190.0/255.0 green:96.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor];
                [button.layer setBorderWidth:2.0];
            }else {
                [button.layer setBorderColor:[UIColor grayColor].CGColor];
                [button.layer setBorderWidth:1.0];
            }
            if (i > 2) {
                [button setFrame:CGRectMake(60 + 10 * (i-2) +  width * (i-3), 55, width, 30)];
            } else {
                [button setFrame:CGRectMake(60 + 10 * (i+1) + width * i, 15, width, 30)];
            }
            [self.contentView addSubview:button];
            [buttonsArray addObject:button];
        }
    } else {
        for (int i = 0; i<[rewardBtnsArray count]; i++) {
            UIButton *button = [rewardBtnsArray objectAtIndex:i];
            [button setHidden:boolValue];
        }
    }
}

- (void)setMonthTicketButtonHidden:(BOOL)boolValue
{
    if ([buttonsArray count]==0) {
        float width = (self.contentView.frame.size.width - 10 - 10*4)/3;
        for (int i = 0; i< [integralArrays count]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:i];
            [button setHidden:boolValue];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:integralArrays[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor whiteColor]];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            if (i==0) {
                [button.layer setBorderColor:[UIColor colorWithRed:190.0/255.0 green:96.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor];
                [button.layer setBorderWidth:2.0];
                currentIntegral = @"1";
            }else {
                [button.layer setBorderColor:[UIColor grayColor].CGColor];
                [button.layer setBorderWidth:1.0];
            }
            if (i > 2) {
                [button setFrame:CGRectMake(10 * (i-2) + width * (i-3), 60+40, width, 30)];
            } else {
                [button setFrame:CGRectMake(10 * (i+1) + width * i, 60, width, 30)];
            }
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

- (void)rewardbuttonClicked:(id)sender
{
    numberTextField.text = [(UIButton *)sender titleLabel].text;
    for (int i = 0; i < 5; i++) {
        UIButton *button = [buttonsArray objectAtIndex:i];
        if (i==[sender tag]) {
            [button.layer setBorderColor:[UIColor colorWithRed:190.0/255.0 green:96.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor];
            [button.layer setBorderWidth:2.0];
        }
        else {
            [button.layer setBorderColor:[UIColor grayColor].CGColor];
            [button.layer setBorderWidth:1.0];
        }
    }
}

- (void)buttonClicked:(id)sender
{
    currentIntegral = [NSString stringWithFormat:@"%d",[sender tag]+1];
    for (int i = 0; i < 5; i++) {
        UIButton *button = [buttonsArray objectAtIndex:i];
        if (i==[sender tag]) {
            [button.layer setBorderColor:[UIColor colorWithRed:190.0/255.0 green:96.0/255.0 blue:37.0/255.0 alpha:1.0].CGColor];
            [button.layer setBorderWidth:2.0];
        }
        else {
            [button.layer setBorderColor:[UIColor grayColor].CGColor];
            [button.layer setBorderWidth:1.0];
        }
    }
}

- (void)setValue:(NSString *)value
{
    if ([currentValue length] == 0) {
        currentValue = value;
        int index = [keyWordsArray indexOfObject:currentValue];
        [keywordImageView setImage:[UIImage imageNamed:[imageNamesArray objectAtIndex:index]]];
        if (index == 2) {
            numberTextField.text = rewardNum[0];
            [self setRewardButtonHidden:NO];
        }
        else if (index == 4) {
           [self setMonthTicketButtonHidden:NO];
       } 
    }
}

- (void)sendButtonClickedAndSetDictValue
{
    if ([self.delegate respondsToSelector:@selector(sendButtonClick:)]) {
        [numberTextField resignFirstResponder];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [numberTextField resignFirstResponder];
    // Configure the view for the selected state
}

@end
