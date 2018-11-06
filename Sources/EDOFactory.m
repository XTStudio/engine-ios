//
//  EDOExecuter.m
//  Endo-iOS
//
//  Created by PonyCui on 2018/11/6.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "EDOFactory.h"
#import "EDOExporter.h"
#import "EDODebugger.h"

@implementation EDOFactory

+ (nonnull JSContext *)decodeContextFromBundle:(nonnull  NSString *)named {
    NSString *path = [[NSBundle mainBundle] pathForResource:named ofType:nil];
    if (path != nil) {
        return [self decodeContextFromString:[NSString stringWithContentsOfFile:path
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:NULL]];
    }
    else {
        return [self decodeContextFromString:@""];
    }
}

+ (nonnull JSContext *)decodeContextFromString:(nonnull NSString *)script {
    JSContext *context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:context];
    if (script != nil) {
        [context evaluateScript:script];
    }
    return context;
}

+ (JSContext *)decodeContextFromBundle:(NSString *)named
                   withDebuggerAddress:(NSString *)debuggerAddress
                          onReadyBlock:(void (^)(JSContext * _Nonnull))onReadyBlock {
    static EDODebugger *sharedDebugger;
    sharedDebugger = [[EDODebugger alloc] initWithRemoteAddress:debuggerAddress];
    [sharedDebugger connect:^(JSContext *context) {
        onReadyBlock(context);
    } fallback:^{ }];
    return [self decodeContextFromBundle:named];
}

+ (nullable id)objectFromContext:(nonnull JSContext *)context withName:(nullable NSString *)named {
    return [[EDOExporter sharedExporter] nsValueWithJSValue:context[named ?: @"main"]];
}

+ (nullable UIView *)viewFromContext:(nonnull JSContext *)context withName:(nullable NSString *)named {
    id value = [self objectFromContext:context withName:named];
    if ([value isKindOfClass:[UIView class]]) {
        return value;
    }
    else {
        return nil;
    }
}

+ (nullable UIViewController *)viewControllerFromContext:(nonnull JSContext *)context withName:(nullable NSString *)named {
    id value = [self objectFromContext:context withName:named];
    if ([value isKindOfClass:[UIViewController class]]) {
        return value;
    }
    else {
        return nil;
    }
}

@end
