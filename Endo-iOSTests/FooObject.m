//
//  FooObject.m
//  Endo-iOSTests
//
//  Created by 崔明辉 on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "FooObject.h"
#import "EDOExporter.h"

@implementation FooObject

+ (void)load {
    EDO_EXPORT_CLASS(@"FooObject", nil);
    EDO_EXPORT_PROPERTY(@"view");
    EDO_EXPORT_PROPERTY(@"barCalled");
    EDO_EXPORT_PROPERTY(@"fooBarCalled");
    EDO_EXPORT_PROPERTY(@"fooBarArgumentsCalled");
    EDO_EXPORT_PROPERTY(@"fooBarArgumentsAliasCalled");
    EDO_EXPORT_PROPERTY(@"edo_aFloat");
    EDO_BIND_METHOD(bindingMethod);
    EDO_EXPORT_METHOD(bar);
    EDO_EXPORT_METHOD(edo_fooBar);
    EDO_EXPORT_METHOD(edo_fooBarWithString:andView:);
    EDO_EXPORT_METHOD_ALIAS(edo_fooBar:andView:, @"fooBarWithString");
    EDO_EXPORT_METHOD(methodWithCallback:)
}

- (void)dealloc {
    EDO_RELEASE(self.view);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setView:(UIView *)view {
    EDO_RELEASE(_view);
    _view = view;
    EDO_RETAIN(_view);
}

- (void)bindingMethod {
    
}

- (void)bar {
    self.barCalled = YES;
}

- (void)edo_fooBar {
    self.fooBarCalled = YES;
}

- (void)edo_fooBarWithString:(NSString *)aString andView:(UIView *)aView {
    if ([aString isEqualToString:@"string value"] && [aView isKindOfClass:[UIView class]]) {
        self.fooBarArgumentsCalled = YES;
    }
}

- (void)edo_fooBar:(NSString *)aString andView:(UIView *)aView {
    if ([aString isEqualToString:@"alias string value"] && [aView isKindOfClass:[UIView class]]) {
        self.fooBarArgumentsAliasCalled = YES;
    }
}

- (void)methodWithCallback:(id (^)(NSArray *))callback {
    NSNumber *result = callback(@[@(1)]);
    if ([result isKindOfClass:[NSNumber class]] && [result integerValue] == 1) {
        self.barCalled = YES;
    }
}

@end
