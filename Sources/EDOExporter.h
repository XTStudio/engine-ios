//
//  EDOExport.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOStructValue.h"

typedef id(^EDOInitializer)(NSArray *arguments);
typedef void(^EDOBindMethodInvokingBlock)(JSValue *value, NSArray *arguments);

typedef enum: NSUInteger {
    EDOPropTypeString = 100,
    EDOPropTypeNumber,
    EDOPropTypeBoolean,
    EDOPropTypeDictionary,
    EDOPropTypeArray,
    EDOPropTypeCustom,
} EDOPropType;

@protocol EDOJSExport <JSExport>

- (NSString *)createInstanceWithName:(NSString *)name arguments:(NSArray *)arguments owner:(JSValue *)owner;
- (JSValue *)valueWithPropertyName:(NSString *)name metaClass:(JSValue *)metaClass;
- (void)setValueWithPropertyName:(NSString *)name value:(JSValue *)value metaClass:(JSValue *)metaClass;

@end

@interface EDOExporter : NSObject<EDOJSExport>

+ (EDOExporter *)sharedExporter;

- (void)exportWithContext:(nonnull JSContext *)context;
- (void)exportClass:(Class)clazz name:(nonnull NSString *)name;
- (void)exportInitializer:(Class)clazz initializer:(nonnull EDOInitializer)initializer;
- (void)exportProperty:(Class)clazz propName:(nonnull NSString *)propName propType:(EDOPropType)propType;
- (void)exportStructProperty:(Class)clazz propName:(nonnull NSString *)propName structType:(EDOStructType)structType;
- (void)bindMethodToJavaScript:(Class)clazz selector:(SEL)aSelector invokingBlock:(nullable EDOBindMethodInvokingBlock)invokingBlock;

@end
