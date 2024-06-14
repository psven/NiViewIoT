//
//  IVBlockOperation.h
//  IoTVideo
//
//  Created by JonorZhang on 2022/03/11.
//  Copyright © 2022 Tencentcs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IVBlockOperation;
typedef void (^IVAsyncBlock)(IVBlockOperation *op);

@interface IVBlockOperation : NSOperation

- (nonnull instancetype)initWithBlock:(IVAsyncBlock)block;
+ (nonnull instancetype)operationWithBlock:(IVAsyncBlock)block;
- (void)complete;

@end

NS_ASSUME_NONNULL_END
