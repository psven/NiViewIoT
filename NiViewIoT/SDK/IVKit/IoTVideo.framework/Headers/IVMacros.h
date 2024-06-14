//
//  IVMacros.h
//  IoTVideo
//
//  Created by JonorZhang on 2020/11/2.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

#ifndef IVMacros_h
#define IVMacros_h

#import <Foundation/Foundation.h>

#pragma mark - 对象弱引用

// usage: @weakify(target)
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##object = object;
        #endif
    #endif
#endif

// usage: @strongify(target)
#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##object;
        #endif
    #endif
#endif



#pragma mark - dispatch线程安全

NS_INLINE
void dispatch_async_safe(dispatch_queue_t queue, dispatch_block_t block) {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    } else {
        dispatch_async(queue, ^{
            block();
        });
    }
}

NS_INLINE
void dispatch_sync_safe(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block) {
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {
        block();
    } else {
        dispatch_sync(queue, ^{
            block();
        });
    }
}

NS_INLINE
void dispatch_main_async_safe(dispatch_block_t block) {
    dispatch_async_safe(dispatch_get_main_queue(), block);
}

NS_INLINE
void dispatch_main_sync_safe(DISPATCH_NOESCAPE dispatch_block_t block) {
    dispatch_sync_safe(dispatch_get_main_queue(), block);
}

NS_INLINE
void dispatch_async_global(DISPATCH_NOESCAPE dispatch_block_t block) {
    dispatch_async_safe(dispatch_get_global_queue(0, 0), block);
}


#pragma mark - 安全执行Block

#define exec_safe(block, ...) if (block) { block(__VA_ARGS__); };

#define exec_main_async_safe(block, ...) if (block) { dispatch_async_safe(dispatch_get_main_queue(), ^{block(__VA_ARGS__);}); }
#define exec_main_sync_safe(block, ...) if (block) { dispatch_sync_safe(dispatch_get_main_queue(), ^{block(__VA_ARGS__);}); }


#pragma mark - Objective-C版本的defer实现

#define concat(a,b) a##b
NS_INLINE void cleanup_func(__strong os_block_t *blockRef) {
    (*blockRef)();
}

/// @define Objective-C版本的defer实现
///
/// cleanup (cleanup_function)
/// The cleanup attribute runs a function when the variable goes out of scope. This attribute can only be applied to auto function scope variables; it may not be applied to parameters or variables with static storage duration. The function must take one parameter, a pointer to a type compatible with the variable. The return value of the function (if any) is ignored.
/// If -fexceptions is enabled, then cleanup_function is run during the stack unwinding that happens during the processing of the exception. Note that the cleanup attribute does not allow the exception to be caught, only to perform an action. It is undefined what happens if cleanup_function does not return normally.
/// 
/// Usage:
///     - (void)deferTest
///         objc_defer {
///             NSLog(@"defer here");
///         };
///         NSLog(@"do something here");
///     }
#define objc_defer \
    __strong os_block_t concat(__defer_block_, __LINE__) __attribute__((cleanup(cleanup_func), unused)) = ^


/// 放在函数入口处，自动上锁和解锁
/// Usage:
///     - (void)deferTest
///         auto_lock_unlock(_lock);
///         NSLog(@"do something here");
///     }
///
/// - aLock:  NSLock对象，由调用方传入
#define auto_lock_unlock(aLock) [aLock lock]; objc_defer{ [aLock unlock]; };
    
#endif /* IVMacros_h */

