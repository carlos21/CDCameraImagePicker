//
//  ExceptionCatcher.m
//  CDCameraImagePicker
//
//  Created by Carlos Duclos on 18/01/25.
//  Copyright © 2025 CDCameraImagePicker. All rights reserved.
//


#import "ExceptionCatcher.h"

@implementation ExceptionCatcher

+ (BOOL)tryBlock:(void(^)(void))block error:(NSError * _Nullable * _Nullable)error {
    @try {
        if (block) {
            block();
        }
        return YES;
    } @catch (NSException *exception) {
        if (error) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: exception.reason ?: @"An unknown exception occurred" };
            *error = [NSError errorWithDomain:@"com.example.ExceptionCatcher"
                                         code:0
                                     userInfo:userInfo];
        }
        return NO;
    }
}

@end