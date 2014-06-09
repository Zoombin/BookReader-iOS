//
//  NSObject+Local.m
//  BookReader
//
//  Created by ZoomBin on 13-6-6.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "Book+Local.h"

#import "NSString+XXSY.h"
#import "BRContextManager.h"
#import "NSString+ZBUtilites.h"


#define BEFORE_READ_CHAPTER @"上次阅读章节"
#define BOOKMARK            @"书签"
#define BOUGHT_FLAG         @"已经购买"
#define READ_POS_FLAG       @"阅读位置"
#define READ_PERCENT        @"阅读进度"
#define  GroupNum   9


@implementation NSObject (Local)
static NSDictionary *booksDictionary;

//get these ids from bundle resource not documents
+ (NSArray *)getAllBookId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book"];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:nil];
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:nil];
    return [NSArray arrayWithArray:fileList];
}

+ (NSDictionary *)getBookInfoById:(NSString *)uid {
    return [[self getBooks] objectForKey:uid];
}

+ (void)saveValueWithBookId:(NSString *)bookid andKey:(NSString *)key andValue:(NSString *)value {
    NSMutableDictionary *currentbookDict = [[self getBooks] objectForKey:bookid];
    [currentbookDict setObject:value forKey:key];
    [self saveBooks];
}

+ (NSDictionary *)getBooks
{
    if(booksDictionary == nil) {
        booksDictionary = [[NSDictionary alloc] initWithContentsOfFile:[self plistPath]];
    }
    return booksDictionary;
}

+ (void)saveBooks
{
    if(booksDictionary != nil) {
        [booksDictionary writeToFile:[self plistPath] atomically:YES];
    }
}


+ (NSString *)plistPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rtn = [documentsDirectory stringByAppendingString:@"/BookList.plist"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:rtn]){
        NSMutableDictionary *rootDictionary = [[NSMutableDictionary alloc] init];
        NSArray *allBooksId = [NSArray arrayWithArray:[self getAllBookId]];
        for (int i = 0; i < [allBooksId count]; i++) {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            NSArray *bookmarkArray = [[NSArray alloc] init];
            NSString *readpe = @"0.00%";
            NSString *readlocation =@"0";
            [tempDict setObject:bookmarkArray forKey:BOOKMARK];
            [tempDict setObject:readpe forKey:READ_PERCENT];
            [tempDict setObject:readlocation forKey:READ_POS_FLAG];
            [tempDict setObject:@"0" forKey:BEFORE_READ_CHAPTER];
            [tempDict setObject:@"0" forKey:BOUGHT_FLAG];//0: false 1: true
            NSString *key = [allBooksId objectAtIndex:i];
            [rootDictionary setObject:tempDict forKey:key];
        }
        [rootDictionary writeToFile:rtn atomically:YES];
    }
    return rtn;
}

+ (void)saveBookMarkWithBookId:(NSString *)bookid andContext:(NSString *)context andBookMarkIdx:(NSString *)bookIdx andBookMarkPercentage:(NSString *)percentage
{
    NSMutableDictionary *currentbookDict = [[self getBooks] objectForKey:bookid];
    NSMutableArray *bookMarkArray = [currentbookDict objectForKey:BOOKMARK];
    
    NSMutableDictionary *bookMarkDictionary = [[NSMutableDictionary alloc] init];
    [bookMarkDictionary setObject:context forKey:@"context"];
    [bookMarkDictionary setObject:bookIdx forKey:@"bookidx"];
    [bookMarkDictionary setObject:percentage forKey:@"percentage"];
    [bookMarkArray addObject:bookMarkDictionary];
    [self saveBooks];
}

+ (NSArray *)getBookMarkArrayByBookId:(NSString *)bookid {
    NSMutableDictionary *currentbookDict = [[self getBooks] objectForKey:bookid];
    NSMutableArray *bookMarkArray = [currentbookDict objectForKey:BOOKMARK];
    return bookMarkArray;
}

+ (void)deleteBookMarkWithBookid:(NSString *)bookid andObject:(id)object {
    NSMutableDictionary *currentbookDict = [[self getBooks] objectForKey:bookid];
    NSMutableArray *bookMarkArray = [currentbookDict objectForKey:BOOKMARK];
    [bookMarkArray removeObject:object];
    [self saveBooks];
}

