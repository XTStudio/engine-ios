//
//  EDOExecuter.h
//  Endo-iOS
//
//  Created by PonyCui on 2018/11/6.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface EDOFactory : NSObject

+ (nonnull JSContext *)decodeContextFromBundle:(nonnull  NSString *)named;

+ (nonnull JSContext *)decodeContextFromString:(nonnull NSString *)script;

+ (nonnull JSContext *)decodeContextFromBundle:(nonnull NSString *)named
                           withDebuggerAddress:(NSString *)debuggerAddress
                                  onReadyBlock:(void (^)(JSContext *))onReadyBlock;

+ (nullable id)objectFromContext:(nonnull JSContext *)context
                        withName:(nullable NSString *)named;

+ (nullable UIView *)viewFromContext:(nonnull JSContext *)context
                            withName:(nullable NSString *)named;

+ (nullable UIViewController *)viewControllerFromContext:(nonnull JSContext *)context
                                                withName:(nullable NSString *)named;

@end

NS_ASSUME_NONNULL_END
