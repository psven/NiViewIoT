//
//  IVRemuxingOperation.h
//  IoTVideo
//
//  Created by JonorZhang on 2021/11/25.
//  Copyright © 2021 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 重封装操作
@interface IVRemuxingOperation : NSObject

@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished)  BOOL finished;
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isPaused)    BOOL paused;



/// 输入文件URL。 合并多个本地文件格式："concat:001.ts|002.ts|003.ts|..."；若为云存文件断点续传时须保证文件时间范围一致（允许签名不一致）
@property (nonatomic, strong, readonly) NSString *inputUrl;

/// 输出文件路径，须含文件名和后缀， 如 "/var/mobile/...xxxx.mp4"，断点续传时须保证文件相对路径一致（允许沙盒唯一编码路径xxxxxx-xxxx-xxxx--xxxx-xxxxxxxxx不一致）
@property (nonatomic, strong, readonly) NSString *outputFile;

/// 临时缓存文件后缀
#define TEMP_FILE_SUFFIX @"temp"
/// 获取缓存文件路径 outputFile + ".temp"，例如</user/xxxx/Documents/1639964278.mp4.temp>，用户可删除此文件以取消缓存数据。
+ (NSString *)getTempFilePath:(NSString *)outputFile;


/// @param onStart 开始回调。
@property (nonatomic, copy, nullable) void (^onStart)(void);

/// @param onProgress 过程回调。  progress:进度0.0～1.0;  rcvBytes:已接收字节数;
@property (nonatomic, copy, nullable) void (^onProgress)(float progress, int rcvBytes);

/// @param onFinish 完成回调。playableDuration: 实际可播放时长(us)；
@property (nonatomic, copy, nullable) void (^onFinish)(int64_t playableDuration);

/// @param onError 错误回调。error：错误原因；
@property (nonatomic, copy, nullable) void (^onError)(NSError *error);

/// @param onCancel 取消回调。
@property (nonatomic, copy, nullable) void (^onCancel)(void);


/// 构建方法
/// @param inputUrl 输入文件URL
/// @param outputFile 输出文件路径，须含文件名和后缀， 如 "/var/mobile/...xxxx.mp4"
- (instancetype)initWithInputUrl:(NSString *)inputUrl outputFile:(NSString *)outputFile;

/// 快速构建方法
/// @param inputUrl 输入文件URL，若为云存文件断点续传时须保证文件时间范围一致（允许签名不一致）
/// @param outputFile  输出文件路径，须含文件名和后缀， 如 "/var/mobile/...xxxx.mp4"，断点续传时须保证文件相对路径一致（允许沙盒唯一编码路径xxxxxx-xxxx-xxxx--xxxx-xxxxxxxxx不一致）
/// @param onStart 开始回调。
/// @param onProgress 过程回调。 progress:进度0.0～1.0;  rcvBytes:已接收字节数;
/// @param onFinish 完成回调。playableDuration: 实际可播放时长(us)；
/// @param onError 错误回调。error：错误原因；
/// @param onCancel 取消回调。
+ (instancetype)remuxingOperationWithInputUrl:(NSString *)inputUrl
                                   outputFile:(NSString *)outputFile
                                      onStart:(nullable void (^)(void))onStart
                                   onProgress:(nullable void (^)(float progress, int rcvBytes))onProgress
                                     onFinish:(nullable void (^)(int64_t playableDuration))onFinish
                                      onError:(nullable void (^)(NSError *error))onError
                                     onCancel:(nullable void (^)(void))onCancel;

/// 附加可选项, 默认nil，应在-start前设置好
/// 例如 @c `options = @{“t”: @(4*USEC_PER_SEC)}`，表示截取前4秒
/// @li -ss    <int64>  start time offset [us]，default to 0 (That is, the beginning of the file);
/// @li -t      <int64>  duration time [us], default to Total-Duration of file;
/// @li -vf    <string> video filters, default to nil;  @see https://ffmpeg.org/ffmpeg-filters.html .  For example,
///               "movie=logo.png[logo]; [logo]colorkey=White:0.2:0.5 [alphawm]; [in][alphawm]overlay=20:20[out]"
///               "split [main][tmp]; [tmp] crop=iw:ih/2:0:0, vflip [flip]; [main][flip] overlay=0:H/2"
///               "vflip" or  "hflip"
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *options;

/// 开始/恢复
- (void)start;

/// 暂停，会保留临时文件<outputFile+".temp">。
/// 若该对象未销毁可通过-start恢复；若该对象销毁后可通过创建具有相同outputFile的对象并-start实现断点续传；
- (void)pause;

/// 取消，会删除临时文件<outputFile+".temp">
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
