//
//  ArgumentTestObject.h
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "FooObject.h"

@interface ArgumentTestObject : NSObject

@property (nonatomic, assign) NSInteger fulfills;

- (void)testIntValue:(NSInteger)intValue;
- (void)testFloatValue:(float)floatValue;
- (void)testDoubleValue:(double)doubleValue;
- (void)testBoolValue:(BOOL)boolValue;
- (void)testRectValue:(CGRect)rectValue;
- (void)testSizeValue:(CGSize)sizeValue;
- (void)testAffineTransformValue:(CGAffineTransform)affineTransformValue;
- (void)testStringValue:(NSString *)stringValue;
- (void)testArrayValue:(NSArray *)arrayValue;
- (void)testDictValue:(NSDictionary *)dictValue;
- (void)testNilValue:(id)nilValue;
- (void)testObjectValue:(FooObject *)objectValue;
- (void)testBlockValue:(id (^)(NSArray *))blockValue;

@end
