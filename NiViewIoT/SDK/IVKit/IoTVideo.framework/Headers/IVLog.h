//
//  IVLog.h
//  IoTVideo
//
//  Created by JonorZhang on 2019/12/31.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IVLog_h
#define IVLog_h

/** 
 💡小贴士1：
 当日志等级小于IVLogLevel_TRACE时，对于频繁输出日志的位置使用折叠形式（即统计次数 + 每秒输出一次），如下：
 `{...12}  XXXXXXXX` 表示此处共有12条(包括本条)同类日志，且最后一条日志内容是XXXXXXXX。
 
 💡小贴士2：
  SDK日志提取的正则表达式: (\d\d:\d\d:\d\d.\d\d\d) ((\[P2P\] .*)|(\[SDK\] \[I\]💙 > .*)|(\[(SDK|NET|GDM|VAS)\]) (\[\w\])?([\s\S]*?) ((\[\w+.\w+:\d+ .*)|(L\d+)))
 */
typedef NS_ENUM(NSUInteger, IVLogLevel) {
    /// 不打印日志
    IVLogLevel_OFF   = 0,
    /// 严重
    IVLogLevel_FATAL = 1,
    /// 错误
    IVLogLevel_ERROR = 2,
    /// 警告
    IVLogLevel_WARN  = 3,
    /// 信息
    IVLogLevel_INFO  = 4,
    /// 调试（使用建议：开发中后期）
    IVLogLevel_DEBUG = 5,
    /// 跟踪，非折叠（使用建议：开发前期、定位问题）
    IVLogLevel_TRACE = 6,
};

#endif /* IVLog_h */
