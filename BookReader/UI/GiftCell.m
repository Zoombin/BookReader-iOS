//
//  GiftCell.m
//  BookReader
//
//  Created by 颜超 on 13-4-28.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "GiftCell.h"
#import "UIButton+BookReader.h"
#import "ServiceManager.h"
#import <QuartzCore/QuartzCore.h>

#define DarkGrayColor   [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]
#define lightGrayColor  [UIColor colorWithRed:246.0/255.0 green:243.0/255.0 blue:236.0/255.0 alpha:1.0]
#define BorderColor     [UIColor colorWithRed:20.0/255.0 green:139.0/255.0 blue:14.0/255.0 alpha:1.0]

@implementation GiftCell {
    UITextField *numberTextField;
    NSString *currentValue;
    
    NSArray *integralArrays;
    NSArray *keyWordsArray;
    NSArray *imageNamesArray;
    NSArray *rewardNum;
    
    UIImageView *keywordImageView;
    
    NSString *currentIntegral;
    NSMutableArray *buttonsArray;
    NSMutableArray *rewardBtnsArray;
    
    UISlider *_slider;
    UIButton *reductBtn;
    UIButton *addBtn;
    
    CGFloat height;
    GiftCellStyle currentStyle;
}
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
       andIndexPath:(NSIndexPath *)indexPath
           andStyle:(GiftCellStyle)cellStyle
{
    self = [super init];
    if (self) {
        NSLog(@"%@",@(cellStyle));
        // Initialization code
        currentValue = @"";
        integralArrays = @[@"不知所云",@"随便看看",@"值得一看",@"不容错过",@"经典必看"];
        keyWordsArray = @[@"钻石", @"鲜花", @"月票", @"评价票", @"打赏"];
        imageNamesArray = @[@"demand",@"flower",@"monthticket",@"comment",@"money"];
        rewardNum = @[@"188",@"388",@"888",@"1888",@"8888"];
        currentStyle = cellStyle;
        
        buttonsArray = [[NSMutableArray alloc] init];
        rewardBtnsArray = [[NSMutableArray alloc] init];
        
        CGRect reduceBtnRect = CGRectZero;
        CGRect numTextFieldRect = CGRectZero;
        CGRect addBtnRect = CGRectZero;
        CGRect sendBtnRect = CGRectZero;
        
        keywordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12.5, 35, 35)];
        [keywordImageView setImage:[UIImage imageNamed:imageNamesArray[indexPath.row]]];
        [self.contentView addSubview:keywordImageView];
        
        _slider = [[UISlider alloc]initWithFrame:CGRectZero];
        [_slider setMinimumValue:1];
        [_slider setMaximumValue:10000];
        [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        
        if (cellStyle == GiftCellStyleDiamond) {
            reduceBtnRect = CGRectMake(70, 20, 40, 20);
            numTextFieldRect = CGRectMake(110, 20, 80, 20);
            addBtnRect = CGRectMake(190, 20, 40, 20);
            sendBtnRect = CGRectMake(self.bounds.size.width-70, 17.5, 45, 25);
            height = 80.0f;
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(sendBtnRect) + 5, self.bounds.size.width - 20, 25)];
            [detailLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [detailLabel setTextAlignment:NSTextAlignmentLeft];
            [detailLabel setFont:[UIFont systemFontOfSize:14]];
            [detailLabel setTextColor:[UIColor grayColor]];
            [detailLabel setAdjustsFontSizeToFitWidth:YES];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setText:@"说明：每赠送一颗钻石消费100潇湘币。"];
            [self.contentView addSubview:detailLabel];
        } else if (cellStyle == GiftCellStyleFlower) {
            reduceBtnRect = CGRectMake(70, 20, 40, 20);
            numTextFieldRect = CGRectMake(110, 20, 80, 20);
            addBtnRect = CGRectMake(190, 20, 40, 20);
            sendBtnRect = CGRectMake(self.bounds.size.width-70, 17.5, 45, 25);
            height = 80.0f;
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(sendBtnRect) + 5, self.bounds.size.width - 20, 25)];
            [detailLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [detailLabel setTextAlignment:NSTextAlignmentLeft];
            [detailLabel setTextColor:[UIColor grayColor]];
            [detailLabel setFont:[UIFont systemFontOfSize:14]];
            [detailLabel setAdjustsFontSizeToFitWidth:YES];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setText:@"说明：每赠送一朵鲜花消费100潇湘币。"];
            [self.contentView addSubview:detailLabel];
        } else if (cellStyle == GiftCellStyleTicket) {
            reduceBtnRect = CGRectMake(70, 20, 40, 20);
            numTextFieldRect = CGRectMake(110, 20, 80, 20);
            addBtnRect = CGRectMake(190, 20, 40, 20);
            sendBtnRect = CGRectMake(self.bounds.size.width-70, 17.5, 45, 25);
            height = 80.0f;
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(sendBtnRect) + 5, self.bounds.size.width - 20, 25)];
            [detailLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [detailLabel setTextAlignment:NSTextAlignmentLeft];
            [detailLabel setTextColor:[UIColor grayColor]];
            [detailLabel setFont:[UIFont systemFontOfSize:14]];
            [detailLabel setAdjustsFontSizeToFitWidth:YES];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setText:@"说明：每订阅消费满10月即可获赠1张月票，当月有效！"];
            [self.contentView addSubview:detailLabel];
        } else if (cellStyle == GiftCellStyleComment) {
            height = 180.0f;
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12.5, self.contentView.bounds.size.width, 30)];
            [descriptionLabel setFont:[UIFont systemFontOfSize:15]];
            [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
            [descriptionLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [descriptionLabel setBackgroundColor:[UIColor clearColor]];
            [descriptionLabel setText:@"请您做出对这本书合适的评价"];
            [self.contentView addSubview:descriptionLabel];
            
            float width = (self.contentView.frame.size.width - 10 - 10*4)/3;
            for (int i = 0; i< [integralArrays count]; i++) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setTag:i];
                [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                if (i > 2) {
                    [button cooldownButtonFrame:CGRectMake(10 * (i - 2) + width * (i - 3), 60 + 40, width, 30) andEnableCooldown:NO];
                } else {
                    [button cooldownButtonFrame:CGRectMake(10 * (i + 1) + width * i, 60, width, 30) andEnableCooldown:NO];
                }
                [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
                [button setTitle:integralArrays[i] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button setBackgroundColor:[UIColor whiteColor]];
                [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
                if (i == 0) {
                    button.enabled = NO;
                    [button.layer setBorderWidth:2];
                    [button.layer setBorderColor:BorderColor.CGColor];
                    currentIntegral = @"1";
                }
                [self.contentView addSubview:button];
                [buttonsArray addObject:button];
                
                sendBtnRect = CGRectMake(10, 140, 45, 25);
                
                UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sendBtnRect) + 5, CGRectGetMinY(sendBtnRect), 200, 25)];
                [detailLabel setTextAlignment:NSTextAlignmentLeft];
                [detailLabel setFont:[UIFont systemFontOfSize:15]];
                [detailLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
                [detailLabel setBackgroundColor:[UIColor clearColor]];
                [detailLabel setText:@"(每次评价需消耗200潇湘币)"];
                [self.contentView addSubview:detailLabel];
            }
        } else if (cellStyle == GiftCellStyleMoney) {
            height = 150.0f;
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12.5, self.contentView.bounds.size.width, 30)];
            [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
            [descriptionLabel setFont:[UIFont systemFontOfSize:15]];
            [descriptionLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [descriptionLabel setBackgroundColor:[UIColor clearColor]];
            [descriptionLabel setText:@"喜欢本书就给作者送个红包吧"];
            [self.contentView addSubview:descriptionLabel];
            
            sendBtnRect = CGRectMake(10, 100, 45, 25);
            
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sendBtnRect) + 5, CGRectGetMinY(sendBtnRect), 200, 25)];
            [detailLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [detailLabel setTextAlignment:NSTextAlignmentLeft];
            [detailLabel setFont:[UIFont systemFontOfSize:15]];
            [detailLabel setBackgroundColor:[UIColor clearColor]];
            [detailLabel setText:@"(以上数字单位为潇湘币)"];
            [self.contentView addSubview:detailLabel];
            
            float width = (self.contentView.frame.size.width - 120 - 10 - 10*4)/3;
            for (int i = 0; i< 5; i++) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setTag:i];
                [button addTarget:self action:@selector(rewardbuttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [button setTitle:rewardNum[i] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button setBackgroundColor:[UIColor whiteColor]];
                [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
                if (i == 0) {
                    button.enabled = NO;
                    [button.layer setBorderWidth:2];
                    [button.layer setBorderColor:BorderColor.CGColor];
                    _slider.value = 188;
                }
                [button cooldownButtonFrame:CGRectMake(10 * (i+1) + width * i, 55, width, 30) andEnableCooldown:NO];
                [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
                [self.contentView addSubview:button];
                [rewardBtnsArray addObject:button];
            }
        }
        
        if (!CGRectEqualToRect(reduceBtnRect, CGRectZero)) {
            reductBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [reductBtn cooldownButtonFrame:reduceBtnRect andEnableCooldown:NO];
            [reductBtn setTitle:@"-" forState:UIControlStateNormal];
            [reductBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [reductBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [reductBtn addTarget:self action:@selector(reductBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:reductBtn];
        }
        
        if (!CGRectEqualToRect(numTextFieldRect, CGRectZero)) {
            numberTextField = [[UITextField alloc]initWithFrame:numTextFieldRect];
            [numberTextField setText:@"1"];
            [numberTextField setTextColor:[UIColor grayColor]];
            [numberTextField setDelegate:self];
            [numberTextField setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [numberTextField setTextAlignment:NSTextAlignmentCenter];
            [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
            [numberTextField setBackgroundColor:[UIColor colorWithRed:249.0/255.0 green:248.0/255.0 blue:245.0/255.0 alpha:1.0]];
            [self.contentView addSubview:numberTextField];
        }
        
        if (!CGRectEqualToRect(addBtnRect, CGRectZero)) {
            addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [addBtn cooldownButtonFrame:addBtnRect andEnableCooldown:NO];
            [addBtn setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [addBtn setTitle:@"+" forState:UIControlStateNormal];
            [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:addBtn];
        }
        
        if (!CGRectEqualToRect(sendBtnRect, CGRectZero)) {
            UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [sendButton cooldownButtonFrame:sendBtnRect andEnableCooldown:NO];
            [sendButton addTarget:self action:@selector(sendButtonClickedAndSetDictValue) forControlEvents:UIControlEventTouchUpInside];
            [sendButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
            [sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [sendButton setTitle:@"赠送" forState:UIControlStateNormal];
            if (cellStyle == GiftCellStyleComment) {
                [sendButton setTitle:@"评价" forState:UIControlStateNormal];
            } else if (cellStyle == GiftCellStyleTicket) {
                [sendButton setTitle:@"投票" forState:UIControlStateNormal];
            }
            [self.contentView addSubview:sendButton];
        }
        
        UIView *dottedLine = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.contentView.frame.size.width + 10, 1)];
        [dottedLine setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [dottedLine setBackgroundColor:[UIColor blackColor]];
        [self.contentView addSubview:dottedLine];
        
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

- (void)rewardbuttonClicked:(id)sender
{
    _slider.value = [[(UIButton *)sender titleLabel].text integerValue];
    for (int i = 0; i < 5; i++) {
        UIButton *button = [rewardBtnsArray objectAtIndex:i];
        if (i == [sender tag]) {
            button.enabled = NO;
            [button.layer setBorderWidth:2];
            [button.layer setBorderColor:BorderColor.CGColor];
        }
        else {
            button.enabled = YES;
            [button.layer setBorderColor:[UIColor clearColor].CGColor];
        }
    }
}

- (void)buttonClicked:(id)sender
{
    currentIntegral = [NSString stringWithFormat:@"%d",[sender tag]+1];
    for (int i = 0; i < 5; i++) {
        UIButton *button = [buttonsArray objectAtIndex:i];
        if (i == [sender tag]) {
            button.enabled = NO;
            [button.layer setBorderWidth:2];
            [button.layer setBorderColor:BorderColor.CGColor];
        }
        else {
            button.enabled = YES;
            [button.layer setBorderColor:[UIColor clearColor].CGColor];
        }
    }
}

- (void)sendButtonClickedAndSetDictValue
{
    if ([self.delegate respondsToSelector:@selector(sendButtonClick:)]) {
        [numberTextField resignFirstResponder];
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [tmpDict setObject:@(_slider.value) forKey:@"count"];
        NSString *index = [NSString stringWithFormat:@"%@",XXSYGiftTypesMap[keyWordsArray[currentStyle]]];
        [tmpDict setObject:index forKey:@"index"];
        if (currentStyle == GiftCellStyleComment) {
            [tmpDict setObject:currentIntegral forKey:@"integral"];
            NSLog(@"投评价票");
        }
        [self.delegate sendButtonClick:tmpDict];
    }
}


- (CGFloat)height
{
	return height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [numberTextField resignFirstResponder];
    // Configure the view for the selected state
}

@end
