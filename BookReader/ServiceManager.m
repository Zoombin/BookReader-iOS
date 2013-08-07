//
//  BookReaderServiceManager.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "ServiceManager.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "NSString+XXSY.h"
#import "Chapter+Setup.h"
#import "Book+Setup.h"
#import "BRComment.h"
#import "BRPay.h"

//获取IP地址需要用到
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>

//#define XXSY_BASE_URL @"http://10.224.72.188/service/"
#define XXSY_BASE_URL @"http://link.xxsy.net/service"
//#define XXSY_BASE_URL @"http://pay.xxsy.net/Client/"
#define SECRET @"DRiHFmTSaN12wXgQBjVUr5oCpxZznWhvkIO97EuAd30bey8fs4JctGMYl6KqLP"
#define SUCCESS_FLAG @"0000"
#define FORBIDDEN_FLAG @"9999"
#define USER_ID @"userid"
#define SESSION_VALIDATION @"br_session_validation"

#define NEXT_UPDATE_TIME_FORMATTER @"yyyy-MM-dd HH:mm"


//pwd 是16位小写 sign是32位小写
@implementation ServiceManager

+(ServiceManager *)shared
{
    static ServiceManager *instance;
    if(!instance){
        instance = [[ServiceManager alloc] initWithBaseURL:[NSURL URLWithString:XXSY_BASE_URL]];
        [instance registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return instance;
}

static NSNumber *sUserID;

+ (BOOL)isSessionValid
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:SESSION_VALIDATION] boolValue];
}

+ (void)login
{
	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:SESSION_VALIDATION];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout
{
	[self deleteUserInfo];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:SESSION_VALIDATION];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveUserID:(NSNumber *)userID
{
	sUserID = userID;
    [[NSUserDefaults standardUserDefaults] setObject:sUserID forKey:USER_ID];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"save userID: %@", userID);
}

+ (NSNumber *)userID
{
	if (!sUserID) {
		sUserID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
	}
	return sUserID;
}

+ (BOOL)hadLaunchedBefore
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:HAD_LAUNCHED_BEFORE]) {
        return YES;
    }
	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:HAD_LAUNCHED_BEFORE];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return NO;
}

+ (void)saveNotificationContent:(NSString *)content
{
    [[NSUserDefaults standardUserDefaults] setObject:content forKey:NOTIFICATION_CONTENT];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)checkHasShowNotifi:(NSString *)content
{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:NOTIFICATION_CONTENT];
    if ([string isEqualToString:content]) {
        NSLog(@"已经存在");
        return YES;
    }
    return NO;
}

+ (void)saveUserInfo:(BRUser *)member
{
    [[NSUserDefaults standardUserDefaults] setObject:member.coin forKey:USER_MONEY];
    [[NSUserDefaults standardUserDefaults] setObject:member.name forKey:USER_NAME];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BRUser *)userInfo
{
    BRUser *member = [[BRUser alloc] init];
    member.name = [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME];
    member.coin = [[NSUserDefaults standardUserDefaults] objectForKey:USER_MONEY];
    member.uid = sUserID;
    return member;
}

+ (void)deleteUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_MONEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_NAME];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)deleteUserID
{
	sUserID = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//获取随机Key和check
+ (NSDictionary *)randomCode
{
    NSMutableString *checkString = [@"" mutableCopy];
    NSMutableString *keyString = [@"" mutableCopy];
    NSMutableDictionary *rtnValue = [@{} mutableCopy];
    for (int i = 0; i < 8; i++) {//传5-9个就行了
        int k = arc4random() % [SECRET length];
        NSString *dot = i == 0 ? @"" : @",";
        [checkString appendFormat:@"%@%d", dot, k];
        [keyString appendFormat:@"%c", [SECRET characterAtIndex:k]];
    }
    rtnValue[@"check"] = checkString;
    rtnValue[@"key"] = keyString;
    return rtnValue;
}

+ (NSMutableDictionary *)commonParameters:(NSArray *)signParameters
{
	NSMutableDictionary *parameters = [@{} mutableCopy];
	NSMutableString *parameterValuesString = [NSMutableString string];
	for (NSDictionary *parameterMap in signParameters) {
		[parameters addEntriesFromDictionary:parameterMap];
		[parameterValuesString appendString:parameterMap.allValues[0]];
	}
    NSString *parameterValuesEncodingString = [[parameterValuesString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString];
    NSMutableDictionary *valueDict =  [[self randomCode] mutableCopy];
    parameters[@"check"] = valueDict[@"check"];
    NSString *sign = [NSString stringWithFormat:@"%@%@", parameterValuesEncodingString, valueDict[@"key"]];
    parameters[@"sign"] = [sign md532];
    return parameters;
}

+ (void)verifyCodeByPhoneNumber:(NSString *)phoneNumber
                      withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}]];
	parameters[@"username"] = phoneNumber;
    [[ServiceManager shared] postPath:@"PostVerifyCode.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil,theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error ,@"");
        }
    }];
}

