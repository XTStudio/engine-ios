//
//  EDOObjectTransfer.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/6.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"

@interface EDOObjectTransfer : NSObject

+ (JSValue *)convertToJSValueWithObject:(NSObject *)anObject;

+ (id)convertToNSValueWithJSValue:(JSValue *)anValue;

+ (NSArray *)convertToNSArgumentsWithJSArguments:(NSArray *)jsArguments;

@end
