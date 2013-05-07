#define  MAIN_SCREEN ( [[UIScreen mainScreen] bounds] )

#define SCREEN_SCALE ( (MAIN_SCREEN).size.width == 768 ? 2.4 : 1 )

#define kNeedRefreshBookShelf @"need_refresh_bookshelf"


#define txtColor [UIColor colorWithRed:91.0/255.0 green:33.0/255.0 blue:0.0/255.0 alpha:1.0]  //UI的字体颜色

#define headerImageViewFrame    CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)
#define titleLabelFrame         CGRectMake(0, 0, MAIN_SCREEN.size.width, 44)
#define _mTableViewFrame        CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-70+6)
#define downloadButtonFrame     CGRectMake(MAIN_SCREEN.size.width-60, 5, 50, 25)
#define infoTableViewFrame          CGRectMake(0, 44, MAIN_SCREEN.size.width, MAIN_SCREEN.size.height-105+6)

//---infoTableView---
#define textViewFrame               CGRectMake(20, 2, MAIN_SCREEN.size.width-40, 78)
#define backgroundImageViewFrame    CGRectMake(15, 0, textView.frame.size.width+10, textView.frame.size.height+10)

#define kDefaultAppID_iOS       @"2e78ef6c2e1493a2"// youmi default app id
#define kDefaultAppSecret_iOS   @"9f748efd281a1ad1"// youmi default app secret
#define UMengAppKey         @"50ce806352701561f7000197"

#define textCopyRight       @"本应用由潇湘书院和苏州纵缤信息科技有限公司合作推出。所有作品皆为潇湘书院正版授权，如有非法转载，将追究法律责任。"
#define textEmail           @"纵缤科技Email:   2290435357@qq.com"

#define WashCarItunesUrl    @"https://itunes.apple.com/app/id554554656?mt=8"

//#define HOUSE_URL               @"http://zoombin.com/"
#define HOUSE_URL               @"http://42.121.99.164/"
#define HOUSE_APPLIST_PATH      @"bookreader/AppList.plist"
#define HOUSE_BOOKLIST_PATH     @"bookreader/BookList.plist"

#define ADWHIRL_ID      @"de67b8c95c714951968d0eade4d85508"//3013 ADMOB BOOKREADER
#define ADWHIRL_READING @"d76331fd3b5244ec8adae320444ded27"//3013 ADMOB BOOKREADER

#define ADWHIRL_XXSY    @"d6f151d4cbdf4dd0b4eeea551f17a83e"//2290 ADMOB BOOKREADER

#define UDID_1          @"064f18ddbfb8bd1492ce34752a787a9342843823"//BAO WEI KANG

#define BEFORE_READ_CHAPTER @"上次阅读章节"
#define BOOKMARK            @"书签"
#define BOUGHT_FLAG         @"已经购买"
#define READ_POS_FLAG       @"阅读位置"
#define READ_PERCENT        @"阅读进度"