+ (void)registerByPhoneNumber:(NSString *)phoneNumber
                   verifyCode:(NSString *)verifyCode
                  andPassword:(NSString *)password
                    withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}, @{@"yzm" : verifyCode}]];
    parameters[@"pwd"] = [password md516];
    [[ServiceManager shared] postPath:@"Register.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            BRUser *member = [BRUser createWithAttributes:theObject[@"user"]];
            [ServiceManager saveUserID:member.uid];
			[ServiceManager login];
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG],nil,theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error, @"");
        }
    }];
}

+ (void)loginByPhoneNumber:(NSString *)phoneNumber
               andPassword:(NSString *)password
                 withBlock:(void (^)(BOOL success, NSError *error, NSString *message, BRUser *member))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}, @{@"pwd" : [password md516]}]];
    [[ServiceManager shared] postPath:@"Login.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        BRUser *member = nil;
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            member = [BRUser createWithAttributes:theObject[@"user"]];
            [ServiceManager saveUserID:member.uid];
			[ServiceManager login];
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG],nil,theObject[@"error"],member);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,error,nil,nil);
        }
    }];
}

+ (void)changePasswordWithOldPassword:(NSString *)oldPassword
                       andNewPassword:(NSString *)newPassword
                            withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"oldpwd" : [oldPassword md516]}, @{@"newpwd" : [newPassword md516]}]];
    [[ServiceManager shared] postPath:@"ChangePassword.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil,theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error, @"");
        }
    }];
}

+ (void)postFindPasswordCode:(NSString *)phoneNumber
                   withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}]];
    [[ServiceManager shared] postPath:@"PostFindPasswordCode.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
       id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error, @"");
        }
    }];
}

+ (void)findPassword:(NSString *)phoneNumber
          verifyCode:(NSString *)verifyCode
      andNewPassword:(NSString *)newPassword
           withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}, @{@"yzm" : verifyCode}, @{@"pwd" : [newPassword md516]}]];
    [[ServiceManager shared] postPath:@"FindPassword.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
       id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error, @"");
        }
    }];
}

+ (void)userInfoWithBlock:(void (^)(BOOL success,  NSError *error, BRUser *member))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}]];
    [[ServiceManager shared] postPath:@"GetHyuser.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        BRUser *member = nil;
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            member = [BRUser createWithAttributes:theObject[@"user"]];
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil,  member);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error,nil);
        }
    }];
}

+ (void)payWithType:(NSString *)payType
          withBlock:(void (^)(NSString *message, NSError *error))block
{
	static const NSString *iOSFlag = @"40";
    NSString *paymentCode = [NSString stringWithFormat:@"%@_%@_%@",[self getCurrentTimeWithFormatter:@"yyyyMMddHHmmss"],[self userID], iOSFlag];//潇湘书院的订单号
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"mount" : payType}, @{@"orderid" : paymentCode}]];
    [[ServiceManager shared] postPath:@"UserPay.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *postsFromResponse = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
        if (block) {
            block([NSString stringWithFormat:@"%@",postsFromResponse], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error);
        }
    }];
}

+ (void)paymentHistoryWithPageIndex:(NSString *)pageIndex
                           andCount:(NSString *)count
                          withBlock:(void (^)(NSArray *resultArray, BOOL success, NSError *error))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"index" : pageIndex}, @{@"size" : count}]];
    [[ServiceManager shared] postPath:@"RechargeList.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            NSArray *rechargeList = [theObject objectForKey:@"rechargeList"];
            if ([rechargeList count]>0) {
                for (int i=0; i<[rechargeList count]; i++) {
                    BRPay *pay = [[BRPay alloc] init];
                    pay.orderID = rechargeList[i][@"orderid"];
                    pay.count = rechargeList[i][@"count"];
                    [array addObject:pay];
                }
            }
        }
        
        if (block) {
            block(array,[theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,nil,error);
        }
    }];
}

