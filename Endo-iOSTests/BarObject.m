//
//  BarObject.m
//  Endo-iOSTests
//
//  Created by 崔明辉 on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "BarObject.h"
#import "EDOExporter.h"

@implementation BarObject

+ (void)load {
    EDO_EXPORT_CLASS(@"BarObject", @"FooObject");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
