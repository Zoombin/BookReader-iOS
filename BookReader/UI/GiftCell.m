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
    UILabel *leftNumLabel;
    UILabel *rightNumLabel;
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
        [reductBtn setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
        [reductBtn setTitle:@"-" forState:UIControlStateNormal];
        [reductBtn addTarget:self action:@selector(reductBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [reductBtn setFrame:CGRectMake(70, 22, 40, 20)];
        [self.contentView addSubview:reductBtn];
        
        numberTextField = [[UITextField alloc]initWithFrame:CGRectMake(110, 22, 80, 20)];
        [numberTextField setText:@"1"];
        [numberTextField.layer setBorderWidth:1.0];
        [numberTextField.layer setBorderColor:[UIColor colorWithRed:193.0/255.0 green:157.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor];
        [numberTextField setUserInteractionEnabled:NO];
        [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [numberTextField setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:numberTextField];
        
         addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [addBtn setBackgroundImage:[UIImage imageNamed:@"yellow_btn"] forState:UIControlStateNormal];
        [addBtn setTitle:@"+" forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [addBtn setFrame:CGRectMake(190, 22, 40, 20)];
        [self.contentView addSubview:addBtn];
    
        keywordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 60, 70)];
        [self.contentView addSubview:keywordImageView];
        
        leftNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 54, 10, 20)];
        [leftNumLabel setText:@"1"];
        [leftNumLabel setTextColor:[UIColor grayColor]];
        [leftNumLabel setFont:[UIFont systemFontOfSize:14]];
        [leftNumLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:leftNumLabel];
        
         _slider = [[UISlider alloc]initWithFrame:CGRectMake(80, 54, 120, 20)];
        [_slider setMinimumValue:1];
        [_slider setMaximumTrackTintColor:[UIColor colorWithRed:56.0/255.0 green:28.0/255.0 blue:15.0/255.0 alpha:1.0]];
        [_slider setMinimumTrackTintColor:[UIColor colorWithRed:212.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1.0]];
        [_slider setThumbTintColor:[UIColor colorWithRed:212.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1.0]];
        [_slider setMaximumValue:10000];
        [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_slider];
        
         rightNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 54, 40, 20)];
        [rightNumLabel setText:@"10000"];
        [rightNumLabel setTextColor:[UIColor grayColor]];
        [rightNumLabel setFont:[UIFont systemFontOfSize:14]];
        [rightNumLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:rightNumLabel];
    
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendButton setFrame:CGRectMake(self.bounds.size.width-70, 25, 45, 35)];
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
    [numberTextField setText:[NSString stringWithFormat:@"%d",k]];
}

- (void)reductBtnClicked
{
    _slider.value = _slider.value - 1;
    int k = _slider.value;
    [numberTextField setText:[NSString stringWithFormat:@"%d",k]];
}

- (void)setRewardButtonHidden:(BOOL)boolValue
{
    if ([rewardBtnsArray count]==0) {
        leftNumLabel.hidden = YES;
        rightNumLabel.hidden = YES;
        _slider.hidden = YES;
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
            [button setTitleColor:[UIColor colorWithRed:202.0/255.0 green:118.0/255.0 blue:24.0/255.0 alpha:1.0] forState:UIControlStateNormal];
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
            [button setTitleColor:[UIColor colorWithRed:202.0/255.0 green:118.0/255.0 blue:24.0/255.0 alpha:1.0] forState:UIControlStateNormal];
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
                [button setFrame:CGRectMake(10 * (i-2) + width * (i-3), 100+40, width, 30)];
            } else {
                [button setFrame:CGRectMake(10 * (i+1) + width * i, 100, width, 30)];
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
        if (index == 2) {
            numberTextField.text = rewardNum[0];
            [self setRewardButtonHidden:NO];
        }else if (index == 3) {
            rightNumLabel.text = @"100";
            _slider.maximumValue = 100;
        }
        else if (index == 4) {
            rightNumLabel.text = @"100";
            _slider.maximumValue = 100;
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
