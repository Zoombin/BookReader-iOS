//
//  BookReaderServiceManager.m
//  BookReader
//
//  Created by 颜超 on 13-3-25.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "ServiceManager.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "NSString+XXSYDecoding.h"
#import "Book.h"
#import "Chapter.h"
#import "Member+Setup.h"
#import "BookReaderDefaultsManager.h"

//获取IP地址需要用到
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>

#define DEFAULF_KEY    @"04B6A5985B70DC641B0E98C0F8B221A6" //用于解密

//#define XXSY_BASE_URL   @"http://10.224.72.188/service/"
#define XXSY_BASE_URL  @"http://link.xxsy.net/service"
#define SECRET          @"DRiHFmTSaN12wXgQBjVUr5oCpxZznWhvkIO97EuAd30bey8fs4JctGMYl6KqLP"



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

+ (void)saveUserID:(NSNumber *)userID
{
	sUserID = userID;
    [[NSUserDefaults standardUserDefaults] setObject:sUserID forKey:USER_ID];
}

+ (NSNumber *)userID
{
	if (!sUserID) {
		sUserID = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
	}
	return sUserID;
}

+ (void)deleteUserID
{
	sUserID = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
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
    [parameterValuesString setString:[[parameterValuesString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString]];
    NSMutableDictionary *valueDict =  [[self randomCode] mutableCopy];
    parameters[@"check"] = valueDict[@"check"];
    NSString *sign = [NSString stringWithFormat:@"%@%@", parameterValuesString, valueDict[@"key"]];
    parameters[@"sign"] = [sign md532];
    return parameters;
}

+ (void)verifyCodeByPhoneNumber:(NSString *)phoneNumber
                      withBlock:(void (^)(NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}]];
	parameters[@"username"] = phoneNumber;
    [[ServiceManager shared] postPath:@"PostVerifyCode.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        if (block) {
            block([theObject objectForKey:@"result"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", error);
        }
    }];
}

+ (void)registerByPhoneNumber:(NSString *)phoneNumber
                   verifyCode:(NSString *)verifyCode
                  andPassword:(NSString *)password
                    withBlock:(void (^)(NSString *, NSString *,NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}, @{@"yzm" : verifyCode}]];
    parameters[@"pwd"] = [password md516];
    [[ServiceManager shared] postPath:@"Register.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            Member *member = [Member createWithAttributes:theObject[@"user"]];
            [ServiceManager saveUserID:member.uid];
        }
        if (block) {
            block([theObject objectForKey:@"result"],[theObject objectForKey:@"error"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"",@"", error);
        }
    }];
}

+ (void)loginByPhoneNumber:(NSString *)phoneNumber
               andPassword:(NSString *)password
                 withBlock:(void (^)(Member *,NSString *,NSString *,NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}, @{@"pwd" : [password md516]}]];
    [[ServiceManager shared] postPath:@"Login.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        Member *member = nil;
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            member = [Member createWithAttributes:theObject[@"user"]];
            [ServiceManager saveUserID:member.uid];
        }
        if (block) {
            block(member, [theObject objectForKey:@"result"],[theObject objectForKey:@"error"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,nil,nil,error);
        }
    }];
}

+ (void)changePasswordWithOldPassword:(NSString *)oldPassword
                       andNewPassword:(NSString *)newPassword
                            withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"oldpwd" : [oldPassword md516]}, @{@"newpwd" : [newPassword md516]}]];
    [[ServiceManager shared] postPath:@"ChangePassword.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"result"],[theObject objectForKey:@"error"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", @"", error);
        }
    }];
}

+ (void)postFindPasswordCode:(NSString *)phoneNumber
                   withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}]];
    [[ServiceManager shared] postPath:@"PostFindPasswordCode.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
       id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        if (block) {
            block([theObject objectForKey:@"error"], [theObject objectForKey:@"result"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"",@"", error);
        }
    }];
}

+ (void)findPassword:(NSString *)phoneNumber
          verifyCode:(NSString *)verifyCode
      andNewPassword:(NSString *)newPassword
           withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"username" : phoneNumber}, @{@"yzm" : verifyCode}, @{@"pwd" : [newPassword md516]}]];
    [[ServiceManager shared] postPath:@"FindPassword.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
       id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"success=>%@",theObject);
        if (block) {
            block([theObject objectForKey:@"error"], [theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(@"", @"", error);
        }
    }];
}

