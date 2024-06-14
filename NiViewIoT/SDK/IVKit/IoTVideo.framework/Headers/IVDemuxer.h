//
//  IVDemuxer.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/3/10.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVAVWorknode.h"

NS_ASSUME_NONNULL_BEGIN

@interface IVDemuxer : IVAVWorknode
/*
                           ┌──────────────┐
    (NSString *filePath)   │              │  (AVPackt *avpackt)
 ─────────────────────────►│  IVDemuxer   ├─────────────────────────►
    or (NSURL *fileUrl)    │              │─────┐
                           └──────────────┘     ▼
                                        @{"fmtCtx":AVFormatContext*}
 */

@end

NS_ASSUME_NONNULL_END
