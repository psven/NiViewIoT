//
//  IVVideoViewAttr.h
//  GWPlayer
//
//  Created by JonorZhang on 2023/10/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IVVideoRenderable;

@interface IVVideoViewAttr : NSObject {
    @package
    /// 指定画面对象
    id<IVVideoRenderable> _Nullable videoView;
    /// 指定画面索引
    NSInteger videoIndex;
    /// 文件保存路径
    NSString * _Nullable savePath;
    /// 视频滤镜，如水印
    NSString * _Nullable filter;
}

+ (instancetype)videoViewAttrWithIndex:(NSInteger)videoIndex
                              savePath:(nullable NSString *)savePath
                                filter:(nullable NSString *)filter;

+ (instancetype)videoViewAttrWithView:(nullable id<IVVideoRenderable>)videoView
                             savePath:(nullable NSString *)savePath
                               filter:(nullable NSString *)filter;

@end

NS_ASSUME_NONNULL_END
