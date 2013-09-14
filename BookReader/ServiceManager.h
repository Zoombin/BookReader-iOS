//
//  BookReaderServiceManager.h
//  BookReader
//
//  Created by ZoomBin on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "BRUser.h"


#define NETWORK_ERROR        @"网络异常"

#define USER_MONEY @"usermoney"
#define USER_NAME @"username"
#define HAD_LAUNCHED_BEFORE @"had_launched_before"

@interface ServiceManager : AFHTTPClient


+ (ServiceManager *)shared;

+ (BOOL)isSessionValid;
+ (void)login;
+ (void)logout;
+ (void)saveUserID:(NSNumber *)userID;
+ (BOOL)hadLaunchedBefore;
+ (void)saveUserInfo:(BRUser *)member;
+ (NSNumber *)userID;
+ (BRUser *)userInfo;
+ (void)deleteUserID;
+ (void)deleteUserInfo;
+ (NSArray *)bookCategories;

#pragma mark - 用户接口
//短信获取验证码
+ (void)verifyCodeByPhoneNumber:(NSString *)phoneNumber
                      withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block;
//短信注册
+ (void)registerByPhoneNumber:(NSString *)phoneNumber     //用户手机号
                   verifyCode:(NSString *)verifyCode
                  andPassword:(NSString *)password
                    withBlock:(void (^)(BOOL success, NSError *error, NSString *message, BRUser *member))block;  //sign:md5(username+key)

//昵称注册
+ (void)registerByNickName:(NSString *)nickName
                     email:(NSString *)email
               andPassword:(NSString *)password
                 withBlock:(void (^)(BOOL success, NSError *error, NSString *message, BRUser *member))block;


//用户登录
+ (void)loginByPhoneNumber:(NSString *)phoneNumber //用户手机号
               andPassword:(NSString *)password
                 withBlock:(void (^)(BOOL success, NSError *error, NSString *message, BRUser *member))block;
//用户密码修改
+ (void)changePasswordWithOldPassword:(NSString *)oldPassword
        andNewPassword:(NSString *)newPassword
             withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block;

//发送短信收取改回密码验证码
+ (void)postFindPasswordCode:(NSString *)phoneNumber
                   withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block;

//短信找回密码
+ (void)findPassword:(NSString *)phoneNumber
          verifyCode:(NSString *)verifyCode
      andNewPassword:(NSString *)newPassword
           withBlock:(void(^)(BOOL success, NSError *error, NSString *message))block; //error resultCode

//获取用户信息
+ (void)userInfoWithBlock:(void(^)(BOOL success, NSError *error, BRUser *member))block;

//用户充值
+ (void)payWithType:(NSString *)payType //分为5种 1,2,3,4,5 分别代表0.99$ 1.99$ 4.99$ 9.99$ 19.99$
		  withBlock:(void(^)(NSString *message, NSError *error))block __deprecated;//iOS不需要这个接口了
//{"result":"0000","count":8400}
//Example:20130108153057_2797792_14 日期_userid_40

//用户充值记录
+ (void)paymentHistoryWithPageIndex:(NSString *)pageIndex //第几页
              andCount:(NSString *)count        //每页的数目
						  withBlock:(void(^)(NSArray *resultArray, BOOL success, NSError *error))block __deprecated;//iOS不需要这个接口了

#pragma mark - 书城接口
//获取榜单 分类 搜索的书籍列表
typedef NS_ENUM(NSInteger, XXSYClassType) {
	XXSYClassTypeGoBack = 1,//穿越
	XXSYClassTypeOverhead = 2,//架空
	XXSYClassTypeCity = 3,//都市
	XXSYClassTypeYouth = 4,//青春
	XXSYClassTypeMagic = 5,//魔幻
    XXSYClassTypeFantasy = 6,//玄幻
	XXSYClassTypeWealthy = 7,//豪门
	XXSYClassTypeHistory = 8,//历史
	XXSYClassTypeAbility = 9,//异能
    XXSYClassTypeShort = 10,//短篇
	XXSYClassTypeSlash = 11//耽美
};

typedef NS_ENUM(NSInteger, XXSYRankingType) {
	XXSYRankingTypeAll = 1,//总榜
	XXSYRankingTypeNew = 2,//最新
	XXSYRankingTypeHot = 3,//最热
};

+ (void)books:(NSString *)keyword
      classID:(XXSYClassType)classid
      ranking:(XXSYRankingType)ranking
         size:(NSString *)size
        andIndex:(NSString *)index
       withBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block;

//获取热词接口
+ (void)hotKeyWithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block;

//获取推荐信息
+ (void)recommendBooksIndex:(NSInteger)index
                  WithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block;

//获取图书详情
+ (void)bookDetailsByBookId:(NSString *)bookid
                      andIntro:(BOOL)intro   //1:返回简介 0:不返回简介
                     withBlock:(void (^)(BOOL success,  NSError *error, Book *obj))block;

//获取评论接口
+ (void)bookDiccusssListByBookId:(NSString *)bookid
                            size:(NSString *)size //每次返回条数
                        andIndex:(NSString *)index //第几页
                       withBlock:(void(^)(BOOL success,  NSError *error, NSArray *resultArray))block;
