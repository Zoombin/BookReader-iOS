//
//  BookReaderServiceManager.h
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "Member.h"
#import "Chapter.h"
#import "Commit.h"
#import "Pay.h"
#import "Book.h"

#define SUCCESS_FLAG @"0000"

@interface ServiceManager : AFHTTPClient

+(ServiceManager *)shared;

#pragma mark -
#pragma mark 用户接口
//短信获取验证码
+ (void)verifyCodeByPhoneNumber:(NSString *)phoneNumber
                      withBlock:(void (^)(NSString *, NSError *))block;
//短信注册
+ (void)registerByPhoneNumber:(NSString *)phoneNumber     //用户手机号
                   verifyCode:(NSString *)verifyCode
                  andPassword:(NSString *)password
                    withBlock:(void (^)(NSString *, NSString *,NSError *))block;  //sign:md5(username+key)
//用户登录
+ (void)loginByPhoneNumber:(NSString *)phoneNumber //用户手机号
               andPassword:(NSString *)password
                 withBlock:(void (^)(Member *,NSString *,NSString *,NSError *))block;
//用户密码修改
+ (void)changePassword:(NSNumber *)userid
        oldPassword:(NSString *)oldPassword
        andNewPassword:(NSString *)newPassword
             withBlock:(void (^)(NSString *,NSString *,NSError *))block;

//发送短信收取改回密码验证码
+ (void)postFindPasswordCode:(NSString *)phoneNumber
                   withBlock:(void (^)(NSString *,NSString*,NSError *))block;

//短信找回密码
+ (void)findPassword:(NSString *)phoneNumber
          verifyCode:(NSString *)verifyCode
      andNewPassword:(NSString *)newPassword
           withBlock:(void(^)(NSString *,NSString *,NSError *))block; //error resultCode

//获取用户信息
+ (void)userInfo:(NSNumber *)userid
          withBlock:(void(^)(Member *,NSError *))block;

//用户充值
+ (void)pay:(NSString *)userid   //Example:20130108153057_2797792_14 日期_userid_40
     type:(NSString *)payType //分为5种 1,2,3,4,5 分别代表0.99$ 1.99$ 4.99$ 9.99$ 19.99$
      withBlock:(void(^)(NSString *,NSError *))block; //{"result":"0000","count":8400}

//用户充值记录
+ (void)paymentHistory:(NSNumber *)userid
          pageIndex:(NSString *)pageIndex //第几页
              andCount:(NSString *)count        //每页的数目
             withBlock:(void(^)(NSArray *,NSString *,NSError *))block;

#pragma mark -
#pragma mark 书城接口
//获取榜单 分类 搜索的书籍列表
+ (void)books:(NSString *)keyword
      classID:(NSString *)classid  //分类1~9 穿越，架空，历史，都市，青春，豪门，魔幻，异能，玄幻
      ranking:(NSString *)ranking //1.总榜 2.最新 3.最热
         size:(NSString *)size
        andIndex:(NSString *)index
       withBlock:(void (^)(NSArray *, NSError *))block;

//获取推荐信息
+ (void)getRecommandBooksWithBlock:(void (^)(NSArray *, NSError *))block;

//获取图书详情
+ (void)bookDetailsByBookId:(NSString *)bookid //书的id
                      andIntro:(NSString *)intro   //1:返回简介 0:不返回简介
                     withBlock:(void (^)(Book *,NSError *))block;

//获取评论接口
+ (void)bookDiccusssListByBookId:(NSString *)bookid //书的id
                            size:(NSString *)size //每次返回条数
                        andIndex:(NSString *)index //第几页
                       withBlock:(void(^)(NSArray *,NSError *))block;
//章节列表
+ (void)bookCatalogueList:(NSString *)bookid
          andNewestCataId:(NSString *)cataid
                withBlock:(void(^)(NSArray *,NSError *))block;

//获取章节内容
+ (void)bookCatalogue:(NSString *)cataid
            andUserid:(NSNumber *)userid
            withBlock:(void(^)(NSString *,NSString *,NSString *,NSError *))block; //内容 提示语 提示code

//章节订阅
+ (void)chapterSubscribe:(NSNumber *)userid
               chapter:(NSString *)chapterid
                  book:(NSString *)bookid
                author:(NSNumber *)authorid
                andPrice:(NSString *)price
               withBlock:(void(^)(NSString *,NSString *,NSString *,NSError *))block; //内容 提示语 提示code

//获取数据信息
+ (void)userBooks:(NSNumber *)userid
             size:(NSString *)size
         andIndex:(NSString *)index
        withBlock:(void(^)(NSArray *,NSError *))block;

//收藏书籍
+ (void)addFavourite:(NSNumber *)userid
         book:(NSString *)bookid
       andValue:(BOOL)value
      withBlock:(void(^)(NSString *,NSString *,NSError *))block;

//自动订阅
+ (void)autoSubscribe:(NSNumber *)userid
               book:(NSString *)bookid
             andValue:(NSString *)value //1:打开 0:关闭
            withBlock:(void(^)(NSString *,NSError *))block;

//发表评论
+ (void)disscuss:(NSNumber *)userid
              book:(NSString *)bookid
          andContent:(NSString *)content
           withBlock:(void(^)(NSString *,NSError *))block;

//同类推荐
+ (void)bookRecommand:(NSNumber *)classid //1~11
             andCount:(NSString *)count
            withBlock:(void(^)(NSArray *,NSError *))block;

//作者其他书
+ (void)otherBooksFromAuthor:(NSNumber *)authorid
               andCount:(NSString *)count
              withBlock:(void(^)(NSArray *,NSError *))block;

//是否在收藏夹
+ (void)existsFavourite:(NSNumber *)userid
                   book:(NSString *)bookid
              withBlock:(void(^)(NSString *,NSError *))block;

//用户道具
+ (void)giveGift:(NSNumber *)userid
            type:(NSString *)type    //1:送钻石 2:送鲜花 3:打赏 4:月票 5:投评价
        author:(NSNumber *)authorid  //月票没了就没了
           count:(NSString *)count   //送数量
        integral:(NSString *)integral //投评价不能为0 其他为0
       andBook:(NSString *)bookid
       withBlock:(void(^)(NSString *,NSError *))block;
//integral 积分 1:不知所云 2:随便看看 3:值得一看 4:不容错过 5:经典必看

#pragma mark -

@end

//测试BookId 449218
//返回的用户信息
//{"result":"0000","user":{"userid":5508883,"username":"13862090556","password":"49ba59abbe56e057","isBind":1,"account":33180,"monthTicket":0,"appraiseTicket":0,"mobile":"13862090556","status":0,"registerTime":"2013-04-03 11:09","mail":"","sex":0}}
//用户充值记录的信息
//{"result":"0000","rechargeList":[{"id":44,"userid":5508883,"orderid":"20130403163155_5508883_40","count":8400},{"id":43,"userid":5508883,"orderid":"20130403160604_5508883_40","count":8400},{"id":42,"userid":5508883,"orderid":"20130403160557_5508883_40","count":8400},{"id":41,"userid":5508883,"orderid":"20130403160005_5508883_40","count":420},{"id":40,"userid":5508883,"orderid":"20130403155950_5508883_40","count":8400},{"id":39,"userid":5508883,"orderid":"20130403155944_5508883_40","count":4200},{"id":38,"userid":5508883,"orderid":"20130403155931_5508883_40","count":2100},{"id":37,"userid":5508883,"orderid":"20130403155924_5508883_40","count":420},{"id":36,"userid":5508883,"orderid":"20130403155912_5508883_40","count":840}],"total":9}