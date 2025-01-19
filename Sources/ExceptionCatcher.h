//
//  ExceptionCatcher.h
//  CDCameraImagePicker
//
//  Created by Carlos Duclos on 18/01/25.
//  Copyright © 2025 CDCameraImagePicker. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExceptionCatcher : NSObject

/// Executes the provided block and catches any Objective-C exception.
/// @param block The block of code to execute.
/// @param error An optional error pointer that will be populated if an exception is caught.
/// @return YES if the block executed without throwing an exception, NO otherwise.
+ (BOOL)tryBlock:(void(^)(void))block error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END