//
//  GiftViewController.m
//  BookReader
//
//  Created by 颜超 on 13-4-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "GiftViewController.h"
#import "UIDefines.h"
#import "ServiceManager.h"

@implementation GiftViewController {
    NSString *title;
    NSString *currentIndex;
    UITextField *numberTextField;
    Book *bookObj;
    NSNumber *userid;
    NSArray *integralArrays;
    NSString *currentIntegral;
}

- (id)initWithIndex:(NSString *)index
         andBookObj:(Book *)bookObject
{
    self = [super init];
    if (self) {
        // Custom initialization
        currentIndex = index;
        currentIntegral = @"";
        bookObj = bookObject;
        NSArray *array = @[@"钻石",@"鲜花",@"打赏",@"月票",@"评价票"];
        integralArrays = @[@"不知所云",@"随便看看",@"值得一看",@"不容错过",@"经典必看"];
        title = array[[index integerValue]];
        userid = [[NSUserDefaults standardUserDefaults] valueForKey:@"userid"];
        //  1:送钻石 2:送鲜花 3:打赏 4:月票 5:投评价
        // 1:不知所云 2:随便看看 3:值得一看 4:不容错过 5:经典必看
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage*img =[UIImage imageNamed:@"main_view_bkg"];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:img]];
	// Do any additional setup after loading the view.
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [backgroundImage setImage:[UIImage imageNamed:@"toolbar_top_bar"]];
    [self.view addSubview:backgroundImage];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"search_btn_hl"] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backButton setFrame: CGRectMake(10, 4, 48, 32)];
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)];
    [titleLabel setText:title];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:titleLabel];
    
    UIButton *hidenKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hidenKeyboardButton setFrame:CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-44)];
    [hidenKeyboardButton addTarget:self action:@selector(hidenKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hidenKeyboardButton];
    
    numberTextField = [[UITextField alloc]initWithFrame:CGRectMake(80, 80, MAIN_SCREEN.size.width-80*2, 25)];
    [numberTextField setText:@"0"];
    [numberTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [numberTextField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:numberTextField];
    
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(80, 130, MAIN_SCREEN.size.width-80*2, 25)];
    [slider setMinimumValue:0];
    [slider setMaximumValue:1000];
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton addTarget:self action:@selector(sendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setFrame:CGRectMake(120, 160, MAIN_SCREEN.size.width-120*2, 30)];
    [sendButton setTitle:@"赠送" forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    
    if ([currentIndex isEqualToString:@"4"]) {
        for (int i = 0; i< [integralArrays count]; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button setTag:i+100];
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (i==0) {
                [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                currentIntegral = @"1";
            }else {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [button setFrame:CGRectMake(80, 200+25*i, MAIN_SCREEN.size.width-80*2, 25)];
            [button setTitle:integralArrays[i] forState:UIControlStateNormal];
            [self.view addSubview:button];
        }
    }
}

- (void)buttonClicked:(id)sender
{
    currentIntegral = [NSString stringWithFormat:@"%d",[sender tag]-99];
    for (int i = 0; i < 5; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i+100];
        if (i+100==[sender tag])
        {
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void)sendButtonClicked
{
    NSString *integral = @"";
    if ([currentIndex isEqualToString:@"4"])
    {
        integral = currentIntegral;
    }
    NSString *index = [NSString stringWithFormat:@"%d",[currentIndex integerValue]+1];
    [ServiceManager giveGift:userid
                        type:index
                      author:bookObj.authorID
                       count:numberTextField.text
                    integral:integral
                     andBook:bookObj.uid
                   withBlock:^(NSString *result, NSError *error) {
                       if (error) {
                           
                       }else {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:result message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                           [alertView show];
                       }
                   }];
}

- (void)valueChanged:(id)sender
{
    UISlider *slider = sender;
    int k = slider.value;
    [numberTextField setText:[NSString stringWithFormat:@"%d",k]];
}

- (void)hidenKeyboard
{
    [numberTextField resignFirstResponder];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
