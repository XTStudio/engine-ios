//
//  FooObject.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "FooObject.h"
#import "EDOExporter.h"

@implementation FooObject

+ (void)load {
    EDO_EXPORT_CLASS(@"FooObject", nil);
    EDO_EXPORT_PROPERTY(@"floatValue");
    EDO_EXPORT_SCRIPT(@"Initializer.staticFoo2 = new Initializer()")
    EDO_EXPORT_GLOBAL_SCRIPT(@"FooObject.staticFoo = new FooObject()")
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _floatValue = 0.1;
    }
    return self;
}

@end
