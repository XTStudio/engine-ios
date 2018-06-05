//
//  EDOStructValue.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "EDOStructValue.h"

@implementation EDOStructValue

+ (JSValue *)valueForStructType:(EDOStructType)structType value:(id)value {
    if (structType == EDOStructTypeCGPoint && [value isKindOfClass:[NSValue class]]) {
        return [JSValue valueWithPoint:[value CGPointValue] inContext:[JSContext currentContext]];
    }
    else if (structType == EDOStructTypeCGSize && [value isKindOfClass:[NSValue class]]) {
        return [JSValue valueWithSize:[value CGSizeValue] inContext:[JSContext currentContext]];
    }
    else if (structType == EDOStructTypeCGRect && [value isKindOfClass:[NSValue class]]) {
        return [JSValue valueWithRect:[value CGRectValue] inContext:[JSContext currentContext]];
    }
    else {
        return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
    }
}

+ (NSValue *)nsValueForStructType:(EDOStructType)structType value:(JSValue *)value {
    if (structType == EDOStructTypeCGPoint && value.isObject) {
        return [NSValue valueWithCGPoint:[value toPoint]];
    }
    else if (structType == EDOStructTypeCGSize && value.isObject) {
        return [NSValue valueWithCGSize:[value toSize]];
    }
    else if (structType == EDOStructTypeCGRect && value.isObject) {
        return [NSValue valueWithCGRect:[value toRect]];
    }
    else {
        return nil;
    }
}

@end
