//
//  ReturnTestObject.h
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "FooObject.h"
#import "XXXObject.h"

@interface ReturnTestObject : NSObject

- (NSInteger)intValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)boolValue;
- (CGRect)rectValue;
- (CGSize)sizeValue;
- (CGAffineTransform)affineTransformValue;
- (NSString *)stringValue;
- (NSArray *)arrayValue;
- (NSDictionary *)dictValue;
- (id)nilValue;
- (JSValue *)jsValue;
- (FooObject *)objectValue;
- (XXXObject *)unexportdClassValue;
- (NSError *)errorValue;

@end
