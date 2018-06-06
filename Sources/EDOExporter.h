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

#define EDO_EXPORT_CLASS(A) [[EDOExporter sharedExporter] exportClass:[self class] name:A];
#define EDO_EXPORT_INITIALIZER(BLOCK) [[EDOExporter sharedExporter] exportInitializer:[self class] initializer:^id(NSArray *arguments) BLOCK ];
#define EDO_EXPORT_PROPERTY(A) [[EDOExporter sharedExporter] exportProperty:[self class] propName:A];
#define EDO_BIND_METHOD(A) [[EDOExporter sharedExporter] bindMethodToJavaScript:[self class] selector:@selector(A)];
#define EDO_EXPORT_METHOD(A) [[EDOExporter sharedExporter] exportMethodToJavaScript:[self class] selector:@selector(A)];

@protocol EDOJSExport <JSExport>

- (NSString *)createInstanceWithName:(NSString *)name arguments:(NSArray *)arguments owner:(JSValue *)owner;
- (JSValue *)valueWithPropertyName:(NSString *)name owner:(JSValue *)owner;
- (void)setValueWithPropertyName:(NSString *)name value:(JSValue *)value metaClass:(JSValue *)metaClass;
- (JSValue *)callMethodWithName:(NSString *)name arguments:(NSArray *)arguments metaClass:(JSValue *)metaClass;

@end

@interface EDOExporter : NSObject<EDOJSExport>

+ (EDOExporter *)sharedExporter;

- (void)exportWithContext:(nonnull JSContext *)context;
- (void)exportClass:(Class)clazz name:(nonnull NSString *)name;
- (void)exportInitializer:(Class)clazz initializer:(nonnull EDOInitializer)initializer;
- (void)exportProperty:(Class)clazz propName:(nonnull NSString *)propName;
- (void)bindMethodToJavaScript:(Class)clazz selector:(nonnull SEL)aSelector;
- (void)exportMethodToJavaScript:(Class)clazz selector:(nonnull SEL)aSelector;
- (nullable id)valueWithObjectRef:(nonnull NSString *)objectRef;
- (nullable JSValue *)scriptObjectWithObject:(nonnull NSObject *)anObject;

@end
