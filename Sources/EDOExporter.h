//
//  EDOExport.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

typedef id(^EDOInitializer)(NSArray *arguments);

typedef enum: NSUInteger {
    EDOPropTypeString,
    EDOPropTypeNumber,
    EDOPropTypeBoolean,
} EDOPropType;

@protocol EDOJSExport <JSExport>

- (NSString *)createInstanceWithName:(NSString *)name arguments:(NSArray *)arguments;
- (JSValue *)valueWithPropertyName:(NSString *)name metaClass:(JSValue *)metaClass;
- (void)setValueWithPropertyName:(NSString *)name value:(JSValue *)value metaClass:(JSValue *)metaClass;

@end

@interface EDOExporter : NSObject<EDOJSExport>

+ (EDOExporter *)sharedExporter;

- (void)exportWithContext:(JSContext *)context;
- (void)exportClass:(Class)clazz name:(NSString *)name;
- (void)exportInitializer:(Class)clazz initializer:(EDOInitializer)initializer;
- (void)exportProperty:(Class)clazz propName:(NSString *)propName propType:(EDOPropType)propType;

@end
