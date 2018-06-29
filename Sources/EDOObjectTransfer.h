//
//  EDOObjectTransfer.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/6.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"

@interface EDOObjectTransfer : NSObject

+ (JSValue *)convertToJSValueWithObject:(NSObject *)anObject context:(JSContext *)context;

+ (NSDictionary *)convertToJSDictionaryWithNSDictionary:(NSDictionary *)nsDictionary context:(JSContext *)context;

+ (NSArray *)convertToJSArgumentsWithNSArguments:(NSArray *)nsArguments context:(JSContext *)context;

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue owner:(JSValue *)owner;

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue eageringType:(NSString *)eageringType owner:(JSValue *)owner;

+ (NSDictionary *)convertToNSDictionaryWithJSDictionary:(NSDictionary *)jsDictionary owner:(JSValue *)owner;

+ (NSArray *)convertToNSArgumentsWithJSArguments:(NSArray *)jsArguments owner:(JSValue *)owner;

+ (void)setArgumentToInvocation:(NSInvocation *)invocation idx:(unsigned long)idx obj:(id)obj argumentType:(char[256])argumentType;

+ (JSValue *)getReturnValueFromInvocation:(NSInvocation *)invocation valueType:(char[256])valueType context:(JSContext *)context;

@end
