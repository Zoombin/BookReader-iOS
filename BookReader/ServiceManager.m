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
#import "NSString+MD5.h"
#import "NSString+XXSYDecoding.h"
#import "Book.h"
#import "Chapter.h"
#import "Member+Setup.h"

//获取IP地址需要用到
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>

#define DEFAULF_KEY    @"04B6A5985B70DC641B0E98C0F8B221A6" //用于解密

//#define XXSY_BASE_URL   @"http://10.224.72.188/service/"
#define XXSY_BASE_URL  @"http://link.xxsy.net/service"
#define SECRET          @"DRiHFmTSaN12wXgQBjVUr5oCpxZznWhvkIO97EuAd30bey8fs4JctGMYl6KqLP"

#define NETWORKERROR    @"网络异常"

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

//获取随机Key和check
+ (NSDictionary *)randomCode {
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

+ (NSDictionary *)commonParameters:(NSString *)signString
{
    NSMutableDictionary *parameters = [@{} mutableCopy];
    NSMutableDictionary *valueDict =  [[NSMutableDictionary alloc] initWithDictionary:[self randomCode]];
    parameters[@"check"] = valueDict[@"check"];
    NSString *sign = [NSString stringWithFormat:@"%@%@", signString, valueDict[@"key"]];
    parameters[@"sign"] = [sign md532];
    return parameters;
}

+ (void)verifyCodeByPhoneNumber:(NSString *)phoneNumber
                      withBlock:(void (^)(NSString *, NSError *))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:phoneNumber]];
    parameters[@"username"] = phoneNumber;
    [[ServiceManager shared] postPath:@"PostVerifyCode.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"result"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(@"", error);
        }
    }];
}

+ (void)registerByPhoneNumber:(NSString *)phoneNumber
                   verifyCode:(NSString *)verifyCode
                  andPassword:(NSString *)password
                    withBlock:(void (^)(NSString *, NSError *))block
{
    NSString *signString = [NSString stringWithFormat:@"%@%@", phoneNumber, verifyCode];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"username"] = phoneNumber;
    parameters[@"yzm"] = verifyCode;
    parameters[@"pwd"] = [password md516];
    [[ServiceManager shared] postPath:@"Register.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(@"", error);
        }
    }];
}

+ (void)loginByPhoneNumber:(NSString *)phoneNumber
               andPassword:(NSString *)password
                 withBlock:(void (^)(Member *,NSString *,NSError *))block {
    NSString *signString = [[NSString stringWithFormat:@"%@%@", phoneNumber, [password md516]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"username"] = phoneNumber;
    parameters[@"pwd"] = [password md516];
    [[ServiceManager shared] postPath:@"Login.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        Member *member = nil;
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            member = [Member createWithAttributes:theObject[@"user"]];
            [[NSUserDefaults standardUserDefaults] setValue:member.uid forKey:@"userid"];
        }
        if (block) {
            block(member, [theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil,nil, error);
        }
    }];
}

+ (void)changePassword:(NSNumber *)userid
        oldPassword:(NSString *)oldPassword
        andNewPassword:(NSString *)newPassword
             withBlock:(void (^)(NSString *, NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@%@%@", userid, [oldPassword md516],[newPassword md516]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"oldpwd"] = [oldPassword md516];
    parameters[@"newpwd"] = [newPassword md516];
    [[ServiceManager shared] postPath:@"ChangePassword.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(@"", error);
        }
    }];
}

