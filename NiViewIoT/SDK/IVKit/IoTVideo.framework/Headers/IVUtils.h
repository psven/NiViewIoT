//
//  IVUtils.h
//  IotVideo
//
//  Created by JonorZhang on 2019/11/1.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#ifndef IVUtils_h
#define IVUtils_h

#import <Foundation/Foundation.h>

extern UInt64 strTidToU64(NSString *tid);
extern NSString *u64TidToStr(UInt64 tid);

/// uint8_t *转十六进制NSString
///
/// 仅转换前100个字节，超过部分省略，形如 {length=195, bytes=0x00000000 00000000 00000000...}
/// @param bytes 要转换的bytes
/// @param len bytes长度
/// @return bytes的十六进制字符串
extern NSString *convertBytesToHexStr(const uint8_t *bytes, uint32_t len);

/// uint8_t *转十六进制NSString
///
/// 仅转换前maxLen个字节，超过部分省略，形如 {length=195, bytes=0x00000000 00000000 00000000...}
/// @param bytes 要转换的bytes
/// @param len bytes长度
/// @return bytes的十六进制字符串
extern NSString *convertBytesToHexStr2(const uint8_t *bytes, uint32_t len, uint32_t maxLen);

/// NSData转十六进制NSString
///
/// 仅转换前100个字节，超过部分省略，形如 {length=195, bytes=0x00000000 00000000 00000000...}
/// @param data 要转换的data
/// @return data的十六进制字符串
extern NSString *convertDataToHexStr(NSData *data);


/// NSData转十六进制NSString
///
/// 仅转换前maxLen个字节，超过部分省略，形如 {length=195, bytes=0x00000000 00000000 00000000...}
/// @param data 要转换的data
/// @return data的十六进制字符串
extern NSString *convertDataToHexStr2(NSData *data, uint32_t maxLen);

/// 计算任意时间当天开始时间
///
/// 例如：输入1604073623 ( 2020-10-31 00:00:23 UTC+8) ，输出1604073600 ( 2020-10-31 00:00:00 UTC+8)
/// @param time The time interval since 00:00:00 UTC on 1 January 1970.
/// @return The start time of the date since 00:00:00 UTC on 1 January 1970.
extern NSInteger startTimeOfDate(NSInteger time);


/// 获取SDK运行环境
extern NSString *getSDKEnvironment(void);

/// 加密 rtsp onvif 密码
/// @param password 原始密码
extern NSString *getRtspMd5Paasword(NSString *password);

/// 获取当前设备可用内存(单位：MB）
/// retrun 成功：可用内存大小，失败：NSNotFound
extern double availableMemory(void);

/// 获取当前应用所占用的内存（单位：MB）
/// retrun 成功：已用内存大小，失败：NSNotFound
extern double usedMemory(void);

/// @code NSString *fmtstr(const char *fmt, ...)
#define fmtstr(fmt, ...) [NSString stringWithFormat:@(fmt), ##__VA_ARGS__]

/// @code NSString *fmtstrv(const char *fmt, va_list v)
#define fmtstrv(fmt, v)  [[NSString alloc] initWithFormat:@(fmt) arguments:v]

/// @code const char *fmtchr(const char *fmt, ...)
#define fmtchr(fmt, ...) [fmtstr(fmt, ##__VA_ARGS__) UTF8String]

/// @code const char *fmtchrv(const char *fmt, va_list v)
#define fmtchrv(fmt, v)  [fmtstrv(fmt, v) UTF8String]

#endif /* IVUtils_h */
