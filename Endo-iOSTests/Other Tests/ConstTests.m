//
//  ConstTests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EDOExporter.h"
#import "FooObject.h"

@interface ConstTests : XCTestCase

@end

@implementation ConstTests

- (void)setUp {
    [super setUp];
    EDO_EXPORT_CONST(@"kTestConst", @"const value");
    EDO_EXPORT_CONST(@"kTestNumberConst", @(123));
    EDO_EXPORT_CONST(@"kTestObjectConst", [FooObject new]);
}

- (void)testConsts {
    JSContext *context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:context];
    XCTAssert([[[context evaluateScript:@"kTestConst"] toString] isEqualToString:@"const value"]);
    XCTAssert([[[context evaluateScript:@"kTestNumberConst"] toNumber] isEqualToNumber:@(123)]);
    XCTAssertTrue([context evaluateScript:@"kTestObjectConst instanceof FooObject"].toBool);
}

@end