+ (void)userInfoWithBlock:(void (^)(Member *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}]];
    [[ServiceManager shared] postPath:@"GetHyuser.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        Member *member = nil;
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            member = [Member createWithAttributes:theObject[@"user"]];
            [ServiceManager saveUserID:member.uid];
        }
        if (block) {
            block(member,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)payWithType:(NSString *)payType
          withBlock:(void (^)(NSString *, NSError *))block
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	static const NSString *iOSFlag = @"40";
    NSString *paymentCode = [NSString stringWithFormat:@"%@_%@_%@",[dateFormatter stringFromDate:[NSDate date]],[self userID], iOSFlag];//潇湘书院的订单号
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"mount" : payType}, @{@"orderid" : paymentCode}]];
    [[ServiceManager shared] postPath:@"UserPay.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *postsFromResponse = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
        NSLog(@"success=>%@",postsFromResponse);
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
                          withBlock:(void (^)(NSArray *, NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"index" : pageIndex}, @{@"size" : count}]];
    [[ServiceManager shared] postPath:@"RechargeList.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            NSArray *rechargeList = [theObject objectForKey:@"rechargeList"];
            if ([rechargeList count]>0) {
                for (int i=0; i<[rechargeList count]; i++) {
                    Pay *pay = [[Pay alloc] init];
                    pay.orderID = rechargeList[i][@"orderid"];
                    pay.count = rechargeList[i][@"count"];
                    [array addObject:pay];
                }
            }
        }
        
        if (block) {
            block(array,[theObject objectForKey:@"result"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,nil,error);
        }
    }];
}

+ (void)books:(NSString *)keyword
      classID:(NSString *)classid
      ranking:(NSString *)ranking
         size:(NSString *)size
        andIndex:(NSString *)index
       withBlock:(void (^)(NSArray *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"keyword" : keyword}, @{@"classid" : classid}, @{@"ranking" : ranking}, @{@"size" : size}, @{@"index" : index}]];
    [[ServiceManager shared] postPath:@"Search.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        NSMutableArray *bookListsArray = [@[] mutableCopy];
        if ([theObject[@"bookList"] isKindOfClass:[NSArray class]]) {
			[bookListsArray addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"bookList"]]];
        }
        if (block) {
            block(bookListsArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)getRecommandBooksWithBlock:(void (^)(NSArray *, NSError *))block
{
    NSMutableDictionary *parameters = [self commonParameters:@[]];
    [[ServiceManager shared] postPath:@"GetRecommend.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSArray *bookListArray = [theObject objectForKey:@"bookList"];
        NSMutableArray *resultArray = [@[] mutableCopy];
		[resultArray addObjectsFromArray:[Book booksWithAttributesArray:bookListArray]];
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookDetailsByBookId:(NSString *)bookid
                      andIntro:(NSString *)intro
                     withBlock:(void (^)(Book *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"bookid" : bookid}, @{@"intro" : intro}]];
    [[ServiceManager shared] postPath:@"GetBookDetail.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        NSDictionary *dict = [theObject objectForKey:@"book"];
        Book *book = [Book createBookWithAttributes:dict];
        if (block) {
            block(book, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookDiccusssListByBookId:(NSString *)bookid
                            size:(NSString *)size
                        andIndex:(NSString *)index
                       withBlock:(void (^)(NSArray *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"bookId" : bookid}, @{@"size" : size}, @{@"index" : index}]];
    [[ServiceManager shared] postPath:@"GetDiscuss.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *commentArray = [[NSMutableArray alloc] init];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            NSArray *array = [theObject objectForKey:@"discussList"];
            for (int i =0; i<[array count]; i++) {
                NSDictionary *tmpDict = [array objectAtIndex:i];
                Commit *commit = [[Commit alloc] init];
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
            block(commentArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookCatalogueList:(NSString *)bookid
          andNewestCataId:(NSString *)cataid
                withBlock:(void (^)(NSArray *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"bookId" : bookid}, @{@"lastchapterid" : cataid}]];
    [[ServiceManager shared] postPath:@"ChapterList.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject[@"chapterList"] isKindOfClass:[NSArray class]]) {
			[resultArray addObjectsFromArray:[Chapter chaptersWithAttributesArray:theObject[@"chapterList"] andBookID:bookid]];
        }
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookCatalogue:(NSString *)cataid
            withBlock:(void (^)(NSString *, NSString *, NSString *, NSError *))block
{
    NSNumber *userid = [self userID];
    if ([self userID] == nil) {
        userid = @0;
    }
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"chapterid" : cataid}, @{@"userid" : userid.stringValue}]];
    [[ServiceManager shared] postPath:@"ChapterDetail.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            if ([[theObject objectForKey:@"result"] isEqualToString:SUCCESS_FLAG]) {
               block([[theObject objectForKey:@"chapter"] objectForKey:@"content"],[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil); 
            }else {
                block(@"",[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,nil,nil,error);
        }
    }];
}

+ (void)chapterSubscribeWithChapterID:(NSString *)chapterid
                                 book:(NSString *)bookid
                               author:(NSNumber *)authorid
                             andPrice:(NSString *)price
                            withBlock:(void (^)(NSString *, NSString *, NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"userid" : [self userID].stringValue}, @{@"chapterid" : chapterid}, @{@"bookid" : bookid}, @{@"authorid" : authorid}, @{@"price" : price}]];
    [[ServiceManager shared] postPath:@"ChapterSubscribe.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            if ([[theObject objectForKey:@"result"] isEqualToString:SUCCESS_FLAG]) {
                block([[theObject objectForKey:@"chapter"] objectForKey:@"content"],[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
            }else {
                block(@"",[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,nil,nil, error);
        }
    }];
}

+ (void)userBooksWithSize:(NSString *)size
                 andIndex:(NSString *)index
                withBlock:(void (^)(NSArray *, NSError *))block
{
    NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.get"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"size"] = size;
    parameters[@"index"] = index;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *bookList = [@[] mutableCopy];
		[bookList addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"keepList"]]];
        if (block) {
            block(bookList, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)addFavouriteWithBookID:(NSString *)bookid
                      andValue:(BOOL)value
                     withBlock:(void (^)(NSString *, NSString *, NSError *))block
{
    NSString *methodValue = value ? @"keep.insert" : @"keep.remove";
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : methodValue}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil,nil, error);
        }
    }];
}

