//
//  IVTSDownloader.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/3/10.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVAVWorknode.h"

NS_ASSUME_NONNULL_BEGIN

@interface IVTSDownloader : IVAVWorknode
/*
                      ┌────────────────┐
  (IVM3U8Info *info)  │                │  @{"file":NSURL*, "key":NSData*, "iv":NSData*}
 ────────────────────►│ IVTSDownloader ├────────────────────────────────────────►
               ┌─────►│                │──────┐
               │      └────────────────┘      ▼
     @{"folder":NSString*!}              @{"t":NSNumber*}
 */
@end

NS_ASSUME_NONNULL_END