+ (void)books:(NSString *)keyword
      classID:(XXSYClassType)classid
      ranking:(XXSYRankingType)ranking
         size:(NSString *)size
        andIndex:(NSString *)index
       withBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"keyword" : keyword}, @{@"classid" : @(classid).stringValue}, @{@"ranking" : @(ranking).stringValue}, @{@"size" : size}, @{@"index" : index}]];
    [[ServiceManager shared] postPath:@"Search.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *bookListsArray = [@[] mutableCopy];
        if ([theObject[@"bookList"] isKindOfClass:[NSArray class]]) {
			[bookListsArray addObjectsFromArray:[Book createWithAttributesArray:theObject[@"bookList"] andExtra:nil]];
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, bookListsArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)recommendBooksIndex:(NSInteger)index
                  WithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
    NSMutableDictionary *parameters = [self commonParameters:@[]];
    [parameters setObject:@(index).stringValue forKey:@"type"];
    [[ServiceManager shared] postPath:@"GetRecommend.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSArray *bookListArray = [theObject objectForKey:@"bookList"];
        NSMutableArray *resultArray = [@[] mutableCopy];
		[resultArray addObjectsFromArray:[Book createWithAttributesArray:bookListArray andExtra:nil]];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, resultArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)bookDetailsByBookId:(NSString *)bookid
                      andIntro:(BOOL)intro
                     withBlock:(void (^)(BOOL succes, NSError *error, Book *obj))block
{
    NSString *introValue = intro ? @"1" : @"0";
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"bookid" : bookid}, @{@"intro" : introValue}]];
    [[ServiceManager shared] postPath:@"GetBookDetail.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        NSMutableDictionary *dict = [theObject objectForKey:@"book"];
        [dict setObject:theObject[@"props"] forKey:@"props"];
        Book *book = (Book *)[Book createWithAttributes:dict];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil ,book);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)bookDiccusssListByBookId:(NSString *)bookid
                            size:(NSString *)size
                        andIndex:(NSString *)index
                       withBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"bookId" : bookid}, @{@"size" : size}, @{@"index" : index}]];
    [[ServiceManager shared] postPath:@"GetDiscuss.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *commentArray = [[NSMutableArray alloc] init];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            NSArray *array = [theObject objectForKey:@"discussList"];
            for (int i =0; i<[array count]; i++) {
                NSDictionary *tmpDict = [array objectAtIndex:i];
                BRComment *commit = [[BRComment alloc] init];
                commit.bookID = tmpDict[@"bookId"];
                commit.content = tmpDict[@"content"];
                commit.commentID = tmpDict[@"id"];
                commit.insertTime = tmpDict[@"insertTime"];
                commit.uid = tmpDict[@"userId"];
                commit.userName = tmpDict[@"userName"];
                [commentArray addObject:commit];
            }
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, commentArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);	
        }
    }];
}

+ (void)bookCatalogueList:(NSString *)bookid
                withBlock:(void (^)(BOOL success, NSError *error, BOOL forbidden, NSArray *resultArray, NSDate *nextUpdateTime))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"bookId" : bookid}, @{@"lastchapterid" : @"0"}]];//每次都从头开始更新章节列表
    parameters[@"index"] = @"1";
    parameters[@"size"] = @"2000";
    parameters[@"auto"] = @"1";
	parameters[@"nextupdatetime"] = [self getCurrentTimeWithFormatter:NEXT_UPDATE_TIME_FORMATTER];
    [[ServiceManager shared] postPath:@"ChapterList.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject[@"chapterList"] isKindOfClass:[NSArray class]]) {
			[resultArray addObjectsFromArray:[Chapter createWithAttributesArray:theObject[@"chapterList"] andExtra:bookid]];
        }
		NSString *nextUpdateTimeString = theObject[@"nextUpdateTime"];//@"2999-12-31 11:59";
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:NEXT_UPDATE_TIME_FORMATTER];
		NSDate *nextUpdateTime = [dateFormatter dateFromString:nextUpdateTimeString];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, [theObject[@"result"] isEqualToString:FORBIDDEN_FLAG], resultArray, nextUpdateTime);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil, nil, nil);
        }
    }];
}

