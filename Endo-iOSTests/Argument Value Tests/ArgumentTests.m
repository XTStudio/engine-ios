//
//  ArgumentTests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"
#import "EDOObjectTransfer.h"
#import "ArgumentTestObject.h"

@interface ArgumentTests : XCTestCase

@end

@implementation ArgumentTests

- (void)testArguments {
    JSContext *context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:context];
    [context evaluateScript:@"var obj = new ArgumentTestObject"];
    [context evaluateScript:@"obj.testIntValue(1)"];
    [context evaluateScript:@"obj.testFloatValue(1.1)"];
    [context evaluateScript:@"obj.testDoubleValue(1.2)"];
    [context evaluateScript:@"obj.testBoolValue(true)"];
    [context evaluateScript:@"obj.testRectValue({x: 1, y: 2, width: 3, height: 4})"];
    [context evaluateScript:@"obj.testSizeValue({width: 5, height: 6})"];
    [context evaluateScript:@"obj.testAffineTransformValue({a: 1, b: 2, c: 3, d: 4, tx: 44, ty: 55})"];
    [context evaluateScript:@"obj.testStringValue('String Value')"];
    [context evaluateScript:@"obj.testArrayValue([1,2,3,4])"];
    [context evaluateScript:@"obj.testDictValue({aKey: 'aValue'})"];
    [context evaluateScript:@"obj.testNilValue(undefined)"];
    [context evaluateScript:@"obj.testObjectValue(new FooObject)"];
    [context evaluateScript:@"obj.testBlockValue(function(r){return r;})"];
    ArgumentTestObject *obj = [EDOObjectTransfer convertToNSValueWithJSValue:[context evaluateScript:@"obj"] owner:[context evaluateScript:@"obj"]];
    XCTAssertEqual(obj.fulfills, 13);
}

@end
