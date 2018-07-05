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
    else if ([anObject isKindOfClass:[JSValue class]]) {
        return (JSValue *)anObject;
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
        if ([objcType hasPrefix:@"{CGRect"] || [objcType hasPrefix:@"{_CGRect"]) {
            return [JSValue valueWithRect:[nsValue CGRectValue] inContext:context ?: [JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGSize"] || [objcType hasPrefix:@"{_CGSize"]) {
            return [JSValue valueWithSize:[nsValue CGSizeValue] inContext:context ?: [JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGPoint"] || [objcType hasPrefix:@"{_CGPoint"]) {
            return [JSValue valueWithPoint:[nsValue CGPointValue] inContext:context ?: [JSContext currentContext]];
        }
        else if ([objcType hasPrefix:@"{CGAffineTransform"] || [objcType hasPrefix:@"{_CGAffineTransform"]) {
            CGAffineTransform transform = [nsValue CGAffineTransformValue];
            return (JSValue *)@{ @"a": @(transform.a), @"b": @(transform.b), @"c": @(transform.c), @"d": @(transform.d), @"tx": @(transform.tx), @"ty": @(transform.ty) };
        }
        else if ([objcType hasPrefix:@"{UIEdgeInsets"] || [objcType hasPrefix:@"{_UIEdgeInsets"]) {
            UIEdgeInsets edgeInsets = [nsValue UIEdgeInsetsValue];
            return (JSValue *)@{ @"top": @(edgeInsets.top), @"left": @(edgeInsets.left), @"bottom": @(edgeInsets.bottom), @"right": @(edgeInsets.right) };
        }
        else if ([objcType hasPrefix:@"{NSRange"] || [objcType hasPrefix:@"{_NSRange"]) {
            NSRange range = [nsValue rangeValue];
            return (JSValue *)@{ @"location": @(range.location), @"length": @(range.length) };
        }
    }
    else {
        return [[EDOExporter sharedExporter] scriptObjectWithObject:anObject context:context initializer:nil createIfNeeded:YES];
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
    else if ([eageringType hasPrefix:@"{CGRect"] || [eageringType hasPrefix:@"{_CGRect"]) {
        return [NSValue valueWithCGRect:[anValue toRect]];
    }
    else if ([eageringType hasPrefix:@"{CGSize"] || [eageringType hasPrefix:@"{_CGSize"]) {
        return [NSValue valueWithCGSize:[anValue toSize]];
    }
    else if ([eageringType hasPrefix:@"{CGPoint"] || [eageringType hasPrefix:@"{_CGPoint"]) {
        return [NSValue valueWithCGPoint:[anValue toPoint]];
    }
    else if (([eageringType hasPrefix:@"{CGAffineTransform"] || [eageringType hasPrefix:@"{_CGAffineTransform"]) && [anValue isObject]) {
        NSDictionary *dict = [anValue toDictionary];
        return [NSValue valueWithCGAffineTransform:CGAffineTransformMake([dict[@"a"] floatValue],
                                                                         [dict[@"b"] floatValue],
                                                                         [dict[@"c"] floatValue],
                                                                         [dict[@"d"] floatValue],
                                                                         [dict[@"tx"] floatValue],
                                                                         [dict[@"ty"] floatValue])];
    }
    else if (([eageringType hasPrefix:@"{UIEdgeInsets"] || [eageringType hasPrefix:@"{_UIEdgeInsets"]) && [anValue isObject]) {
        NSDictionary *dict = [anValue toDictionary];
        return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake([dict[@"top"] floatValue],
                                                               [dict[@"left"] floatValue],
                                                               [dict[@"bottom"] floatValue],
                                                               [dict[@"right"] floatValue])];
    }
    else if (([eageringType hasPrefix:@"{NSRange"] || [eageringType hasPrefix:@"{_NSRange"]) && [anValue isObject]) {
        NSDictionary *dict = [anValue toDictionary];
        return [NSValue valueWithRange:NSMakeRange([dict[@"location"] floatValue],
                                                   [dict[@"length"] floatValue])];
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
    else if (anValue.isObject) {
        JSValue *metaClassValue = [anValue objectForKeyedSubscript:@"_meta_class"];
        if (metaClassValue.isObject) {
            NSDictionary *metaClassInfo = metaClassValue.toDictionary;
            if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
                return [[EDOExporter sharedExporter] nsValueWithObjectRef:metaClassInfo[@"objectRef"]] ?: anValue;
            }
        }
        else {
            return [self convertToNSDictionaryWithJSDictionary:anValue.toDictionary owner:owner];
        }
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
            return ^(NSArray *nsArguments, BOOL eagerJSValue){
                JSValue *owner = [managedValue value];
                id returnValue;
                if (owner != nil) {
                    returnValue = [owner invokeMethod:@"__invokeCallback" withArguments:@[
                                                                                          idx ?: @(-1),
                                                                                          [self convertToJSArgumentsWithNSArguments:nsArguments
                                                                                                                            context:owner.context]
                                                                                          ]];
                    returnValue = eagerJSValue ? returnValue : [self convertToNSValueWithJSValue:returnValue owner:returnValue];
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

+ (void)setArgumentToInvocation:(NSInvocation *)invocation idx:(unsigned long)idx obj:(id)obj argumentType:(char [256])argumentType {
    if (strcmp(argumentType, "@") == 0) {
        [invocation setArgument:&obj atIndex:idx];
    }
    else if (strcmp(argumentType, "i") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        int argument = [obj intValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "s") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        short argument = [obj shortValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "l") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        long argument = [obj longValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "q") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        long long argument = [obj longLongValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "I") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        unsigned int argument = [obj unsignedIntValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "S") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        unsigned short argument = [obj unsignedShortValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "L") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        unsigned long argument = [obj unsignedLongValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "Q") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        unsigned long long argument = [obj unsignedLongLongValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "f") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        float argument = [obj floatValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "d") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        double argument = [obj doubleValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else if (strcmp(argumentType, "B") == 0 && [obj isKindOfClass:[NSNumber class]]) {
        bool argument = [obj boolValue];
        [invocation setArgument:&argument atIndex:idx];
    }
    else {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSString *objcType = [NSString stringWithUTF8String:argumentType];
            if ([objcType hasPrefix:@"{CGRect"] || [objcType hasPrefix:@"{_CGRect"]) {
                CGRect argument = CGRectMake([obj[@"x"] floatValue],
                                             [obj[@"y"] floatValue],
                                             [obj[@"width"] floatValue],
                                             [obj[@"height"] floatValue]);
                [invocation setArgument:&argument atIndex:idx];
            }
            else if ([objcType hasPrefix:@"{CGSize"] || [objcType hasPrefix:@"{_CGSize"]) {
                CGSize argument = CGSizeMake([obj[@"width"] floatValue],
                                             [obj[@"height"] floatValue]);
                [invocation setArgument:&argument atIndex:idx];
            }
            else if ([objcType hasPrefix:@"{CGPoint"] || [objcType hasPrefix:@"{_CGPoint"]) {
                CGPoint argument = CGPointMake([obj[@"x"] floatValue],
                                               [obj[@"y"] floatValue]);
                [invocation setArgument:&argument atIndex:idx];
            }
            else if ([objcType hasPrefix:@"{CGAffineTransform"] || [objcType hasPrefix:@"{_CGAffineTransform"]) {
                CGAffineTransform argument = CGAffineTransformMake([obj[@"a"] floatValue],
                                                                   [obj[@"b"] floatValue],
                                                                   [obj[@"c"] floatValue],
                                                                   [obj[@"d"] floatValue],
                                                                   [obj[@"tx"] floatValue],
                                                                   [obj[@"ty"] floatValue]);
                [invocation setArgument:&argument atIndex:idx];
            }
            else if ([objcType hasPrefix:@"{UIEdgeInsets"] || [objcType hasPrefix:@"{_UIEdgeInsets"]) {
                UIEdgeInsets argument = UIEdgeInsetsMake([obj[@"top"] floatValue],
                                                         [obj[@"left"] floatValue],
                                                         [obj[@"bottom"] floatValue],
                                                         [obj[@"right"] floatValue]);
                [invocation setArgument:&argument atIndex:idx];
            }
            else if ([objcType hasPrefix:@"{NSRange"] || [objcType hasPrefix:@"{_NSRange"]) {
                NSRange argument = NSMakeRange([obj[@"location"] floatValue],
                                               [obj[@"length"] floatValue]);
                [invocation setArgument:&argument atIndex:idx];
            }
            else {
                [invocation setArgument:&obj atIndex:idx];
            }
        }
        else {
            [invocation setArgument:&obj atIndex:idx];
        }
    }
}

+ (JSValue *)getReturnValueFromInvocation:(NSInvocation *)invocation valueType:(char [256])ret context:(JSContext *)context {
    if (strcmp(ret, "v") != 0) {
        if (strcmp(ret, "i") == 0) {
            int tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "s") == 0) {
            short tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "l") == 0) {
            long tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "q") == 0) {
            long long tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "I") == 0) {
            unsigned int tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "S") == 0) {
            unsigned short tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "L") == 0) {
            unsigned long tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "Q") == 0) {
            unsigned long long tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "f") == 0) {
            float tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "d") == 0) {
            double tempResult;
            [invocation getReturnValue:&tempResult];
            return (JSValue *)@(tempResult);
        }
        else if (strcmp(ret, "b") == 0) {
            BOOL tempResult;
            [invocation getReturnValue:&tempResult];
            return [JSValue valueWithBool:tempResult inContext:context];
        }
        else if (strcmp(ret, "@") == 0) {
            void *tempResult = NULL;
            [invocation getReturnValue:&tempResult];
            NSObject *result = (__bridge NSObject *)tempResult;
            return [EDOObjectTransfer convertToJSValueWithObject:result context:context];
        }
        else {
            NSString *objcType = [NSString stringWithUTF8String:ret];
            if ([objcType hasPrefix:@"{CGRect"] || [objcType hasPrefix:@"{_CGRect"]) {
                CGRect tempResult;
                [invocation getReturnValue:&tempResult];
                return [JSValue valueWithRect:tempResult inContext:context];
            }
            else if ([objcType hasPrefix:@"{CGSize"] || [objcType hasPrefix:@"{_CGSize"]) {
                CGSize tempResult;
                [invocation getReturnValue:&tempResult];
                return [JSValue valueWithSize:tempResult inContext:context];
            }
            else if ([objcType hasPrefix:@"{CGPoint"] || [objcType hasPrefix:@"{_CGPoint"]) {
                CGPoint tempResult;
                [invocation getReturnValue:&tempResult];
                return [JSValue valueWithPoint:tempResult inContext:context];
            }
            else if ([objcType hasPrefix:@"{CGAffineTransform"] || [objcType hasPrefix:@"{_CGAffineTransform"]) {
                CGAffineTransform tempResult;
                [invocation getReturnValue:&tempResult];
                return (JSValue *)@{ @"a": @(tempResult.a), @"b": @(tempResult.b), @"c": @(tempResult.c), @"d": @(tempResult.d), @"tx": @(tempResult.tx), @"ty": @(tempResult.ty) };
            }
            else if ([objcType hasPrefix:@"{UIEdgeInsets"] || [objcType hasPrefix:@"{_UIEdgeInsets"]) {
                UIEdgeInsets tempResult;
                [invocation getReturnValue:&tempResult];
                return (JSValue *)@{ @"top": @(tempResult.top), @"left": @(tempResult.left), @"bottom": @(tempResult.bottom), @"right": @(tempResult.right) };
            }
            else if ([objcType hasPrefix:@"{NSRange"] || [objcType hasPrefix:@"{_NSRange"]) {
                NSRange tempResult;
                [invocation getReturnValue:&tempResult];
                return (JSValue *)@{ @"location": @(tempResult.location), @"length": @(tempResult.length) };
            }
        }
    }
    return [JSValue valueWithUndefinedInContext:context];
}

@end
