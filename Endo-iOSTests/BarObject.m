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
    EDO_EXPORT_PROPERTY(@"uuuCalled");
    EDO_EXPORT_METHOD(toXXX);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (XXXObject *)toXXX {
    return [[XXXObject alloc] init];
}

@end
