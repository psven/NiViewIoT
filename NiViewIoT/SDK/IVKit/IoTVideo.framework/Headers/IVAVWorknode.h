//
//  IVAVWorknode.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/3/15.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, IVAVWorknodeState) {
    IVAVWorknodeStateReady = 0, // default
    IVAVWorknodeStateRunning,
    IVAVWorknodeStateSuspended,
    IVAVWorknodeStateCompleted,
    IVAVWorknodeStateCancelled,
};

typedef NS_OPTIONS(NSUInteger, IVAVWorknodeFlags) {
    IVAVWorknodeFlagsNone  = 0,         // 未知

    IVAVWorknodeFlagsVideo = 1 << 0,    // 视频流
    IVAVWorknodeFlagsAudio = 1 << 1,    // 音频流
    IVAVWorknodeFlagsText  = 1 << 2,    // 文本
    IVAVWorknodeFlagsURL   = 1 << 3,    // 链接
    IVAVWorknodeFlagsData  = 1 << 4,    // 二进制数据

    IVAVWorknodeFlagsAny   = UINT_MAX,  // 任何数据
};
typedef IVAVWorknodeFlags IVAVWorknodeCapability;

@class IVAVWorknode;

@protocol IVAVWorknodeDelegate <NSObject>

@optional

/// 输出额外信息
/// @param worknode 当前节点
/// @param inData 输入数据
/// @param extraInfo 额外信息
- (void)worknode:(IVAVWorknode *)worknode sequence:(NSUInteger)sequence processData:(nullable void *)inData didOutputExtraInfo:(void *)extraInfo;

/// 输出数据
/// @param worknode 当前节点
/// @param inData 输入数据
/// @param outData 输出数据
- (void)worknode:(IVAVWorknode *)worknode sequence:(NSUInteger)sequence processData:(nullable void *)inData didOutputData:(nullable void *)outData;

/// 收到错误
/// @param worknode 当前节点
/// @param inData 输入数据
/// @param error 若成功则为nil
- (void)worknode:(IVAVWorknode *)worknode sequence:(NSUInteger)sequence processData:(nullable void *)inData didReceiveError:(NSError *)error;

/// 状态更新
/// @param worknode 当前节点
/// @param state 当前节点状态
- (void)worknode:(IVAVWorknode *)worknode didChangeState:(IVAVWorknodeState)state;

@end



/*
 工作节点输入输出示意图：
 
                         [节点代理]
                             ▲
                      ┌──────┴──────┐
        (输入数据流)    │             │  (输出数据流)
 ────────────────────►│  节点处理器   ├─────────────────────►
               ┌─────►│             │─────┐
               │      └─────────────┘     ▼
     <必要输入!,可选输入?>               [输出额外信息]
 */

@interface IVAVWorknode : NSObject

/// 节点能处理的数据集
//@property (nonatomic, assign) IVAVWorknodeCapability capability;

/// 节点状态, 默认IVAVWorknodeStateReady
@property (nonatomic, assign) IVAVWorknodeState state;

/// 节点进度 0.0~1.0,  整个工作流的进度应由所有节点中最小的进度决定, 有些节点过程无关所以统一默认1.0
@property (nonatomic, assign) float progress;

/// 节点代理
@property (nonatomic, nullable, weak) id<IVAVWorknodeDelegate> delegate;

/// 下一节点
@property (nonatomic, nullable, strong) IVAVWorknode *next;

/// 已完成的分片序号（用于略过不处理）
@property (nonatomic, strong, nullable) NSMutableSet<NSNumber *> *caches;

/// 构造方法
- (instancetype)initWithDelegate:(nullable id<IVAVWorknodeDelegate>)delegate;

/// 【▶️提交待加工数据】 子类必须重写以进行数据处理
/// @param inData 待加工数据，or NULL to mark EOF
/// @param flags 见IVAVWorknodeFlags
/// @param sequence 分片并发操作序列号，对应TS片段顺序；非分片操作填0
- (void)processData:(nullable void *)inData flags:(IVAVWorknodeFlags)flags sequence:(NSUInteger)sequence;

/// 输入额外信息
- (void)extraInfo:(NSMutableDictionary *)info sequence:(NSUInteger)sequence;

/// 暂停
- (void)suspend;

/// 取消
- (void)cancel;

/// 恢复
- (void)resume;

@end

NS_ASSUME_NONNULL_END