+ (BOOL)checkHasExistWithBookId:(NSString *)bookid andBookIdx:(NSString *)bookidx {
    NSMutableDictionary *currentbookDict = [[self getBooks] objectForKey:bookid];
    NSMutableArray *bookMarkArray = [currentbookDict objectForKey:BOOKMARK];
    if ([bookMarkArray count]==0) {
        return NO;
    }
    for (int i =0; i<[bookMarkArray count]; i++) {
        NSDictionary *bookMarkDictionary = [bookMarkArray objectAtIndex:i];
        NSString *tempbookidx = [bookMarkDictionary objectForKey:@"bookidx"];
        if ([tempbookidx isEqualToString:bookidx]) {
            NSLog(@"此书签已经存在!");
            return YES;
        }
    }
    return NO;
}

+ (NSString *)getTextWithBookId:(NSString *)bookid {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%@/book",bookid];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:@"txt"];//
    NSData *data = [NSData dataWithContentsOfFile:documentDir];
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return txt;
}

+ (NSString *)getAuthorNameByBookId:(NSString *)bookid {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%@/info",bookid];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:@"txt"];//
    NSData *data = [NSData dataWithContentsOfFile:documentDir];
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[txt componentsSeparatedByString:@"\n"] objectAtIndex:1];
}

+ (NSString *)getBookNameByBookId:(NSString *)bookid {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%@/info",bookid];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:@"txt"];//
    NSData *data = [NSData dataWithContentsOfFile:documentDir];
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[txt componentsSeparatedByString:@"\n"] objectAtIndex:0];
}

+ (NSData *)getBookImageDataWithBookId:(NSString *)bookid {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%@",bookid];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:nil];//
    NSData *data = nil;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDir error:nil];
    
    if ([fileList containsObject:@"cover.jpg"]) {
        NSString *imagePath = [[NSBundle mainBundle]pathForResource:[pathName stringByAppendingString:@"/cover"] ofType:@"jpg"];
        data = [NSData dataWithContentsOfFile:imagePath];
    }else if([fileList containsObject:@"cover.png"]){
        NSString *imagePath = [[NSBundle mainBundle]pathForResource:[pathName stringByAppendingString:@"/cover"] ofType:@"png"];
        data = [NSData dataWithContentsOfFile:imagePath];
    }
    return data;
}

+ (NSMutableArray *)getchaptersByBookId:(NSString *)bookid {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%@/zjinfo",bookid];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:@"txt"];//
    NSData *data = [NSData dataWithContentsOfFile:documentDir];
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i= 0; i<[[txt componentsSeparatedByString:@"\n"] count]; i++) {
        NSString *chaptersName = [[txt componentsSeparatedByString:@"\n"] objectAtIndex:i];
        if ([chaptersName length]>0) {
            [array addObject:chaptersName];
        }
    }
    return array;
}

+ (NSMutableArray *)getchaptersArrayByBookId:(NSString *)bookid {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%@/zjinfo",bookid];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:@"txt"];//
    NSData *data = [NSData dataWithContentsOfFile:documentDir];
    NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i= 0; i<[[txt componentsSeparatedByString:@"\n"] count]; i++) {
        NSString *chaptersName = [[txt componentsSeparatedByString:@"\n"] objectAtIndex:i];
        chaptersName = [self getChapterName:chaptersName];
        if ([chaptersName length]>0) {
            [array addObject:chaptersName];
        }
    }
    return array;
}

+ (NSString *)getChapterName:(NSString *)chaptername {
    NSString *flagString = @"章节名:";
    NSRange range = [chaptername rangeOfString:flagString];
    if(range.location == NSNotFound) {
        return chaptername;
    }
    else {
        NSString *rtnStr = [chaptername substringFromIndex:range.location + [flagString length]];
        return rtnStr;
    }
}

