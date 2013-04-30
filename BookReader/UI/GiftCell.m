//
//  GiftCell.m
//  BookReader
//
//  Created by 颜超 on 13-4-28.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "GiftCell.h"
#import "UIDefines.h"

@implementation GiftCell {
    UITextField *numberTextField;
    NSString *currentValue;
    
    NSArray *integralArrays;
    NSMutableArray *keyWordsArray;
    
    NSString *currentIntegral;
    NSMutableArray *buttonsArray;
}
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        currentValue = @"";
        integralArrays = @[@"不知所云",@"随便看看",@"值得一看",@"不容错过",@"经典必看"];
        keyWordsArray = [NSMutableArray arrayWithObjects:@"钻石",@"鲜花",@"打赏",@"月票",@"评价票", nil];
        buttonsArray = [[NSMutableArray alloc] init];
        
        numberTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 8, 50, 25)];
        [numberTextField setText:@"1"];
        [numberTextField setUserInteractionEnabled:NO];
        [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [numberTextField setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:numberTextField];
    
        UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(60, 8, 160, 25)];
        [slider setMinimumValue:1];
        [slider setMaximumValue:1000];
        [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:slider];
    
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [sendButton addTarget:self action:@selector(sendButtonClickedAndSetDictValue) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setFrame:CGRectMake(MAIN_SCREEN.size.width-50*2, 8, 80, 30)];
        [sendButton setTitle:@"赠送" forState:UIControlStateNormal];
        [self.contentView addSubview:sendButton];
    }
    return self;
}

- (void)setMonthTicketButtonHidden:(BOOL)boolValue
{
    if ([buttonsArray count]==0) {
        for (int i = 0; i< [integralArrays count]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTag:i];
            [button setHidden:boolValue];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (i==0) {
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                currentIntegral = @"1";
            }else {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [button setFrame:CGRectMake(80, 50+25*i, MAIN_SCREEN.size.width-80*2, 25)];
            [button setTitle:integralArrays[i] forState:UIControlStateNormal];
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
        if (i==[sender tag])
        {
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    if ([currentValue length]==0) {
        currentValue = value;
        if ([keyWordsArray indexOfObject:currentValue]==4) {
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
        if ([index intValue] ==5) {
            [tmpDict setObject:currentIntegral forKey:@"integral"];
            NSLog(@"投评价票");
        }
        [self.delegate sendButtonClick:tmpDict];
    }
}

@end