+ (void)autoSubscribeWithBookID:(NSString *)bookid
                       andValue:(NSString *)value
                      withBlock:(void (^)(NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.auto"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    parameters[@"value"] = value;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([NSString stringWithFormat:@"%@",theObject], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)disscussWithBookID:(NSString *)bookid
                andContent:(NSString *)content
                 withBlock:(void (^)(NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"discuss.send"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    parameters[@"content"] = content;
    parameters[@"ip"] = [self ipAddress];
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"error"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}


+ (void)bookRecommand:(NSNumber *)classid
             andCount:(NSString *)count
            withBlock:(void (^)(NSArray *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"type.recommend"}]];
    parameters[@"classid"] = classid;
    parameters[@"count"] = count;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
			[resultArray addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"bookList"]]];
        }
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)otherBooksFromAuthor:(NSNumber *)authorid
               andCount:(NSString *)count
              withBlock:(void (^)(NSArray *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"book.authorother"}]];
    parameters[@"authorid"] = authorid;
    parameters[@"count"] = count;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
			[resultArray addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"bookList"]]];
        }
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)existsFavouriteWithBookID:(NSString *)bookid
                        withBlock:(void (^)(NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"keep.isexists"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"value"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)giveGiftWithType:(NSString *)type
                  author:(NSNumber *)authorid
                   count:(NSString *)count
                integral:(NSString *)integral
                 andBook:(NSString *)bookid withBlock:(void (^)(NSString *, NSError *))block
{
	NSMutableDictionary *parameters = [self commonParameters:@[@{@"methed" : @"user.props"}]];
    parameters[@"userid"] = [self userID];
    parameters[@"bookid"] = bookid;
    parameters[@"type"] = type;
    parameters[@"authorid"] = authorid;
    parameters[@"count"] = count;
    parameters[@"integral"] = integral;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
         id theObject = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"error"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
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

@end