+ (void)bookCatalogue:(NSString *)cataid VIP:(BOOL)VIP
            withBlock:(void (^)(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID))block
{
	NSNumber *userid = [self userID];
    if (!userid || !VIP) {
        userid = @0;
    }
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"chapterid" : cataid}, @{@"userid" : userid.stringValue}]];
    [[ServiceManager shared] postPath:@"ChapterDetail.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            if ([theObject[@"result"] isEqualToString:SUCCESS_FLAG]) {
				NSDictionary *chapterData = theObject[@"chapter"];
				block(YES, nil, theObject[@"error"], chapterData[@"content"], [chapterData[@"prevId"] stringValue], [chapterData[@"nextId"] stringValue]);
            } else {
                block(NO, nil, theObject[@"error"], nil, nil, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil, nil, nil, nil);
        }
    }];
}

+ (void)chapterSubscribeWithChapterID:(NSString *)chapterid
                                 book:(NSString *)bookid
                               author:(NSNumber *)authorid
                            withBlock:(void (^)(BOOL success, NSError *error, NSString *message, NSString *content, NSString *previousID, NSString *nextID))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"chapterid" : chapterid}, @{@"bookid" : bookid}, @{@"authorid" : authorid.stringValue}, @{@"price" : @"0"}]];//price is useless, XXSY need update this api
	parameters[@"noctx"] = @"0";
#define iOS_SUBSCRIBE_FLAG @"5"
    parameters[@"sno"] = iOS_SUBSCRIBE_FLAG;
    [[ServiceManager shared] postPath:@"ChapterSubscribe.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            if ([theObject[@"result"] isEqualToString:SUCCESS_FLAG]) {
                block(YES, nil, theObject[@"error"], theObject[@"chapter"][@"content"], [theObject[@"chapter"][@"prevId"] stringValue], [theObject[@"chapter"][@"nextId"] stringValue]);
            }else {
                block(NO, nil, theObject[@"error"], nil, nil, nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil, nil, nil, nil);
        }
    }];
}

+ (void)userBooksWithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
    NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.get"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"size"] = @"5000";//客户端请求5000本上限
    parameters[@"index"] = @"1";//从第一页开始请求
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *bookList = [@[] mutableCopy];
		[bookList addObjectsFromArray:[Book createWithAttributesArray:theObject[@"keepList"] andExtra:@(YES)]];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, bookList);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)addFavoriteWithBookID:(NSString *)bookid
                      On:(BOOL)onOrOff
                     withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
    NSString *methodValue = onOrOff ? @"keep.insert" : @"keep.remove";
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : methodValue}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)autoSubscribeWithBookID:(NSString *)bookid
                       On:(BOOL)onOrOff
                      withBlock:(void (^)(BOOL success, NSError *error))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.auto"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    parameters[@"value"] = onOrOff ? @"1" : @"0";
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)disscussWithBookID:(NSString *)bookid
                andContent:(NSString *)content
                 withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"discuss.send"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    parameters[@"content"] = content;
//    parameters[@"ip"] = [self ipAddress];
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}


+ (void)bookRecommend:(XXSYClassType)classid
             andCount:(NSString *)count
            withBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"type.recommend"}]];
    parameters[@"classid"] = @(classid);
    parameters[@"count"] = count;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
			[resultArray addObjectsFromArray:[Book createWithAttributesArray:theObject[@"bookList"] andExtra:nil]];
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, resultArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)otherBooksFromAuthor:(NSNumber *)authorid
               andCount:(NSString *)count
              withBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"book.authorother"}]];
    parameters[@"authorid"] = authorid;
    parameters[@"count"] = count;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
			[resultArray addObjectsFromArray:[Book createWithAttributesArray:theObject[@"bookList"] andExtra:nil]];
        }
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, resultArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)existsFavoriteWithBookID:(NSString *)bookid
                        withBlock:(void (^)(BOOL isExist, NSError *error))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.isexists"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([[theObject objectForKey:@"value"] integerValue] == 1 ? YES : NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)giveGiftWithType:(XXSYGiftType)typeKey
                  author:(NSNumber *)authorid
                   count:(NSString *)count
                integral:(XXSYIntegralType)integral
                 andBook:(NSString *)bookid withBlock:(void (^)(BOOL success, NSError *error, NSString *message))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"user.props"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;	
    parameters[@"type"] = @(typeKey).stringValue;
    parameters[@"authorid"] = authorid;
    parameters[@"count"] = count;
    parameters[@"integral"] = @(integral).stringValue;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
         id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, theObject[@"error"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)systemConfigsWithBlock:(void (^)(BOOL success, NSError *error, NSString *autoUpdateDelay,NSString *decodeKey,NSString *keepUpdateDelay))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"yyyyMMdd" : [self getCurrentTimeWithFormatter:@"yyyyMMdd"]}]];
    [parameters removeObjectForKey:@"yyyyMMdd"];
    [[ServiceManager shared] postPath:@"GetConfigs.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if ([theObject[@"result"] isEqualToString:SUCCESS_FLAG]) {
            if (block) {
                block(YES, nil, [[theObject objectForKey:@"settings"] objectForKey:@"autoUpdatedelay"],[[theObject objectForKey:@"settings"] objectForKey:@"decodeKey"], [[theObject objectForKey:@"settings"] objectForKey:@"keepUpdateDelay"]);
            }
        }else {
            if (block) {
                block(NO, nil, @"", @"", @"");
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, @"", @"", @"");
        }
    }];
}

