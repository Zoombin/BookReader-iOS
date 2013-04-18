//
//  UIDefines.h
//  BookReader
//
//  Created by 颜超 on 13-2-1.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#define  MAIN_SCREEN ( [[UIScreen mainScreen] bounds] )

#define SCREEN_SCALE ( (MAIN_SCREEN).size.width == 768 ? 2.4 : 1 )

#define txtColor [UIColor colorWithRed:91.0/255.0 green:33.0/255.0 blue:0.0/255.0 alpha:1.0]  //UI的字体颜色

#define headerImageViewFrame    CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)
#define titleLabelFrame         CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)
#define _mTableViewFrame        CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-70+6)
#define downloadButtonFrame     CGRectMake(MAIN_SCREEN.size.width-60, 5, 50, 25)
#define infoTableViewFrame          CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-105+6)

//---infoTableView---
#define textViewFrame               CGRectMake(20, 2, MAIN_SCREEN.size.width-40, 78)
#define backgroundImageViewFrame    CGRectMake(15, 0, textView.frame.size.width+10, textView.frame.size.height+10)