//检测书是否缺资料，如果缺的话就不打包了。
+ (void)checkError {
    NSString *infoStr = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    int num = 10;
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%d",num];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:nil];//
    NSArray *fileList = [NSArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:documentDir error:nil]];
    NSLog(@"开始");
    for (int j = 0; j<[fileList count]; j++) {//count 代表要几本书一组
        NSString *documentName = [fileList objectAtIndex:j];
        
        NSString *bookpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/book",num,documentName];
        NSString *bookdocumentDir = [[NSBundle mainBundle] pathForResource:bookpath ofType:@"txt"];
        if (![fileManager fileExistsAtPath:bookdocumentDir]) {
            infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@书籍不存在\n",documentName]];
            NSLog(@"%@书籍不存在",documentName);
        }else {
            NSData *data = [[NSData alloc] initWithContentsOfFile:bookdocumentDir];
            if ([data length]==0) {
                infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@书籍文件存在但内容为空\n",documentName]];
                NSLog(@"%@书籍文件存在但内容为空",documentName);
            }
        }
        
        NSString *infopath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/info",num,documentName];
        NSString *infodocumentDir = [[NSBundle mainBundle] pathForResource:infopath ofType:@"txt"];
        if (![fileManager fileExistsAtPath:infodocumentDir]) {
            infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@书名和作者名不存在\n",documentName]];
            NSLog(@"%@书名和作者名不存在",documentName);
        }else {
            NSData *data = [[NSData alloc] initWithContentsOfFile:infodocumentDir];
            if ([data length]==0) {
                infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@书名和作者名的文件存在,但内容为空\n",documentName]];
                NSLog(@"%@书名和作者名的文件存在,但内容为空",documentName);
            }
        }
        
        NSString *coverpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/cover",num,documentName];
        NSString *coverdocumentDir = [[NSBundle mainBundle] pathForResource:coverpath ofType:@"jpg"];
        if (![fileManager fileExistsAtPath:coverdocumentDir]) {
            infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@封面不存在\n",documentName]];
            NSLog(@"%@封面不存在",documentName);
        }
        
        NSString *iconpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/icon",num,documentName];
        NSString *icondocumentDir = [[NSBundle mainBundle] pathForResource:iconpath ofType:@"jpg"];
        if (![fileManager fileExistsAtPath:icondocumentDir]) {
            infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@icon不存在\n",documentName]];
            NSLog(@"%@icon不存在",documentName);
        }
        
        NSString *zjifpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/zjinfo",num,documentName];
        NSString *zjifdocumentDir = [[NSBundle mainBundle] pathForResource:zjifpath ofType:@"txt"];
        if (![fileManager fileExistsAtPath:zjifdocumentDir]) {
            infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@章节信息不存在\n",documentName]];
            NSLog(@"%@章节信息不存在",documentName);
        }else {
            NSData *data = [NSData dataWithContentsOfFile:zjifdocumentDir];
            NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *chaptersName = [[txt componentsSeparatedByString:@"\n"] objectAtIndex:0];
            chaptersName = [self getChapterName:chaptersName];
            if ([chaptersName length]==0) {
                infoStr = [infoStr stringByAppendingString:[NSString stringWithFormat:@"%@章节信息有误\n",documentName]];
                NSLog(@"%@章节信息有误",documentName);
            }
        }
    }
    NSLog(@"结束");
    NSLog(@"检查完毕！");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"info.txt"];
    [infoStr writeToFile:plistPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (void)copyFile {
    NSString *pathName = [NSString stringWithFormat:@"BookDoc/Book/%d",GroupNum];
    NSString *documentDir = [[NSBundle mainBundle] pathForResource:pathName ofType:nil];//
    //NSMutableArray *fileList = [[[NSMutableArray alloc] init] autorelease];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *fileList = [NSMutableArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:documentDir error:nil]];
    
    //第一个书的总数：booksCount
    //第二个是每组多少书：countPerGroup
    //第三个是分成多少组：groups
    int booksCount = [fileList count];
    int countPerGroup = 30;
    int groups = 4;
    //    int allBooksCount = countPerGroup * groups;
    
    
    /////
    NSMutableArray *booksMutableArray = [NSMutableArray arrayWithCapacity:booksCount];
    for(int i = 0; i < booksCount; ++i) {
        id object = [fileList objectAtIndex:i];
        [booksMutableArray addObject:object];
    }//这个模拟创建这个booksArray，里面是每本书的uid
    
    
    
    int delta = 0;
    NSAssert(booksCount != 0, @"boosCount = 0, there is no books to group!!");
    int peishu = countPerGroup * groups / booksCount;
    NSLog(@"peishu = %d", peishu);
    if(peishu > 0) {
        delta = countPerGroup * groups - peishu * booksCount;//delta有可能是正的也可能是负的
    }
    else {
        NSAssert(false, @"分组后的数据比总数还少，不希望有这种情况发生");
    }
    
    NSLog(@"delta = %d", delta);
    
    
    int groupsLength = peishu;
    NSMutableArray *groupsArray;
    if(delta > 0) {
        groupsArray = [NSMutableArray arrayWithCapacity:groupsLength];
        //说明书的总数不够，需要多弄几本补充一下
    }
    else if(delta < 0) {
        groupsLength = peishu - 1;
        groupsArray = [NSMutableArray arrayWithCapacity:groupsLength];
        //说明书的总数大于分组的这些书
    }
    else {
        groupsArray = [NSMutableArray arrayWithCapacity:groupsLength];
        //delta = 0,说明书的总数正好够分这么多组
    }
    
    
    for(int i = 0; i < groupsLength; i++) {
        NSMutableArray *tmpBooks = [booksMutableArray copy];
        [groupsArray addObject:tmpBooks];
    }
    
    
    NSLog(@"groupsLength = %d", [groupsArray count]);
    
    int groupIdx = 0;
    for(int i = 0; i < [groupsArray count]; ++i) {
        NSMutableArray *books = [NSMutableArray arrayWithArray:[groupsArray objectAtIndex:i]];
        while ([books count] > 0) {
            int rand = arc4random() % [books count];
            NSString *documentName = [books objectAtIndex:rand];
            
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *folderPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",groupIdx]];
            NSArray *folderArray = [NSArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:folderPath error:nil]];
            if (![folderArray containsObject:documentName]) {
                [self addBookWithGroundIndex:groupIdx andDocumentName:documentName];
                [books removeObjectAtIndex:rand];
                groupIdx++;
                if(groupIdx >= groups)
                    groupIdx = 0;
            }
            //            NSLog(@"分给第%d组: %@", groupIdx, [books objectAtIndex:rand]);
        }
    }
    
    
    
    if(delta != 0) {
        NSMutableArray *deltaBooks = [NSMutableArray arrayWithCapacity:delta];
        NSMutableArray *tmpBooksArray = [NSMutableArray arrayWithArray:booksMutableArray];
        for (int i = 0; i < abs(delta); i++) {
            int rand = arc4random() % [tmpBooksArray count];
            NSLog(@"rand = %03d", rand);
            [deltaBooks addObject:[tmpBooksArray objectAtIndex:rand]];
            [tmpBooksArray removeObjectAtIndex:rand];
        }
        //[groupsArray addObject:deltaBooks];
        
        while ([deltaBooks count] > 0) {
            int rand = arc4random() % [deltaBooks count];
            NSString *documentName = [deltaBooks objectAtIndex:rand];
            
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *folderPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",groupIdx]];
            NSArray *folderArray = [NSArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:folderPath error:nil]];
            if (![folderArray containsObject:documentName]) {
                [self addBookWithGroundIndex:groupIdx andDocumentName:documentName];
                [deltaBooks removeObjectAtIndex:rand];
                groupIdx++;
                if(groupIdx >= groups)
                    groupIdx = 0;
            }
            //            NSLog(@"分给第%d组: %@", groupIdx, [deltaBooks objectAtIndex:rand]);
        }
    }
}

