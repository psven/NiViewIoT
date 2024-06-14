//
//  IVM3U8Parser.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/3/10.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVAVWorknode.h"

NS_ASSUME_NONNULL_BEGIN

@interface IVTSInfo : NSObject {
@public
   /// the duration of ts in milliseconds convert from #EXTINF:3.000,
    NSUInteger msec;
    /// the full url of ts, followed by #EXTINF
    NSString  *url;
}
+ (instancetype)tsUrl:(NSString *)url msec:(NSUInteger)msec;
@end


@interface IVM3U8Info : NSObject {
@public
    NSString *METHOD; //固定AES-128
    NSData   *KEY;
    NSData   *IV;
    NSArray<IVTSInfo *> *tsList;
}
@end


@interface IVM3U8Parser : IVAVWorknode
/*
                                       ┌──────────────┐
        (NSString *fileText)           │              │  (IVM3U8Info *info)
 ─────────────────────────────────────►│ IVM3U8Parser ├──────────────────────►
        or (NSURL *url)                │              │
        or (NSString *url)             └──────────────┘
 */
@end

NS_ASSUME_NONNULL_END
