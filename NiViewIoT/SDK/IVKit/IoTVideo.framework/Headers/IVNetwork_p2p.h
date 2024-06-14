//
//  IVNetwork_p2p.h
//  IoTVideo
//
//  Created by ZhaoYong on 2020/2/25.
//  Copyright © 2020 Tencentcs. All rights reserved.
//
//  实现一个通过p2p的网络请求，使得增值服务可以引用核心库实现网络请求
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^IVNetworkResponseHandler)(NSString * _Nullable json, NSError * _Nullable error);

@interface IVNetwork_p2p : NSObject

/// 消息管理单例
@property (class, nonatomic, strong, readonly) IVNetwork_p2p *sharedInstance;
/// 回调线程 默认主线程
@property (nonatomic, strong, nullable) dispatch_queue_t responseQueue;

+ (instancetype)sharedInstance;

/// p2p专用网络请求
/// @param methodType 请求方式: “GET”、“POST”、“PUT”
/// @param urlString 请求地址
/// @param params 请求参数
/// @param response 回调
- (void)requestWithMethodType:(NSString *_Nonnull)methodType
                    urlString:(NSString *_Nullable)urlString
                       params:(NSDictionary<NSString *, id> *_Nullable)params
                     response:(void (^_Nullable)(NSString *_Nullable, NSError *_Nullable))response;

/// p2p专用网络请求
/// @param methodType 请求方式: “GET”、“POST”、“PUT”
/// @param urlString 请求地址
/// @param params 请求参数
/// @param queue 回调线程 不传则默认在全局 global 线程回调
/// @param response 回调
- (void)requestWithMethodType:(NSString *_Nonnull)methodType
                    urlString:(NSString *_Nullable)urlString
                       params:(NSDictionary<NSString *, id> *_Nullable)params
                        queue:(dispatch_queue_t _Nullable)queue
                     response:(void (^_Nullable)(NSString *_Nullable, NSError *_Nullable))response;

@end

NS_ASSUME_NONNULL_END