+ (void)addBookWithGroundIndex:(int)index andDocumentName:(NSString *)documentName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",index]];
    //    NSArray *folderArray = [NSArray arrayWithArray:[fileManager contentsOfDirectoryAtPath:folderPath error:nil]];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *newPath = [folderPath stringByAppendingPathComponent:documentName];
    [fileManager createDirectoryAtPath:newPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *kbookPath = [[folderPath stringByAppendingPathComponent:documentName]  stringByAppendingPathComponent:@"book.txt"];
    NSString *kinfoPath = [[folderPath stringByAppendingPathComponent:documentName]  stringByAppendingPathComponent:@"info.txt"];
    NSString *kcoverPath = [[folderPath stringByAppendingPathComponent:documentName]  stringByAppendingPathComponent:@"cover.jpg"];
    NSString *kiconPath = [[folderPath stringByAppendingPathComponent:documentName]  stringByAppendingPathComponent:@"icon.jpg"];
    NSString *kzjifPath = [[folderPath stringByAppendingPathComponent:documentName] stringByAppendingPathComponent:@"zjinfo.txt"];
    
    //将数据创建到新文件夹中...
    NSString *bookpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/book",GroupNum,documentName];
    NSString *bookdocumentDir = [[NSBundle mainBundle] pathForResource:bookpath ofType:@"txt"];
    NSData *book = [NSData dataWithContentsOfFile:bookdocumentDir];
    [book writeToFile:kbookPath atomically:YES];
    
    NSString *infopath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/info",GroupNum,documentName];
    NSString *infodocumentDir = [[NSBundle mainBundle] pathForResource:infopath ofType:@"txt"];
    NSData *info = [NSData dataWithContentsOfFile:infodocumentDir];
    [info writeToFile:kinfoPath atomically:YES];
    
    NSString *coverpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/cover",GroupNum,documentName];
    NSString *coverdocumentDir = [[NSBundle mainBundle] pathForResource:coverpath ofType:@"jpg"];
    NSData *cover = [NSData dataWithContentsOfFile:coverdocumentDir];
    [cover writeToFile:kcoverPath atomically:YES];
    
    NSString *iconpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/icon",GroupNum,documentName];
    NSString *icondocumentDir = [[NSBundle mainBundle] pathForResource:iconpath ofType:@"jpg"];
    NSData *icon = [NSData dataWithContentsOfFile:icondocumentDir];
    [icon writeToFile:kiconPath atomically:YES];
    
    NSString *zjifpath = [NSString stringWithFormat:@"BookDoc/Book/%d/%@/zjinfo",GroupNum,documentName];
    NSString *zjifdocumentDir = [[NSBundle mainBundle] pathForResource:zjifpath ofType:@"txt"];
    NSData *zjif = [NSData dataWithContentsOfFile:zjifdocumentDir];
    [zjif writeToFile:kzjifPath atomically:YES];
}

