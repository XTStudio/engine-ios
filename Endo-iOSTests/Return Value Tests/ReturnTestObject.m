//
//  ReturnTestObject.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "ReturnTestObject.h"
#import "EDOExporter.h"

@implementation ReturnTestObject

+ (void)load {
    EDO_EXPORT_CLASS(@"ReturnTestObject", nil);
    EDO_EXPORT_METHOD(intValue);
    EDO_EXPORT_METHOD(floatValue);
    EDO_EXPORT_METHOD(doubleValue);
    EDO_EXPORT_METHOD(boolValue);
    EDO_EXPORT_METHOD(rectValue);
    EDO_EXPORT_METHOD(sizeValue);
    EDO_EXPORT_METHOD(affineTransformValue);
    EDO_EXPORT_METHOD(stringValue);
    EDO_EXPORT_METHOD(arrayValue);
    EDO_EXPORT_METHOD(dictValue);
    EDO_EXPORT_METHOD(nilValue);
    EDO_EXPORT_METHOD(jsValue);
    EDO_EXPORT_METHOD(objectValue);
    EDO_EXPORT_METHOD(unexportdClassValue);
    EDO_EXPORT_METHOD(errorValue);
}

- (NSInteger)intValue;{
    return 1;
}

- (float)floatValue; {
    return 1.1;
}

- (double)doubleValue; {
    return 1.2;
}

- (BOOL)boolValue; {
    return YES;
}

- (CGRect)rectValue; {
    return CGRectMake(1, 2, 3, 4);
}

- (CGSize)sizeValue; {
    return CGSizeMake(5, 6);
}

- (CGAffineTransform)affineTransformValue; {
    return CGAffineTransformMake(1, 2, 3, 4, 44, 55);
}

- (NSString *)stringValue; {
    return @"String Value";
}

- (NSArray *)arrayValue; {
    return @[@(1), @(2), @(3), @(4)];
}

- (NSDictionary *)dictValue; {
    return @{@"aKey": @"aValue"};
}

- (id)nilValue; {
    return nil;
}

- (JSValue *)jsValue; {
    return [JSValue valueWithNullInContext:[JSContext currentContext]];
}

- (FooObject *)objectValue; {
    return [[FooObject alloc] init];
}

- (XXXObject *)unexportdClassValue {
    return [[XXXObject alloc] init];
}

- (NSError *)errorValue; {
    return [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Error Message."}];
}

@end
