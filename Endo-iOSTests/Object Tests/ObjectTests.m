//
//  ObjectTests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"
#import "FooObject.h"

@interface ObjectTests : XCTestCase

@property (nonatomic, strong) JSContext *context;

@end

@implementation ObjectTests

- (void)setUp {
    [super setUp];
    self.context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:self.context];
}

- (void)testNewInstance {
    [self.context evaluateScript:@"var obj = new BarObject"];
    XCTAssertEqual([self.context evaluateScript:@"obj.intValue"].toInt32, 1);
}

- (void)testCusomInstance {
    [self.context evaluateScript:@"var obj = new BarObject(123)"];
    XCTAssertEqual([self.context evaluateScript:@"obj.intValue"].toInt32, 123);
}

- (void)testSubclassInstance {
    [self.context evaluateScript:@"var obj = new BarObject"];
    XCTAssertTrue([self.context evaluateScript:@"obj instanceof FooObject"].toBool);
    XCTAssertTrue(fabs([self.context evaluateScript:@"obj.floatValue"].toDouble - 0.1) < 0.01);
}

- (void)testEventEmitter {
    FooObject *obj = [[EDOExporter sharedExporter] nsValueWithJSValue:[self.context evaluateScript:@"var testEventEmitter = new FooObject; testEventEmitter"]];
    [self.context evaluateScript:@"testEventEmitter.on('click', function(sender){ sender.floatValue = 2.0 })"];
    [self.context evaluateScript:@"testEventEmitter.on('clickTime', function(){ return 1 })"];
    [obj edo_emitWithEventName:@"click" arguments:@[obj]];
    XCTAssertTrue(fabs(obj.floatValue - 2.0) < 0.01);
    XCTAssertEqual([[obj edo_valueWithEventName:@"clickTime" arguments:nil] integerValue], 1);
}

- (void)testBind {
    [self.context evaluateScript:@"class SSSObject extends BarObject { bindTest(e) { this.intValue = e; } } ; var obj = new SSSObject"];
    [self.context evaluateScript:@"obj.bindTest(123);"];
    XCTAssertEqual([self.context evaluateScript:@"obj.intValue"].toInt32, 123);
}

@end
