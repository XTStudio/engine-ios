//
//  ArgumentTestObject.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "ArgumentTestObject.h"
#import "EDOExporter.h"

@implementation ArgumentTestObject

+ (void)load {
    EDO_EXPORT_CLASS(@"ArgumentTestObject", nil);
    EDO_EXPORT_METHOD(testIntValue:);
    EDO_EXPORT_METHOD(testFloatValue:);
    EDO_EXPORT_METHOD(testDoubleValue:);
    EDO_EXPORT_METHOD(testBoolValue:);
    EDO_EXPORT_METHOD(testRectValue:);
    EDO_EXPORT_METHOD(testSizeValue:);
    EDO_EXPORT_METHOD(testAffineTransformValue:);
    EDO_EXPORT_METHOD(testStringValue:);
    EDO_EXPORT_METHOD(testArrayValue:);
    EDO_EXPORT_METHOD(testDictValue:);
    EDO_EXPORT_METHOD(testNilValue:);
    EDO_EXPORT_METHOD(testObjectValue:);
    EDO_EXPORT_METHOD(testBlockValue:);
}

- (void)testIntValue:(NSInteger)intValue {
    if (intValue == 1) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testFloatValue:(float)floatValue {
    if (fabs(floatValue - 1.1) < 0.01) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testDoubleValue:(double)doubleValue {
    if (fabs(doubleValue - 1.2) < 0.01) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testBoolValue:(BOOL)boolValue {
    if (boolValue == YES) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testRectValue:(CGRect)rectValue {
    if (CGRectEqualToRect(rectValue, CGRectMake(1, 2, 3, 4))) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testSizeValue:(CGSize)sizeValue {
    if (CGSizeEqualToSize(sizeValue, CGSizeMake(5, 6))) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testAffineTransformValue:(CGAffineTransform)affineTransformValue {
    if (CGAffineTransformEqualToTransform(affineTransformValue, CGAffineTransformMake(1, 2, 3, 4, 44, 55))) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testStringValue:(NSString *)stringValue {
    if ([stringValue isEqualToString:@"String Value"]) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testArrayValue:(NSArray *)arrayValue {
    if ([arrayValue[0] integerValue] == 1 && [arrayValue[1] integerValue] == 2 && [arrayValue[2] integerValue] == 3 && [arrayValue[3] integerValue] == 4) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testDictValue:(NSDictionary *)dictValue {
    if ([dictValue[@"aKey"] isEqualToString:@"aValue"]) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testNilValue:(id)nilValue {
    if (nilValue == nil) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testObjectValue:(FooObject *)objectValue {
    if ([objectValue isKindOfClass:[FooObject class]]) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

- (void)testBlockValue:(id (^)(NSArray *))blockValue {
    if (blockValue != nil && [blockValue(@[@(2)]) intValue] == 2) {
        self.fulfills++;
    }
    else {
        assert(false);
    }
}

@end
