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

+ (JSValue *)convertToJSValueWithObject:(NSObject *)anObject context:(JSContext *)context {
    if (anObject == nil) {
        return [JSValue valueWithUndefinedInContext:context ?: [JSContext currentContext]];
    }
    else if ([anObject isKindOfClass:[NSString class]] || [anObject isKindOfClass:[NSNumber class]]) {
        return (JSValue *)anObject;
    }
    else if ([anObject isKindOfClass:[NSDictionary class]]) {
        return (JSValue *)[self convertToJSDictionaryWithNSDictionary:(NSDictionary *)anObject context:context];
    }
    else if ([anObject isKindOfClass:[NSArray class]]) {
        return (JSValue *)[self convertToJSArgumentsWithNSArguments:(NSArray *)anObject context:context];
    }
    else if ([anObject isKindOfClass:[NSValue class]]) {
        NSValue *nsValue = (id)anObject;
        NSString *objcType = [NSString stringWithUTF8String:[nsValue objCType]];
        if ([objcType hasPrefix:@"{CGRect"]) {
            return [JSValue valueWithRect:[nsValue CGRectValue] inContext:context ?: [JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGSize"]) {
            return [JSValue valueWithSize:[nsValue CGSizeValue] inContext:context ?: [JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGPoint"]) {
            return [JSValue valueWithPoint:[nsValue CGPointValue] inContext:context ?: [JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGAffineTransform"]) {
            CGAffineTransform transform = [nsValue CGAffineTransformValue];
            return (JSValue *)@{ @"a": @(transform.a), @"b": @(transform.b), @"c": @(transform.c), @"d": @(transform.d), @"tx": @(transform.tx), @"ty": @(transform.ty) };
        }
        else if ([objcType hasPrefix:@"{UIEdgeInsets"]) {
            UIEdgeInsets edgeInsets = [nsValue UIEdgeInsetsValue];
            return (JSValue *)@{ @"top": @(edgeInsets.top), @"left": @(edgeInsets.left), @"bottom": @(edgeInsets.bottom), @"right": @(edgeInsets.right) };
        }
        else if ([objcType hasPrefix:@"{NSRange"]) {
            NSRange range = [nsValue rangeValue];
            return (JSValue *)@{ @"location": @(range.location), @"length": @(range.length) };
        }
    }
    else {
        return [[EDOExporter sharedExporter] scriptObjectWithObject:anObject];
    }
    return [JSValue valueWithUndefinedInContext:context ?: [JSContext currentContext]];
}

+ (NSDictionary *)convertToJSDictionaryWithNSDictionary:(NSDictionary *)nsDictionary context:(JSContext *)context {
    NSMutableDictionary *jsDictionary = [NSMutableDictionary dictionary];
    for (id aKey in nsDictionary) {
        id value = [self convertToJSValueWithObject:nsDictionary[aKey] context:context];
        if (value != nil) {
            [jsDictionary setObject:value forKey:aKey];
        }
    }
    return jsDictionary.copy;
}

+ (NSArray *)convertToJSArgumentsWithNSArguments:(NSArray *)nsArguments context:(JSContext *)context {
    NSMutableArray *jsArguments = [NSMutableArray array];
    for (id argument in nsArguments) {
        [jsArguments addObject:[self convertToJSValueWithObject:argument context:context] ?: [JSValue valueWithUndefinedInContext:context ?: [JSContext currentContext]] ?: [NSNull null]];
    }
    return jsArguments.copy;
}

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue owner:(JSValue *)owner {
    return [self convertToNSValueWithJSValue:anValue eageringType:nil owner:owner];
}

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue eageringType:(NSString *)eageringType owner:(JSValue *)owner {
    if (anValue.isUndefined) {
        return nil;
    }
    else if ([eageringType hasPrefix:@"{CGRect"]) {
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
    else if ([eageringType hasPrefix:@"{NSRange"] && [anValue isObject]) {
        NSDictionary *dict = [anValue toDictionary];
        return [NSValue valueWithRange:NSMakeRange([dict[@"location"] floatValue],
                                                   [dict[@"length"] floatValue])];
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
            return [self convertToNSDictionaryWithJSDictionary:anValue.toDictionary owner:owner];
        }
    }
    else if (anValue.isArray) {
        return [self convertToNSArgumentsWithJSArguments:anValue.toArray owner:owner];
    }
    else if (anValue.isNumber) {
        return anValue.toNumber;
    }
    else if (anValue.isString) {
        return anValue.toString;
    }
    else if (anValue.isBoolean) {
        return anValue.toNumber;
    }
    return nil;
}

+ (id)convertToNSValueWithPlainValue:(id)plainValue owner:(JSValue *)owner {
    if ([plainValue isKindOfClass:[NSString class]] || [plainValue isKindOfClass:[NSNumber class]]) {
        return plainValue;
    }
    else if ([plainValue isKindOfClass:[NSArray class]]) {
        return [self convertToNSArgumentsWithJSArguments:plainValue owner:owner];
    }
    else if ([plainValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary *metaClassInfo = plainValue[@"_meta_class"];
        if ([metaClassInfo[@"classname"] isKindOfClass:[NSString class]] &&
            [metaClassInfo[@"classname"] isEqualToString:@"__Function"]) {
            JSManagedValue *managedValue = [JSManagedValue managedValueWithValue:owner];
            NSNumber *idx = metaClassInfo[@"idx"];
            return ^(NSArray *nsArguments){
                JSValue *owner = [managedValue value];
                id returnValue;
                if (owner != nil) {
                    returnValue = [owner invokeMethod:@"__invokeCallback" withArguments:@[
                                                                                             idx ?: @(-1),
                                                                                             [self convertToJSArgumentsWithNSArguments:nsArguments
                                                                                                                               context:owner.context]
                                                                                             ]];
                    returnValue = [self convertToNSValueWithJSValue:returnValue owner:returnValue];
                    return returnValue;
                }
                return returnValue;
            };
        }
        else if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
            return [[EDOExporter sharedExporter] nsValueWithObjectRef:metaClassInfo[@"objectRef"]];
        }
        else {
            return [self convertToNSDictionaryWithJSDictionary:plainValue owner:owner] ?: plainValue;
        }
    }
    return nil;
}

+ (NSDictionary *)convertToNSDictionaryWithJSDictionary:(NSDictionary *)jsDictionary owner:(JSValue *)owner {
    NSMutableDictionary *nsDictionary = [NSMutableDictionary dictionary];
    for (NSString *aKey in jsDictionary) {
        id value = [self convertToNSValueWithPlainValue:jsDictionary[aKey] owner:owner];
        if (value != nil) {
            [nsDictionary setObject:value forKey:aKey];
        }
    }
    return nsDictionary.copy;
}

+ (NSArray *)convertToNSArgumentsWithJSArguments:(NSArray *)jsArguments owner:(JSValue *)owner {
    NSMutableArray *nsArguments = [NSMutableArray array];
    for (id argument in jsArguments) {
        [nsArguments addObject:[self convertToNSValueWithPlainValue:argument owner:owner] ?: [NSNull null]];
    }
    return nsArguments.copy;
}

@end
