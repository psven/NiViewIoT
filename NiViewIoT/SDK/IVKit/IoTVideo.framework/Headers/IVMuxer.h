//
//  IVMuxer.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/3/10.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVAVWorknode.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct AVCodecContext AVCodecContext;

@interface IVMuxer : IVAVWorknode
/*
                                ┌──────────────┐
    (AVPackt *avpackt)          │              │  (NSString *outputPath)
 ──────────────────────────────►│   IVMuxer    ├────────────────────────────►
                        ┌──────►│              │
                        │       └──────────────┘
     @{"fmtCtx":AVFormatContext*!,
       "fps":int?,
       "vc":IVVideoCodecType!,
       "outputPath":NSString*?}
 */

@end

NS_ASSUME_NONNULL_END