+ (void)createTxtInfo {
    NSArray *array = [NSArray arrayWithArray:[self getAllBookId]];
    NSMutableString *infoStr = [NSMutableString stringWithString:@"此合集包括下列书籍：\n"];
    for (int i = 0; i<[array count]; i++) {
        [infoStr appendFormat:@"%02d.", i + 1];
        
        NSString *bookname = [self getBookNameByBookId:[array objectAtIndex:i]];
        bookname = [bookname stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        bookname = [bookname stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        bookname = [NSString stringWithFormat:@"《%@》", bookname];
        
        [infoStr appendString:bookname];
        
        //assume the max length of book name is 11, if less than 11, than append "Chinese space" to make length equals 11
        const int placementLength = 11;
        if([bookname length] < placementLength) {
            for(int i = 0; i < placementLength - [bookname length]; ++i) {
                [infoStr appendString:[NSString ChineseSpace]];
            }
        }
        
        //TODO: assume bookname only contains one “ or ”, not perfect
        NSRange range = [bookname rangeOfString:@"“"];
        if(range.location != NSNotFound) {
            [infoStr appendString:[NSString ChineseSpace]];
        }
        
        NSString *authorname = [self getAuthorNameByBookId:[array objectAtIndex:i]];
        authorname = [authorname stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        authorname = [authorname stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        authorname = [NSString stringWithFormat:@"作者：%@\n",authorname];
        
        [infoStr appendString:authorname];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"info.txt"];
    [infoStr writeToFile:plistPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSInteger)getIndex:(NSString *)bookid {
    return [[self getAllBookId] indexOfObject:bookid];
}

+ (void)saveBookAndChapter
{
    NSArray *bookidArray = [[NSArray alloc] initWithArray:[self getAllBookId]];
    for (int i = 0; i<[bookidArray count]; i++) {
        NSString *bookID = [bookidArray objectAtIndex:i];
        NSString *bookName = [self getBookNameByBookId:bookID];
        NSString *authorName = [self getBookNameByBookId:bookID];
        NSDictionary *dict = @{@"bookName": bookName,@"authorName": authorName,@"bookId" :@(bookID.integerValue)};
        Book *book = (Book *)[Book createWithAttributes:dict];
        book.bFav = [NSNumber numberWithBool:YES];
        book.cover = [self getBookImageDataWithBookId:bookID];
        [book persistWithBlock:nil];
        [self saveChapterBookID:bookID];
    }
}

+ (void)saveChapterBookID:(NSString *)bookid
{
    NSArray *chaptersNameArray = [self getchaptersByBookId:bookid];
    NSMutableString *content = [@"" mutableCopy];
    [content setString:[self getTextWithBookId:bookid]];
    NSMutableArray *chapterObjArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< [chaptersNameArray count]; i++) {
        Chapter *chapter = [Chapter MR_createInContext:[BRContextManager memoryOnlyContext]];
        chapter.name = chaptersNameArray[i];
        chapter.bid = bookid;
        chapter.uid = [NSString stringWithFormat:@"%@%d",bookid,i];
        chapter.bVip = @(NO);
        if (i == [chaptersNameArray count]-1) {
            NSRange range = [content rangeOfString:chaptersNameArray[i]];
            chapter.content = [content substringFromIndex:range.location + range.length];
        } else {
            chapter.content = [NSString str:content value1:chaptersNameArray[i] value2:chaptersNameArray[i+1]];
        }
        [chapterObjArray addObject:chapter];
    }
    [Chapter persist:chapterObjArray withBlock:nil];
}


//三个参数
//第一个书的总数：booksCount
//第二个是每组多少书：countPerGroup
//第三个是分成多少组：groups
//
//用这三个参数去写就行了啊
//
//
//booksArray；
//
//要增减的量
//int delta = countPerGroup * groups - booksCount;
//
//
//创建groups个booksArray的拷贝，
//最后一个拷贝增减delta数量的书后再把所有书都统统放到一个数组里，这个数组的长度是countPerGroup * groups
//然后这个大数组循环发给每一组

@end

