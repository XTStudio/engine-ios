//
//  EDOStructValue.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef enum: NSUInteger {
    EDOStructTypeCGPoint = 1000,
    EDOStructTypeCGSize,
    EDOStructTypeCGRect,
} EDOStructType;

@interface EDOStructValue : NSObject

+ (JSValue *)valueForStructType:(EDOStructType)structType value:(id)value;

+ (NSValue *)nsValueForStructType:(EDOStructType)structType value:(JSValue *)value;

@end
