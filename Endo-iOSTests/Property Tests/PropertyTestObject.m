//
//  PropertyTestObject.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "PropertyTestObject.h"
#import "EDOExporter.h"

@implementation PropertyTestObject

+ (void)load {
    EDO_EXPORT_CLASS(@"PropertyTestObject", nil);
    EDO_EXPORT_PROPERTY(@"intValue");
    EDO_EXPORT_PROPERTY(@"floatValue");
    EDO_EXPORT_PROPERTY(@"doubleValue");
    EDO_EXPORT_PROPERTY(@"boolValue");
    EDO_EXPORT_PROPERTY(@"rectValue");
    EDO_EXPORT_PROPERTY(@"sizeValue");
    EDO_EXPORT_PROPERTY(@"affineTransformValue");
    EDO_EXPORT_PROPERTY(@"stringValue");
    EDO_EXPORT_PROPERTY(@"arrayValue");
    EDO_EXPORT_PROPERTY(@"dictValue");
    EDO_EXPORT_PROPERTY(@"nilValue");
    EDO_EXPORT_PROPERTY(@"objectValue");
    EDO_EXPORT_READONLY_PROPERTY(@"readonlyIntValue");
}

@end
