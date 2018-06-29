//
//  Endo_iOSTests.m
//  Endo-iOSTests
//
//  Created by 崔明辉 on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"
#import "FooObject.h"

@interface Endo_iOSTests : XCTestCase

@property (nonatomic, strong) JSContext *context;

@end

@implementation Endo_iOSTests

- (void)setUp {
    [super setUp];
    self.context = [[JSContext alloc] init];
    __weak id welf = self;
    [self.context setExceptionHandler:^(JSContext *context, JSValue *exception) {
        __strong id self = welf;
        NSAssert(NO, [exception toString]);
    }];
    [[EDOExporter sharedExporter] exportWithContext:self.context];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testClasses {
    XCTAssertFalse([self.context evaluateScript:@"new UIView"].isUndefined);
    XCTAssertFalse([self.context evaluateScript:@"new UIButton"].isUndefined);
    XCTAssertFalse([self.context evaluateScript:@"new BarObject"].isUndefined);
}

- (void)testInitializer {
    FooObject *obj = [[EDOExporter sharedExporter] nsValueWithJSValue:[self.context evaluateScript:@"new FooObject(new UIView)"]];
    XCTAssertTrue(obj.barCalled);
}

- (void)testConst {
    XCTAssert([[[self.context evaluateScript:@"FooConst"] toString] isEqualToString:@"const value"]);
}

- (void)testNumberProperty {
    [self.context evaluateScript:@"var testNumberProperty = new UIView"];
    [self.context evaluateScript:@"testNumberProperty.alpha = 0.5"];
    [self.context evaluateScript:@"var testNumberProperty_EDOPrefix = new FooObject"];
    [self.context evaluateScript:@"testNumberProperty_EDOPrefix.aFloat = 0.5"];
    XCTAssertEqual([[[self.context evaluateScript:@"testNumberProperty.alpha"] toNumber] floatValue], 0.5);
    XCTAssertEqual([[[self.context evaluateScript:@"testNumberProperty_EDOPrefix.aFloat"] toNumber] floatValue], 0.5);
}

- (void)testStringProperty {
    [self.context evaluateScript:@"var testStringProperty = new UIView"];
    [self.context evaluateScript:@"testStringProperty.accessibilityHint = 'Hello, World!'"];
    XCTAssertTrue([[[self.context evaluateScript:@"testStringProperty.accessibilityHint"] toString] isEqualToString:@"Hello, World!"]);
}

- (void)testStructProperty {
    [self.context evaluateScript:@"var testStructProperty = new UIView"];
    [self.context evaluateScript:@"testStructProperty.frame = {x: 22, y: 33, width: 44, height: 55}"];
    XCTAssertEqual([[self.context evaluateScript:@"testStructProperty.frame"] toRect].origin.x, 22);
    XCTAssertEqual([[self.context evaluateScript:@"testStructProperty.frame"] toRect].origin.y, 33);
    XCTAssertEqual([[self.context evaluateScript:@"testStructProperty.frame"] toRect].size.width, 44);
    XCTAssertEqual([[self.context evaluateScript:@"testStructProperty.frame"] toRect].size.height, 55);
}

- (void)testObjectProperty {
    [self.context evaluateScript:@"var testObjectProperty = new FooObject"];
    [self.context evaluateScript:@"testObjectProperty.view = new UIView"];
    XCTAssertEqual([[self.context evaluateScript:@"testObjectProperty.view.alpha"] toNumber].floatValue, 1.0);
    [self.context evaluateScript:@"testObjectProperty.view = undefined"];
    XCTAssertTrue([self.context evaluateScript:@"testObjectProperty.view"].isUndefined);
}

- (void)testEnumExports {
    XCTAssertEqual([[self.context evaluateScript:@"UIViewContentMode.top"] toNumber].integerValue, UIViewContentModeTop);
    XCTAssertEqual([[self.context evaluateScript:@"UIViewContentMode.right"] toNumber].integerValue, UIViewContentModeRight);
}

- (void)testMethodExports {
    [self.context evaluateScript:@"var testMethodExports = new FooObject"];
    [self.context evaluateScript:@"testMethodExports.bar()"];
    [self.context evaluateScript:@"testMethodExports.fooBar()"];
    [self.context evaluateScript:@"testMethodExports.fooBarWithStringAndView('string value', new UIView)"];
    [self.context evaluateScript:@"testMethodExports.fooBarWithString('alias string value', new UIView)"];
    XCTAssertTrue([[self.context evaluateScript:@"testMethodExports.barCalled"] toBool]);
    XCTAssertTrue([[self.context evaluateScript:@"testMethodExports.fooBarCalled"] toBool]);
    XCTAssertTrue([[self.context evaluateScript:@"testMethodExports.fooBarArgumentsCalled"] toBool]);
    XCTAssertTrue([[self.context evaluateScript:@"testMethodExports.fooBarArgumentsAliasCalled"] toBool]);
    [self.context evaluateScript:@"var testStructMethod = new FooObject"];
    [self.context evaluateScript:@"testStructMethod.structMethod({x: 0, y: 0, width: 100, height: 200})"];
    XCTAssertTrue([[self.context evaluateScript:@"testStructMethod.barCalled"] toBool]);
}

- (void)testMethodBinding {
    FooObject *obj = [[EDOExporter sharedExporter] nsValueWithJSValue:[self.context evaluateScript:@"var A=(function(_super){__extends(A,_super);function A(){return _super!==null&&_super.apply(this,arguments)||this}A.prototype.bindingMethod=function(){this.bar()};return A}(FooObject));new A();"]];
    XCTAssertTrue([obj isKindOfClass:[FooObject class]]);
    [obj bindingMethod];
    XCTAssertTrue(obj.barCalled);
}

- (void)testMethodWithCallback {
    [self.context evaluateScript:@"var testMethodWithCallback = new FooObject"];
    [self.context evaluateScript:@"testMethodWithCallback.methodWithCallback(function(foo){ return foo; });"];
    XCTAssertTrue([[self.context evaluateScript:@"testMethodWithCallback.barCalled"] toBool]);
}

- (void)testEventEmitter {
    FooObject *obj = [[EDOExporter sharedExporter] nsValueWithJSValue:[self.context evaluateScript:@"var testEventEmitter = new FooObject; testEventEmitter"]];
    [self.context evaluateScript:@"testEventEmitter.on('click', function(sender){ sender.bar() })"];
    [self.context evaluateScript:@"testEventEmitter.on('clickTime', function(){ return 1 })"];
    [obj edo_emitWithEventName:@"click" arguments:@[obj]];
    XCTAssertTrue(obj.barCalled);
    XCTAssertEqual([[obj edo_valueWithEventName:@"clickTime" arguments:nil] integerValue], 1);
}

- (void)testInvalidAccess {
    JSValue *privateValue = [self.context evaluateScript:@"var testInvalidAccess = new FooObject; ENDO.valueWithPropertyNameOwner('privateValue',testInvalidAccess)"];
    JSValue *privateMethodValue = [self.context evaluateScript:@"ENDO.callMethodWithNameArgumentsOwner('privateMethod', [],testInvalidAccess)"];
    JSValue *validValue = [self.context evaluateScript:@"var testValidAccess = new BarObject; testValidAccess.barCalled"];
    XCTAssertTrue(privateValue.isUndefined);
    XCTAssertTrue(privateMethodValue.isUndefined);
    XCTAssertTrue(validValue.isBoolean);
}

@end
