//
//  EDOObjectTransfer.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/6.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "EDOObjectTransfer.h"
#import "EDOExporter.h"
#import "NSObject+EDOObjectRef.h"

@implementation EDOObjectTransfer

+ (JSValue *)convertToJSValueWithObject:(NSObject *)anObject {
    if ([anObject isKindOfClass:[NSString class]] || [anObject isKindOfClass:[NSNumber class]]) {
        return (JSValue *)anObject;
    }
    else if ([anObject isKindOfClass:[NSDictionary class]]) {
        return (JSValue *)[self convertToJSDictionaryWithNSArguments:(NSDictionary *)anObject];
    }
    else if ([anObject isKindOfClass:[NSArray class]]) {
        return (JSValue *)[self convertToJSArgumentsWithNSArguments:(NSArray *)anObject];
    }
    else if ([anObject isKindOfClass:[NSValue class]]) {
        NSValue *nsValue = (id)anObject;
        NSString *objcType = [NSString stringWithUTF8String:[nsValue objCType]];
        if ([objcType hasPrefix:@"{CGRect"]) {
            return [JSValue valueWithRect:[nsValue CGRectValue] inContext:[JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGSize"]) {
            return [JSValue valueWithSize:[nsValue CGSizeValue] inContext:[JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGPoint"]) {
            return [JSValue valueWithPoint:[nsValue CGPointValue] inContext:[JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGAffineTransform"]) {
            CGAffineTransform transform = [nsValue CGAffineTransformValue];
            return (JSValue *)@{ @"a": @(transform.a), @"b": @(transform.b), @"c": @(transform.c), @"d": @(transform.d), @"tx": @(transform.tx), @"ty": @(transform.ty) };
        }
        else if ([objcType hasPrefix:@"{UIEdgeInsets"]) {
            UIEdgeInsets edgeInsets = [nsValue UIEdgeInsetsValue];
            return (JSValue *)@{ @"top": @(edgeInsets.top), @"left": @(edgeInsets.left), @"bottom": @(edgeInsets.bottom), @"right": @(edgeInsets.right) };
        }
    }
    else {
        return [[EDOExporter sharedExporter] scriptObjectWithObject:anObject];
    }
    return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
}

+ (NSDictionary *)convertToJSDictionaryWithNSArguments:(NSDictionary *)nsDictionary {
    NSMutableDictionary *jsDictionary = [NSMutableDictionary dictionary];
    for (id aKey in nsDictionary) {
        id value = [self convertToJSValueWithObject:nsDictionary[aKey]];
        if (value != nil) {
            [jsDictionary setObject:value forKey:aKey];
        }
    }
    return jsDictionary.copy;
}

+ (NSArray *)convertToJSArgumentsWithNSArguments:(NSArray *)nsArguments {
    NSMutableArray *jsArguments = [NSMutableArray array];
    for (id argument in nsArguments) {
        [jsArguments addObject:[self convertToJSValueWithObject:argument] ?: [JSValue valueWithUndefinedInContext:[JSContext currentContext]] ?: [NSNull null]];
    }
    return jsArguments.copy;
}

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue {
    return [self convertToNSValueWithJSValue:anValue eageringType:nil];
}

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue eageringType:(NSString *)eageringType {
    if ([eageringType hasPrefix:@"{CGRect"]) {
        return [NSValue valueWithCGRect:[anValue toRect]];
    }
    else if ([eageringType hasPrefix:@"{CGSize"]) {
        return [NSValue valueWithCGSize:[anValue toSize]];
    }
    else if ([eageringType hasPrefix:@"{CGPoint"]) {
        return [NSValue valueWithCGPoint:[anValue toPoint]];
    }
    else if ([eageringType hasPrefix:@"{CGAffineTransform"] && [anValue isObject]) {
        NSDictionary *dict = [anValue toDictionary];
        return [NSValue valueWithCGAffineTransform:CGAffineTransformMake([dict[@"a"] floatValue],
                                                                         [dict[@"b"] floatValue],
                                                                         [dict[@"c"] floatValue],
                                                                         [dict[@"d"] floatValue],
                                                                         [dict[@"tx"] floatValue],
                                                                         [dict[@"ty"] floatValue])];
    }
    else if ([eageringType hasPrefix:@"{UIEdgeInsets"] && [anValue isObject]) {
        NSDictionary *dict = [anValue toDictionary];
        return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([dict[@"top"] floatValue],
                                                               [dict[@"left"] floatValue],
                                                               [dict[@"bottom"] floatValue],
                                                               [dict[@"right"] floatValue])];
    }
    else if (anValue.isObject) {
        JSValue *metaClassValue = [anValue objectForKeyedSubscript:@"_meta_class"];
        if (metaClassValue.isObject) {
            NSDictionary *metaClassInfo = metaClassValue.toDictionary;
            if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
                return [[EDOExporter sharedExporter] nsValueWithObjectRef:metaClassInfo[@"objectRef"]];
            }
        }
        else {
            return [self convertToNSDictionaryWithJSDictionary:anValue.toDictionary];
        }
    }
    else if (anValue.isArray) {
        return [self convertToNSArgumentsWithJSArguments:anValue.toArray];
    }
    return nil;
}

+ (id)convertToNSValueWithPlainValue:(id)plainValue {
    if ([plainValue isKindOfClass:[NSString class]] || [plainValue isKindOfClass:[NSNumber class]]) {
        return plainValue;
    }
    else if ([plainValue isKindOfClass:[NSArray class]]) {
        return [self convertToNSArgumentsWithJSArguments:plainValue];
    }
    else if ([plainValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary *metaClassInfo = plainValue[@"_meta_class"];
        if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
            return [[EDOExporter sharedExporter] nsValueWithObjectRef:metaClassInfo[@"objectRef"]];
        }
        else {
            return [self convertToNSDictionaryWithJSDictionary:plainValue] ?: plainValue;
        }
    }
    return nil;
}

+ (NSDictionary *)convertToNSDictionaryWithJSDictionary:(NSDictionary *)jsDictionary {
    NSMutableDictionary *nsDictionary = [NSMutableDictionary dictionary];
    for (NSString *aKey in jsDictionary) {
        id value = [self convertToNSValueWithPlainValue:jsDictionary[aKey]];
        if (value != nil) {
            [nsDictionary setObject:value forKey:aKey];
        }
    }
    return nsDictionary.copy;
}

+ (NSArray *)convertToNSArgumentsWithJSArguments:(NSArray *)jsArguments {
    NSMutableArray *nsArguments = [NSMutableArray array];
    for (id argument in jsArguments) {
        [nsArguments addObject:[self convertToNSValueWithPlainValue:argument] ?: [NSNull null]];
    }
    return nsArguments.copy;
}

@end
