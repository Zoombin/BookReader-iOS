//
//  ReadViewController.h
//  iReader
//
//  Created by Archer on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "ReadView.h"
#import "ReadMenuView.h"
#import "ReadStatusView.h"
#import "AdWhirlView.h"
#import "BookReader.h"

@interface ReadViewController : UIViewController<ReadMenuViewDelegate,AdWhirlDelegate,UIApplicationDelegate ,UIScrollViewDelegate, UITextViewDelegate> {
    ReadView *readView;
    ReadMenuView *menuView;
    ReadStatusView *statusView;
    UITextField *readField;

    int currentFontSize; 
    NSInteger currentPage;
    NSMutableString *text;
    NSMutableString *newtext;
    
    NSString *textTitle;
    NSMutableArray *pagesArray;
    
    BOOL bFirstAppeared;
    
    BOOL bFlipV;
    BOOL hasAd;
    
    int currentPageInSpineIndex;//主体中的当前页index
    float currentTextSize;//当前字体大小
    int pagesInCurrentSpineCount;//当前主体中的页数
    
    NSInteger startPointX;
    NSInteger startPointY;
    NSInteger lengthPerPage;
    
    NSString *currentBookId;
    
    BOOL    shouldReload;
    NSString *moveIndexs;
    NSMutableArray *chapterArray;
    NSMutableArray *chapterRealName;
    BOOL canRead;
    BOOL isBuy;
    
    NSMutableArray *chapterIndexArray;
}

@property (strong, nonatomic) ReadView *readView;
@property (strong, nonatomic) ReadMenuView *menuView;
@property (strong, nonatomic) ReadStatusView *statusView;
@property (strong, nonatomic) UITextField *readField;
@property (assign, nonatomic) int currentFontSize;
@property (strong, nonatomic) NSMutableString *text;
@property (strong, nonatomic) NSString *textTitle;
@property (assign, nonatomic) BOOL bFlipV;
@property (assign, nonatomic) float currentTextSize;
@property ( nonatomic) NSMutableString *newtext;
@property (assign, nonatomic) BOOL isBuy;

- (id)initWithBookUID:(NSString *)uid andShouldMoveToNew:(BOOL)shouldMove andMoveIndex:(NSString *)index andNewText:(NSString *)ntext;
- (void)gotoIndex:(int)idx;

@end