+ (void)postFindPasswordCode:(NSString *)phoneNumber
                   withBlock:(void (^)(NSString *, NSString *, NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@", phoneNumber];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"username"] = phoneNumber;
    [[ServiceManager shared] postPath:@"PostFindPasswordCode.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
       id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        if (block) {
            block([theObject objectForKey:@"error"], [theObject objectForKey:@"result"],nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(@"",@"", error);
        }
    }];
}

+ (void)findPassword:(NSString *)phoneNumber
          verifyCode:(NSString *)verifyCode
      andNewPassword:(NSString *)newPassword
           withBlock:(void (^)(NSString *, NSString *, NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@%@%@", phoneNumber, verifyCode, [newPassword md516]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"username"] = phoneNumber;
    parameters[@"yzm"] = verifyCode;
    parameters[@"pwd"] = [newPassword md516];
    [[ServiceManager shared] postPath:@"FindPassword.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
       id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"success=>%@",theObject);
        if (block) {
            block([theObject objectForKey:@"error"], [theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(@"", @"", error);
        }
    }];
}

+ (void)userInfo:(NSNumber *)userid
          withBlock:(void (^)(Member *, NSError *))block {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:[userid stringValue]]];
    parameters[@"userid"] = userid;
    [[ServiceManager shared] postPath:@"GetHyuser.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        Member *member = nil;
        if ([theObject isKindOfClass:[NSDictionary class]]) {
            member = [Member createWithAttributes:theObject[@"user"]];
            [[NSUserDefaults standardUserDefaults] setValue:member.uid forKey:@"userid"];
        }
        if (block) {
            block(member,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)pay:(NSString *)userid //订单号日期_用户id_40  20130108153057_2797792_14 精确到秒
     type:(NSString *)payType
      withBlock:(void (^)(NSString *, NSError *))block {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *paymentCode = [NSString stringWithFormat:@"%@_%@_40",[dateFormatter stringFromDate:date],userid];//潇湘书院的订单号
    
    NSString *signString = [NSString stringWithFormat:@"%@%@%@", userid, payType, paymentCode];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"mount"] = payType;
    parameters[@"orderid"] = paymentCode;
    NSLog(@"%@",parameters);
    [[ServiceManager shared] postPath:@"UserPay.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *postsFromResponse = [[NSString alloc] initWithData:JSON encoding:NSUTF8StringEncoding];
        NSLog(@"success=>%@",postsFromResponse);
        if (block) {
            block([NSString stringWithFormat:@"%@",postsFromResponse], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(@"", error);
        }
    }];
}

+ (void)paymentHistory:(NSNumber *)userid
          pageIndex:(NSString *)pageIndex //第几页
              andCount:(NSString *)count //每页的数目
             withBlock:(void (^)(NSArray *,NSString *, NSError *))block
{
    NSString *signString = [NSString stringWithFormat:@"%@%@%@", userid, pageIndex, count];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"index"] = pageIndex;
    parameters[@"size"] = count;
    [[ServiceManager shared] postPath:@"RechargeList.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
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
        [self showAlertWithMessage:NETWORKERROR];
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
       withBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = [[[NSString stringWithFormat:@"%@%@%@%@%@",keyword,classid,ranking,size,index] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"keyword"] = keyword;
    parameters[@"classid"] = classid;
    parameters[@"ranking"] = ranking;
    parameters[@"size"] = size;
    parameters[@"index"] = index;
    NSLog(@"%@",parameters);
    [[ServiceManager shared] postPath:@"Search.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        NSMutableArray *bookListsArray = [@[] mutableCopy];
        if ([theObject[@"bookList"] isKindOfClass:[NSArray class]]) {
			[bookListsArray addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"bookList"]]];
        }
        if (block) {
            block(bookListsArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)getRecommandBooksWithBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = @"";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    [[ServiceManager shared] postPath:@"GetRecommend.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSArray *bookListArray = [theObject objectForKey:@"bookList"];
        NSMutableArray *resultArray = [@[] mutableCopy];
		[resultArray addObjectsFromArray:[Book booksWithAttributesArray:bookListArray]];
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookDetailsByBookId:(NSString *)bookid
                      andIntro:(NSString *)intro
                     withBlock:(void (^)(Book *, NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@%@",bookid,intro];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"bookid"] = bookid;
    parameters[@"intro"]= intro;
    [[ServiceManager shared] postPath:@"GetBookDetail.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"%@",theObject);
        NSDictionary *dict = [theObject objectForKey:@"book"];
        Book *book = [Book createBookWithAttributes:dict];
        if (block) {
            block(book, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookDiccusssListByBookId:(NSString *)bookid
                            size:(NSString *)size
                        andIndex:(NSString *)index
                       withBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@%@%@",bookid,size,index];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"bookId"] = bookid;
    parameters[@"size"] = size;
    parameters[@"index"] = index;
    [[ServiceManager shared] postPath:@"GetDiscuss.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
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
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookCatalogueList:(NSString *)bookid
          andNewestCataId:(NSString *)cataid
                withBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@%@",bookid,cataid];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"bookId"] = bookid;
    parameters[@"lastchapterid"] = cataid;
    [[ServiceManager shared] postPath:@"ChapterList.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject[@"chapterList"] isKindOfClass:[NSArray class]]) {
			[resultArray addObjectsFromArray:[Chapter chaptersWithAttributesArray:theObject[@"chapterList"] andBookID:bookid]];
        }
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)bookCatalogue:(NSString *)cataid
            andUserid:(NSNumber *)userid
            withBlock:(void (^)(NSString *,NSString *,NSString *,NSError *))block {
    if (userid==nil) {
        userid = [NSNumber numberWithInt:0];
    }
    NSString *signString = [NSString stringWithFormat:@"%@%@",cataid,userid];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"chapterid"] = cataid;
    parameters[@"userid"] = userid;
    [[ServiceManager shared] postPath:@"ChapterDetail.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            if ([[theObject objectForKey:@"result"] isEqualToString:@"0000"]) {
               block([[theObject objectForKey:@"chapter"] objectForKey:@"content"],[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil); 
            }else {
                block(@"",[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil,nil,nil,error);
        }
    }];
}

+ (void)chapterSubscribe:(NSNumber *)userid
               chapter:(NSString *)chapterid
                  book:(NSString *)bookid
                author:(NSNumber *)authorid
                andPrice:(NSString *)price
               withBlock:(void (^)(NSString *,NSString *,NSString *,NSError *))block {
    NSString *signString = [NSString stringWithFormat:@"%@%@%@%@%@",userid,chapterid,bookid,authorid,price];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"chapterid"] = chapterid;
    parameters[@"bookid"] = bookid;
    parameters[@"authorid"] = authorid;
    parameters[@"price"] = price;
    [[ServiceManager shared] postPath:@"ChapterSubscribe.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            if ([[theObject objectForKey:@"result"] isEqualToString:@"0000"]) {
                block([[theObject objectForKey:@"chapter"] objectForKey:@"content"],[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
            }else {
                block(@"",[theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil,nil,nil, error);
        }
    }];
}

+ (void)userBooks:(NSNumber *)userid
             size:(NSString *)size
         andIndex:(NSString *)index
        withBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = @"keep.get";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"size"] = size;
    parameters[@"index"] = index;
    parameters[@"methed"]=@"keep.get";
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *bookList = [@[] mutableCopy];
		[bookList addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"keepList"]]];
        if (block) {
            block(bookList, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)addFavourite:(NSNumber *)userid
         book:(NSString *)bookid
       andValue:(BOOL)value
      withBlock:(void (^)(NSString *,NSString *, NSError *))block {
    NSString *signString = @"keep.insert";
    if (value == NO) {
        signString = @"keep.remove";
    }
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"bookid"] = bookid;
    parameters[@"methed"]= signString;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"error"],[theObject objectForKey:@"result"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self showAlertWithMessage:NETWORKERROR]; 会造成无限跳Alert，， 如果网络异常的话
        if (block) {
            block(nil,nil, error);
        }
    }];
}

+ (void)autoSubscribe:(NSNumber *)userid
               book:(NSString *)bookid
             andValue:(NSString *)value
            withBlock:(void (^)(NSString *, NSError *))block {
    NSString *signString = @"keep.auto";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"bookid"] = bookid;
    parameters[@"value"] = value;
    parameters[@"methed"]= signString;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([NSString stringWithFormat:@"%@",theObject], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)disscuss:(NSNumber *)userid
              book:(NSString *)bookid
          andContent:(NSString *)content
           withBlock:(void (^)(NSString *, NSError *))block {
    NSString *signString = @"discuss.send";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"bookid"] = bookid;
    parameters[@"content"] = content;
    parameters[@"methed"]= signString;
    parameters[@"ip"] = [self ipAddress];
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"error"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}


+ (void)bookRecommand:(NSNumber *)classid
             andCount:(NSString *)count
            withBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = @"type.recommend";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"classid"] = classid;
    parameters[@"count"] = count;
    parameters[@"methed"] = signString;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
			[resultArray addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"bookList"]]];
        }
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)otherBooksFromAuthor:(NSNumber *)authorid
               andCount:(NSString *)count
              withBlock:(void (^)(NSArray *, NSError *))block {
    NSString *signString = @"book.authorother";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"authorid"] = authorid;
    parameters[@"count"] = count;
    parameters[@"methed"] = signString;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableArray *resultArray = [@[] mutableCopy];
        if ([theObject isKindOfClass:[NSDictionary class]]) {
			[resultArray addObjectsFromArray:[Book booksWithAttributesArray:theObject[@"bookList"]]];
        }
        if (block) {
            block(resultArray, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)existsFavourite:(NSString *)userid
           book:(NSString *)bookid
           withBlock:(void (^)(NSString *, NSError *))block {
    NSString *signString = @"keep.isexists";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"bookid"] = bookid;
    parameters[@"methed"] = signString;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([NSString stringWithFormat:@"%@",theObject], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

+ (void)giveGift:(NSNumber *)userid
            type:(NSString *)type
        author:(NSNumber *)authorid
           count:(NSString *)count
        integral:(NSString *)integral //1~5
       andBook:(NSString *)bookid withBlock:(void (^)(NSString *, NSError *))block {
    NSString *signString = @"user.props";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self commonParameters:signString]];
    parameters[@"userid"] = userid;
    parameters[@"bookid"] = bookid;
    parameters[@"type"] = type;
    parameters[@"authorid"] = authorid;
    parameters[@"count"] = count;
    parameters[@"integral"] = integral;
    parameters[@"methed"] = signString;
    [[ServiceManager shared] postPath:@"Other.aspx" parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
         id theObject=[NSJSONSerialization JSONObjectWithData:JSON options:NSJSONWritingPrettyPrinted error:nil];
        if (block) {
            block([theObject objectForKey:@"error"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithMessage:NETWORKERROR];
        if (block) {
            block(nil, error);
        }
    }];
}

////获取IP地址
+ (NSString *)ipAddress{
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

+ (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

@end