//章节列表
+ (void)bookCatalogueList:(NSString *)bookid lastChapterID:(NSString *)lastChapterID
                withBlock:(void (^)(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime))block;

//返回章节列表（Android）
+ (void)getDownChapterList:(NSString *)bookid
                 andUserid:(NSString *)userid
                 withBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block __deprecated;//iOS不需要这个接口了

//返回章节内容 (Android)
+ (void)getDownChapterDetail:(NSString *)userid
                   chapterid:(NSString *)chapterid
                      bookid:(NSString *)bookid
                    authorid:(NSString *)authorid
                   withBlock:(void (^)(BOOL, NSError *, NSArray *))block __deprecated;//iOS不需要这个接口了

//获取章节内容
+ (void)bookCatalogue:(NSString *)chapterID VIP:(BOOL)VIP
            withBlock:(void(^)(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID))block; //内容 提示语 提示code

//章节订阅
+ (void)chapterSubscribeWithChapterID:(NSString *)chapterid
								book:(NSString *)bookid
							   author:(NSNumber *)authorid
							withBlock:(void (^)(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID))block;

//获取数据信息，用户收藏的书籍
+ (void)userBooksWithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block;

//添加/删除收藏
+ (void)addFavoriteWithBookID:(NSString *)bookid
       On:(BOOL)onOrOff
      withBlock:(void(^)(BOOL success,  NSError *error, NSString *message))block;

//自动订阅
+ (void)autoSubscribeWithBookID:(NSString *)bookid
             On:(BOOL)onOrOff
            withBlock:(void(^)(BOOL success, NSError *error))block;

//发表评论
+ (void)disscussWithBookID:(NSString *)bookid
          andContent:(NSString *)content
           withBlock:(void(^)(BOOL success, NSError *error, NSString *message))block;

//同类推荐
+ (void)bookRecommend:(XXSYClassType)classid //1~11
             andCount:(NSString *)count
            withBlock:(void(^)(BOOL success, NSError *error, NSArray *resultArray))block;

//作者其他书
+ (void)otherBooksFromAuthor:(NSNumber *)authorid
               andCount:(NSString *)count
              withBlock:(void(^)(BOOL success, NSError *error, NSArray *resultArray))block;

//是否在收藏夹
+ (void)existsFavoriteWithBookID:(NSString *)bookid
              withBlock:(void(^)(BOOL isExist, NSError *error))block;

//默认推荐书籍
+ (void)recommandDefaultBookwithBlock:(void(^)(BOOL success, NSError *error, NSArray *resultArray))block;

//用户道具
typedef NS_ENUM(NSInteger, XXSYGiftType) {
	XXSYGiftTypeDiamond = 1,//钻石
	XXSYGiftTypeFlower = 2,//鲜花
	XXSYGiftTypeAward = 3,//打赏
	XXSYGiftTypeTicket = 4,//月票
	XXSYGiftTypeComment = 5//评价票
};

typedef NS_ENUM(NSInteger, XXSYIntegralType) {
	XXSYIntegralTypeWorse = 1,
	XXSYIntegralTypeBad = 2,
	XXSYIntegralTypeGood = 3,
	XXSYIntegralTypeBetter = 4,
	XXSYIntegralTypeBest = 5
};

#define XXSYGiftTypesMap @{@"钻石" : @(XXSYGiftTypeDiamond), @"鲜花" : @(XXSYGiftTypeFlower), @"打赏" : @(XXSYGiftTypeAward), @"月票" : @(XXSYGiftTypeTicket), @"评价票" : @(XXSYGiftTypeComment)}

+ (void)giveGiftWithType:(XXSYGiftType)typeKey
                  author:(NSNumber *)authorid  //月票没了就没了
                   count:(NSString *)count   //送数量
                integral:(XXSYIntegralType)integral //投评价不能为0 其他为0, //integral 积分 1:不知所云 2:随便看看 3:值得一看 4:不容错过 5:经典必看
                 andBook:(NSString *)bookid
               withBlock:(void(^)(BOOL success, NSError *error, NSString *message))block;

//获取系统配置信息
+ (void)systemConfigsWithBlock:(void(^)(BOOL success, NSError *error, NSString *autoUpdateDelay, NSString *decodeKey,NSString *keepUpdateDelay))block; //返回的时间单位是分
//autoUpdatedelay = 180;  自动更新间隔 单位"分"
//decodeKey = 04B6A5985B70DC641B0E98C0F8B221A6; 解密的key
//keepUpdateDelay = 10080; 强制更新时间 单位"分"

//安卓充值
+ (void)androidPayWithType:(NSString *)channel andPhoneNum:(NSString *)num andCount:(NSString *)count andUserName:(NSString *)name WithBlock:(void(^)(NSString *result, NSError *error))block __deprecated;//iOS不需要这个接口了

+ (void)godStatePayCardNum:(NSString *)cardNum andCardPassword:(NSString *)password andCount:(NSString *)count andUserName:(NSString *)name WithBlock:(void (^)(NSString *result, NSError *error))block __deprecated;//iOS不需要这个接口了

//公告接口
+ (void)systemNotifyWithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray, NSString *content))block;
#pragma mark -

@end