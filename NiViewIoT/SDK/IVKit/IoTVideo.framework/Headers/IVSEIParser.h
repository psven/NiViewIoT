//
//  IVSEIParser.h
//  IoTVideo
//
//  Created by JonorZhang on 2023/3/31.
//  Copyright © 2023 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IVAVDefine.h"

NS_ASSUME_NONNULL_BEGIN


/// 自定义SEI数据包，
/// 使用 @c IVSEIFrameMake(SEIData) 创建
typedef struct IVSEIFrame {
    int16_t  time_zone; //!< 当前码流录制时设备的时区。该值为时区值乘以100所得，范围[-1200，+1200]。例如东8区为800，西5区为-500。
    uint64_t utc_ms;    //!< 当前码流录制时，真实的UTC时间戳，毫秒。
    uint32_t alarm_type;//!< 当前码流存在有哪些告警事件。
    uint16_t saas_len;  //!< saas层自定义SEI数据长度，最大不超过65535字节。
    /**
     * SaaS层自定义SEI数据结构指针, ⚠️指向原数据SEIData中saas_data的位置，不会分配新内存。
     * 其内容为可混合扩展多种数据类型的结构，形如`K V K V ...`，依此递推直至结束
     * 其中, K占1字节，用于指示其后V的结构体类型, K取值见`enum sei_saas_data_type_e`；
     *     V为对应K指示的结构体数据，其字节大小由具体结构体类型决定；
     *
     *      uint8_t    K1;
     *      struct_1  V1;
     *      uint8_t    K2;
     *      struct_2  V2;
     *       ...
     *      uint8_t    Kn;
     *      struct_n  Vn;
     */
    uint8_t *saas_data;
} IVSEIFrame;

/// 从自定义SEIData数据中解析出IVSEIFrame
extern IVSEIFrame IVSEIFrameMake(NSData *SEIData);

NS_ASSUME_NONNULL_END
