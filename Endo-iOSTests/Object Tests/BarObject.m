//
//  BarObject.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "BarObject.h"
#import "EDOExporter.h"
#import "XXXObject.h"

@implementation BarObject

+ (void)load {
    EDO_EXPORT_CLASS(@"BarObject", @"FooObject");
    EDO_EXPORT_PROPERTY(@"intValue");
    EDO_BIND_METHOD(bindTest:);
    [[EDOExporter sharedExporter] exportInitializer:[self class] initializer:^id(NSArray *arguments) {
        BarObject *instance = [[BarObject alloc] init];
        if (0 < arguments.count && [arguments[0] isKindOfClass:[NSNumber class]]) {
            instance.intValue = [arguments[0] integerValue];
        }
        return instance;
    }];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _intValue = 1;
    }
    return self;
}

@end
