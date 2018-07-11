//
//  PropertyTests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"
#import "PropertyTestObject.h"

@interface PropertyTests : XCTestCase

@end

@implementation PropertyTests

- (void)testProperties {
    JSContext *context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:context];
    PropertyTestObject *obj = [[EDOExporter sharedExporter] nsValueWithJSValue:[context evaluateScript:@"var obj = new PropertyTestObject; obj"]];
    [context evaluateScript:@"obj.intValue = 2"];
    XCTAssertEqual(obj.intValue, 2);
    [context evaluateScript:@"obj.floatValue = 1.0"];
    XCTAssertTrue(fabs(obj.floatValue - 1.0) < 0.01);
    [context evaluateScript:@"obj.doubleValue = 1.0"];
    XCTAssertTrue(fabs(obj.doubleValue - 1.0) < 0.01);
    [context evaluateScript:@"obj.boolValue = true"];
    XCTAssertEqual(obj.boolValue, YES);
    [context evaluateScript:@"obj.rectValue = {x: 1, y: 2, width: 3, height: 4}"];
    XCTAssertTrue(CGRectEqualToRect(obj.rectValue, CGRectMake(1, 2, 3, 4)));
    [context evaluateScript:@"obj.sizeValue = {width: 3, height: 4}"];
    XCTAssertTrue(CGSizeEqualToSize(obj.sizeValue, CGSizeMake(3, 4)));
    [context evaluateScript:@"obj.affineTransformValue = {a: 1, b: 2, c: 3, d: 4, tx: 44, ty: 55}"];
    XCTAssertTrue(CGAffineTransformEqualToTransform(obj.affineTransformValue, CGAffineTransformMake(1, 2, 3, 4, 44, 55)));
    [context evaluateScript:@"obj.stringValue = 'string value'"];
    XCTAssertTrue([obj.stringValue isEqualToString:@"string value"]);
    [context evaluateScript:@"obj.arrayValue = [1, 2, 3, 4]"];
    XCTAssertEqual([obj.arrayValue[0] integerValue], 1);
    XCTAssertEqual([obj.arrayValue[1] integerValue], 2);
    XCTAssertEqual([obj.arrayValue[2] integerValue], 3);
    XCTAssertEqual([obj.arrayValue[3] integerValue], 4);
    [context evaluateScript:@"obj.dictValue = {aKey: 'aValue'}"];
    XCTAssertTrue([obj.dictValue[@"aKey"] isEqualToString:@"aValue"]);
    [context evaluateScript:@"obj.nilValue = undefined"];
    XCTAssertNil(obj.nilValue);
    [context evaluateScript:@"obj.objectValue = new FooObject"];
    XCTAssertTrue([obj.objectValue isKindOfClass:[FooObject class]]);
    [context evaluateScript:@"obj.readonlyIntValue = 2"];
    XCTAssertNotEqual(obj.readonlyIntValue, 2);
}

@end
