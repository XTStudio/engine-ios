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

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue {
    if (anValue.isObject) {
        JSValue *metaClassValue = [anValue objectForKeyedSubscript:@"_meta_class"];
        if (metaClassValue.isObject) {
            NSDictionary *metaClassInfo = metaClassValue.toDictionary;
            if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
                return [[EDOExporter sharedExporter] valueWithObjectRef:metaClassInfo[@"objectRef"]];
            }
        }
    }
    return nil;
}

+ (id)convertToNSValueWithPlainValue:(id)plainValue {
    if ([plainValue isKindOfClass:[NSString class]] || [plainValue isKindOfClass:[NSNumber class]]) {
        return plainValue;
    }
    else if ([plainValue isKindOfClass:[NSDictionary class]]) {
        NSDictionary *metaClassInfo = plainValue[@"_meta_class"];
        if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
            return [[EDOExporter sharedExporter] valueWithObjectRef:metaClassInfo[@"objectRef"]];
        }
        else {
            return plainValue;
        }
    }
    return nil;
}

+ (NSArray *)convertToNSArgumentsWithJSArguments:(NSArray *)jsArguments {
    NSMutableArray *nsArguments = [NSMutableArray array];
    for (id argument in jsArguments) {
        [nsArguments addObject:[self convertToNSValueWithPlainValue:argument] ?: [NSNull null]];
    }
    return nsArguments;
}

@end
