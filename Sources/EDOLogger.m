//
//  UULog.m
//  UULog
//
//  Created by PonyCui on 2018/7/3.
//  Copyright © 2018年 XT Studio. All rights reserved.
//

#import "EDOLogger.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@implementation EDOLogger

+ (void)load {
#ifdef DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelVerbose];
#endif
}

+ (void)attachToContext:(JSContext *)context {
    context[@"_UULog"] = self;
    [context setExceptionHandler:^(JSContext *context, JSValue *exception) {
        DDLogError(@"%@", exception.toString);
    }];
    [context evaluateScript:@"function _UULog_ConvertObject(obj) { if (obj === null) { return 'null'; } if (obj === undefined) { return 'undefined'; } return typeof obj === 'object' ? JSON.stringify(obj, undefined, '    ') : obj; } "];
    [context evaluateScript:@"(function(){ var _originMethod = console.log; console.log = function(){ var args = []; for(var i = 0;i < arguments.length;i++){args.push(_UULog_ConvertObject(arguments[i]))}; _UULog.verbose.call(this, args); _originMethod.apply(this, arguments); } })()"];
    [context evaluateScript:@"(function(){ var _originMethod = console.error; console.error = function(){ var args = []; for(var i = 0;i < arguments.length;i++){args.push(_UULog_ConvertObject(arguments[i]))}; _UULog.error.call(this, args); _originMethod.apply(this, arguments); } })()"];
    [context evaluateScript:@"(function(){ var _originMethod = console.warn; console.warn = function(){ var args = []; for(var i = 0;i < arguments.length;i++){args.push(_UULog_ConvertObject(arguments[i]))}; _UULog.warn.call(this, args); _originMethod.apply(this, arguments); } })()"];
    [context evaluateScript:@"(function(){ var _originMethod = console.info; console.info = function(){ var args = []; for(var i = 0;i < arguments.length;i++){args.push(_UULog_ConvertObject(arguments[i]))}; _UULog.info.call(this, args); _originMethod.apply(this, arguments); } })()"];
    [context evaluateScript:@"(function(){ var _originMethod = console.debug; console.debug = function(){ var args = []; for(var i = 0;i < arguments.length;i++){args.push(_UULog_ConvertObject(arguments[i]))}; _UULog.debug.call(this, args); _originMethod.apply(this, arguments); } })()"];
}

+ (void)verbose:(NSArray *)values {
    DDLogVerbose(@"%@", [values componentsJoinedByString:@","]);
}

+ (void)error:(NSArray *)values {
    DDLogError(@"%@", [values componentsJoinedByString:@","]);
}

+ (void)warn:(NSArray *)values {
    DDLogWarn(@"%@", [values componentsJoinedByString:@","]);
}

+ (void)info:(NSArray *)values {
    DDLogInfo(@"%@", [values componentsJoinedByString:@","]);
}

+ (void)debug:(NSArray *)values {
    DDLogDebug(@"%@", [values componentsJoinedByString:@","]);
}

@end
