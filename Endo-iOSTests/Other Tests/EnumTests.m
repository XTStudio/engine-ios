//
//  EnumTests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EDOExporter.h"

@interface EnumTests : XCTestCase

@end

@implementation EnumTests

- (void)setUp {
    [super setUp];
    [[EDOExporter sharedExporter] exportEnum:@"UIViewContentMode"
                                      values:@{
                                               @"top": @(UIViewContentModeTop),
                                               @"right": @(UIViewContentModeRight),
                                               @"bottom": @(UIViewContentModeBottom),
                                               @"left": @(UIViewContentModeLeft),
                                               }];
    [[EDOExporter sharedExporter] exportEnum:@"UIEnumAsString"
                                      values:@{
                                               @"a": @"a",
                                               @"b": @"b",
                                               @"c": @"c",
                                               @"d": @"d",
                                               }];
}

- (void)testEnum {
    JSContext *context = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:context];
    XCTAssertEqual([context evaluateScript:@"UIViewContentMode.top"].toInt32, UIViewContentModeTop);
    XCTAssertEqual([context evaluateScript:@"UIViewContentMode.right"].toInt32, UIViewContentModeRight);
    XCTAssertEqual([context evaluateScript:@"UIViewContentMode.bottom"].toInt32, UIViewContentModeBottom);
    XCTAssertEqual([context evaluateScript:@"UIViewContentMode.left"].toInt32, UIViewContentModeLeft);
    XCTAssertTrue([[context evaluateScript:@"UIEnumAsString.c"].toString isEqualToString:@"c"]);
}

@end
