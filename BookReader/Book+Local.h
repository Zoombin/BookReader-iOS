//
//  NSObject+Local.h
//  BookReader
//
//  Created by 颜超 on 13-6-6.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Local)

//获取到所有书籍的Id
+ (NSArray *)getAllBookId;

//通过书籍的Id来获取到书籍的信息(书签 阅读进度 阅读位置 上次阅读章节 已经购买)
+ (NSDictionary *)getBookInfoById:(NSString *)uid;

//保存书籍的信息到Plist
+ (void)saveValueWithBookId:(NSString *)bookid andKey:(NSString *)key andValue:(NSString *)value;

//书签的保存方法
+ (void)saveBookMarkWithBookId:(NSString *)bookid andContext:(NSString *)context andBookMarkIdx:(NSString *)bookIdx andBookMarkPercentage:(NSString *)percentage;

//获取书签的方法
+ (NSArray *)getBookMarkArrayByBookId:(NSString *)bookid;

//删除书签的方法
+ (void)deleteBookMarkWithBookid:(NSString *)bookid andObject:(id)object;

//判断书签是否存在的方法
+ (BOOL)checkHasExistWithBookId:(NSString *)bookid andBookIdx:(NSString *)bookidx;

//抓取txt文件
+ (NSString *)getTextWithBookId:(NSString *)bookid;

//检错和分组的方法
//-(void)checkError;
//+ (void)copyFile;

//创建所有的书籍的信息的方法(格式为txt)
+ (void)createTxtInfo;

//通过BookId来知道此书位于第几本
+ (NSInteger)getIndex:(NSString *)bookid;

//获取书籍封面的方法
+ (NSData *)getBookImageDataWithBookId:(NSString *)bookid;

//获取书籍名
+ (NSString *)getBookNameByBookId:(NSString *)bookid;

//获取作者名
+ (NSString *)getAuthorNameByBookId:(NSString *)bookid;

//获取章节信息(未被处理 包含zjid字段)
+ (NSMutableArray *)getchaptersByBookId:(NSString *)bookid;

//获取章节信息(已被处理 不包含zjid字段)
+ (NSMutableArray *)getchaptersArrayByBookId:(NSString *)bookid;//获取处理过的章节名；

+ (void)saveBookAndChapter;
@end