+ (void)androidPayWithType:(NSString *)channel andPhoneNum:(NSString *)num andCount:(NSString *)count andUserName:(NSString *)name WithBlock:(void (^)(NSString *, NSError *))block
{
    NSString *signString = [NSString stringWithFormat:@"%@%@%@%@%@",[self userID],count,channel,@"921abacd49a8d1b891ac0870665e61a5",[self getCurrentTimeWithFormatter:@"yyyyMMdd"]];
    NSDictionary *parameters = @{@"userid" : [self userID],@"amount" : count,@"channel" : channel,@"username" :name,@"sign" : [signString md532],@"mobile" :num};
    [[ServiceManager shared] postPath:@"XXSYPayService.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
            if (block) block(@"",nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil,error);
    }];
}

+ (void)godStatePayCardNum:(NSString *)cardNum andCardPassword:(NSString *)password andCount:(NSString *)count andUserName:(NSString *)name WithBlock:(void (^)(NSString *, NSError *))block
{
    NSString *signString = [NSString stringWithFormat:@"%@%@%@%@%@",[self userID],count,@"5",@"921abacd49a8d1b891ac0870665e61a5",[self getCurrentTimeWithFormatter:@"yyyyMMdd"]];
    NSDictionary *parameters = @{@"userid" : [self userID],@"amount" : count,@"channel" : @"5",@"username" :name,@"sign" : [signString md532], @"cardNo" : cardNum, @"cardPassword" :password};
    [[ServiceManager shared] postPath:@"XXSYPayService.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        if (block) block(@"",nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) block(nil,error);
    }];
}

+ (void)recommandDefaultBookwithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray))block
{
    NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.recommend"}]];
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *bookList = [@[] mutableCopy];
		[bookList addObjectsFromArray:[Book createWithAttributesArray:theObject[@"keepList"] andExtra:@(YES)]];
        if (block) {
            block([theObject[@"result"] isEqualToString:SUCCESS_FLAG], nil, bookList);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error, nil);
        }
    }];
}

+ (void)systemNotifyWithBlock:(void (^)(BOOL success, NSError *error, NSArray *resultArray, NSString *content))block
{
    NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"system.notify"}]];
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *bookList = [@[] mutableCopy];
        if (theObject[@"book"]) {
            Book *book = (Book *)[Book createWithAttributes:theObject[@"book"]];
            [bookList addObject:book];
        }
        if (block) {
            block(YES, nil,bookList,theObject[@"content"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(NO, error, nil, nil);
        }
    }];
}

////获取IP地址
+ (NSString *)ipAddress
{
    NSString *ipAddress;
    char baseHostName[255];
    gethostname(baseHostName, 255); // 获得本机名字
    struct hostent *host = gethostbyname(baseHostName); // 将本机名字转换成主机网络结构体 struct hostent
    if (host == NULL) {
        herror("resolv");
    } else {
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
        char ip[255];
        strcpy(ip, inet_ntoa(*list[0])); // 获得本机IP地址
        ipAddress = [[NSString alloc] initWithFormat:@"%s",ip];
    }
    return ipAddress;
}

+ (NSString *)getCurrentTimeWithFormatter:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
