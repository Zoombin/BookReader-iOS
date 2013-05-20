//
//  MobileProbe.h
//  iOS-SDK
//
//  Created by Jin Zhang on 12-5-2.
//  Copyright (c) 2012年 Aliyun-CNZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileProbe : NSObject

#pragma mark basic static
/* 启动统计服务
 * 参数说明:
 *    appkey:在mobile.cnzz.com上添加App后获得的AppKey。
 *    channel:该App推广的渠道名。不同渠道的App需要分别打包。
 * 使用方法:
 *    在AppDelegate的application didFinishLaunchingWithOptions方法中调用。
 */
+ (void)initWithAppKey:(NSString *)appkey channel:(NSString *)channel;

/* 页面统计函数
 * 参数说明:
 *    name:该页面的名称，请务必保证每个页面名称唯一。
 * 使用方法:
 *    在ViewController的viewDidAppear中调用pageBeginWithName。
 *    在ViewController的viewDidDisappear中调用pageEndWithName。
 *    保证同一个View中的Page Name相同
 */
+ (void)pageBeginWithName:(NSString *)name;
+ (void)pageEndWithName:(NSString *)name;

#pragma mark custom events
/* 触发事件
 * 参数说明:
 *    name:事件名称
 *    count:事件计数
 * 使用说明:
 *    同名称的事件会在后台进行计数统计。
 */
+ (void)triggerEventWithName:(NSString *)name count:(int)count;

/* 持续事件
 * 参数说明:
 *    name:事件名称
 * 使用说明:
 *    请确保2个函数的成对调用，并保持名称一致。
 *    同名称的事件会在后台进行时间统计。
 */
+ (void)segmentBeginWithName:(NSString *)name;
+ (void)segmentEndWithName:(NSString *)name;

#pragma mark error logger
/* 错误记录
 * 参数说明:
 *    error:错误描述
 * 使用说明:
 *    传回的错误消息会在web上统计并展示。
 */
+ (void)reportError:(NSString *)error;

@end
