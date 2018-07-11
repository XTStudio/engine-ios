//
//  ReturnTests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"

@interface ReturnTests : XCTestCase

@end

@implementation ReturnTests

- (void)testReturns {
    JSContext *context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:context];
    [context evaluateScript:@"var obj = new ReturnTestObject"];
    XCTAssertTrue([context evaluateScript:@"obj.intValue() === 1"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.floatValue().toFixed(1) === '1.1'"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.doubleValue().toFixed(1) === '1.2'"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.boolValue() === true"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.rectValue().x === 1"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.rectValue().y === 2"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.rectValue().width === 3"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.rectValue().height === 4"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.sizeValue().width === 5"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.sizeValue().height === 6"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.affineTransformValue().a === 1"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.affineTransformValue().b === 2"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.affineTransformValue().c === 3"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.affineTransformValue().d === 4"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.affineTransformValue().tx === 44"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.affineTransformValue().ty === 55"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.stringValue() === 'String Value'"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.arrayValue()[0] === 1"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.arrayValue()[1] === 2"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.arrayValue()[2] === 3"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.arrayValue()[3] === 4"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.dictValue()['aKey'] === 'aValue'"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.nilValue() === undefined"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.jsValue() === null"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.objectValue() instanceof FooObject"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.unexportdClassValue() instanceof FooObject"].toBool);
    XCTAssertTrue([context evaluateScript:@"obj.errorValue().message === 'Error Message.'"].toBool);
}

@end
