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

+ (JSValue *)convertToJSValueWithObject:(NSObject *)anObject;

+ (NSDictionary *)convertToJSDictionaryWithNSArguments:(NSDictionary *)nsDictionary;

+ (NSArray *)convertToJSArgumentsWithNSArguments:(NSArray *)nsArguments;

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue;

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue eageringType:(NSString *)eageringType;

+ (NSDictionary *)convertToNSDictionaryWithJSDictionary:(NSDictionary *)jsDictionary;

+ (NSArray *)convertToNSArgumentsWithJSArguments:(NSArray *)jsArguments;

@end
