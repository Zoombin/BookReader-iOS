//
//  BookReaderServiceManager.h
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

#define SUCCESS_FLAG        @"0000"
#define NETWORK_ERROR        @"网络异常"
#define USER_ID   @"userid"


@class Book;
@class Member;
@interface ServiceManager : AFHTTPClient

+(ServiceManager *)shared;

+ (void)saveUserID:(NSNumber *)userID;
+ (NSNumber *)userID;
+ (void)deleteUserID;
+ (NSString *)XXSYDecodingKey;

#pragma mark - 用户接口
//短信获取验证码
+ (void)verifyCodeByPhoneNumber:(NSString *)phoneNumber
                      withBlock:(void (^)(NSString *code, NSString *resultMessage, NSError *error))block;
//短信注册
+ (void)registerByPhoneNumber:(NSString *)phoneNumber     //用户手机号
                   verifyCode:(NSString *)verifyCode
                  andPassword:(NSString *)password
                    withBlock:(void (^)(NSString *code, NSString *resultMessage,NSError *error))block;  //sign:md5(username+key)
//用户登录
+ (void)loginByPhoneNumber:(NSString *)phoneNumber //用户手机号
               andPassword:(NSString *)password
                 withBlock:(void (^)(Member *member,NSString *code,NSString *resultMessage,NSError *error))block;
//用户密码修改
+ (void)changePasswordWithOldPassword:(NSString *)oldPassword
        andNewPassword:(NSString *)newPassword
             withBlock:(void (^)(NSString *code,NSString *resultMessage,NSError *error))block;

//发送短信收取改回密码验证码
+ (void)postFindPasswordCode:(NSString *)phoneNumber
                   withBlock:(void (^)(NSString *code, NSString *resultMessage, NSError *error))block;

//短信找回密码
+ (void)findPassword:(NSString *)phoneNumber
          verifyCode:(NSString *)verifyCode
      andNewPassword:(NSString *)newPassword
           withBlock:(void(^)(NSString *code, NSString *resultMessage, NSError *error))block; //error resultCode

//获取用户信息
+ (void)userInfoWithBlock:(void(^)(Member *member,NSError *error))block;

//用户充值
+ (void)payWithType:(NSString *)payType //分为5种 1,2,3,4,5 分别代表0.99$ 1.99$ 4.99$ 9.99$ 19.99$
		  withBlock:(void(^)(NSString *resultMessage,NSError *error))block __deprecated;//iOS不需要这个接口了
//{"result":"0000","count":8400}
//Example:20130108153057_2797792_14 日期_userid_40

//用户充值记录
+ (void)paymentHistoryWithPageIndex:(NSString *)pageIndex //第几页
              andCount:(NSString *)count        //每页的数目
						  withBlock:(void(^)(NSArray *resultArray,NSString *code,NSError *error))block __deprecated;//iOS不需要这个接口了

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
       withBlock:(void (^)(NSArray *resultArray, NSError *error))block;

//获取推荐信息
+ (void)recommendBooksWithBlock:(void (^)(NSArray *resultArray, NSError *error))block;

//获取图书详情
+ (void)bookDetailsByBookId:(NSString *)bookid
                      andIntro:(BOOL)intro   //1:返回简介 0:不返回简介
                     withBlock:(void (^)(Book *obj,NSError *error))block;

//获取评论接口
+ (void)bookDiccusssListByBookId:(NSString *)bookid
                            size:(NSString *)size //每次返回条数
                        andIndex:(NSString *)index //第几页
                       withBlock:(void(^)(NSArray *resultArray,NSError *error))block;
//章节列表
+ (void)bookCatalogueList:(NSString *)bookid
          andNewestCataId:(NSString *)cataid
                withBlock:(void(^)(NSArray *resultArray,NSError *error))block;

//获取章节内容
+ (void)bookCatalogue:(NSString *)cataid
            withBlock:(void(^)(NSString *content, NSString *code, NSString *resultMessage, NSError *error))block; //内容 提示语 提示code

//章节订阅
+ (void)chapterSubscribeWithChapterID:(NSString *)chapterid
                  book:(NSString *)bookid
                author:(NSNumber *)authorid
            withBlock:(void(^)(NSString *content,NSString *resultMessage,NSString *code,NSError *error))block; //内容 提示语 提示code

//获取数据信息，用户收藏的书籍
+ (void)userBooksWithBlock:(void (^)(NSArray *resultArray, NSError *error))block;

//添加/删除收藏
+ (void)addFavoriteWithBookID:(NSString *)bookid
       On:(BOOL)onOrOff
      withBlock:(void(^)(NSString *code,NSString *resultMessage,NSError *error))block;

//自动订阅
+ (void)autoSubscribeWithBookID:(NSString *)bookid
             On:(BOOL)onOrOff
            withBlock:(void(^)(NSString *code,NSError *error))block;

//发表评论
+ (void)disscussWithBookID:(NSString *)bookid
          andContent:(NSString *)content
           withBlock:(void(^)(NSString *resultMessage,NSError *error))block;

//同类推荐
+ (void)bookRecommend:(XXSYClassType)classid //1~11
             andCount:(NSString *)count
            withBlock:(void(^)(NSArray *resultArray,NSError *error))block;

//作者其他书
+ (void)otherBooksFromAuthor:(NSNumber *)authorid
               andCount:(NSString *)count
              withBlock:(void(^)(NSArray *resultArray,NSError *error))block;

//是否在收藏夹
+ (void)existsFavoriteWithBookID:(NSString *)bookid
              withBlock:(void(^)(NSString *value,NSError *error))block;

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
               withBlock:(void(^)(NSString *resultMessage,NSError *code))block;

//获取系统配置信息
+ (void)systemConfigsWithBlock:(void(^)(NSString *,NSError *))block; //返回的时间单位是分

#pragma mark -

@end

//测试BookId 449218
//返回的用户信息
//{"result":"0000","user":{"userid":5508883,"username":"13862090556","password":"49ba59abbe56e057","isBind":1,"account":33180,"monthTicket":0,"appraiseTicket":0,"mobile":"13862090556","status":0,"registerTime":"2013-04-03 11:09","mail":"","sex":0}}
//用户充值记录的信息
//{"result":"0000","rechargeList":[{"id":44,"userid":5508883,"orderid":"20130403163155_5508883_40","count":8400},{"id":43,"userid":5508883,"orderid":"20130403160604_5508883_40","count":8400},{"id":42,"userid":5508883,"orderid":"20130403160557_5508883_40","count":8400},{"id":41,"userid":5508883,"orderid":"20130403160005_5508883_40","count":420},{"id":40,"userid":5508883,"orderid":"20130403155950_5508883_40","count":8400},{"id":39,"userid":5508883,"orderid":"20130403155944_5508883_40","count":4200},{"id":38,"userid":5508883,"orderid":"20130403155931_5508883_40","count":2100},{"id":37,"userid":5508883,"orderid":"20130403155924_5508883_40","count":420},{"id":36,"userid":5508883,"orderid":"20130403155912_5508883_40","count":840}],"total":9}