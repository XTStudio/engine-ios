//
//  EDOExport.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSObject+EDOObjectRef.h"

typedef id(^EDOInitializer)(NSArray *arguments);

#define EDO_EXPORT_CLASS(A, B) [[EDOExporter sharedExporter] exportClass:[self class] name:A superName:B];
#define EDO_EXPORT_INITIALIZER(BLOCK) [[EDOExporter sharedExporter] exportInitializer:[self class] initializer:^id(NSArray *arguments) BLOCK ];
#define EDO_EXPORT_PROPERTY(A) [[EDOExporter sharedExporter] exportProperty:[self class] propName:A];
#define EDO_BIND_METHOD(A) [[EDOExporter sharedExporter] bindMethodToJavaScript:[self class] selector:@selector(A)];
#define EDO_EXPORT_METHOD(A) [[EDOExporter sharedExporter] exportMethodToJavaScript:[self class] selector:@selector(A)];
#define EDO_EXPORT_METHOD_ALIAS(A, B) [[EDOExporter sharedExporter] exportMethodToJavaScript:[self class] selector:@selector(A) jsName:B];
#define EDO_EXPORT_SCRIPT(A) [[EDOExporter sharedExporter] exportScriptToJavaScript:[self class] script:A];

@protocol EDOJSExport <JSExport>

- (NSString *)createInstanceWithName:(NSString *)name arguments:(NSArray *)arguments owner:(JSValue *)owner;
- (JSValue *)valueWithPropertyName:(NSString *)name owner:(JSValue *)owner;
- (void)setValueWithPropertyName:(NSString *)name value:(JSValue *)value owner:(JSValue *)owner;
- (JSValue *)callMethodWithName:(NSString *)name arguments:(NSArray *)arguments owner:(JSValue *)owner;
- (void)addListenerWithName:(NSString *)name owner:(JSValue *)owner;

@end

@class EDOExportable;

@interface EDOExporter : NSObject<EDOJSExport>

@property (nonatomic, readonly) NSDictionary<NSString *, EDOExportable *> *exportables;

+ (EDOExporter *)sharedExporter;

- (void)exportWithContext:(nonnull JSContext *)context;
- (void)exportEnum:(NSString *)name values:(NSDictionary *)values;
- (void)exportClass:(Class)clazz name:(nonnull NSString *)name superName:(NSString *)superName;
- (void)exportInitializer:(Class)clazz initializer:(nonnull EDOInitializer)initializer;
- (void)exportProperty:(Class)clazz propName:(nonnull NSString *)propName;
- (void)bindMethodToJavaScript:(Class)clazz selector:(nonnull SEL)aSelector;
- (void)exportMethodToJavaScript:(Class)clazz selector:(nonnull SEL)aSelector;
- (void)exportMethodToJavaScript:(Class)clazz selector:(SEL)aSelector jsName:(NSString *)jsName;
- (void)exportScriptToJavaScript:(Class)clazz script:(NSString *)script;
- (nullable id)nsValueWithJSValue:(JSValue *)value;
- (nullable id)nsValueWithObjectRef:(nonnull NSString *)objectRef;
- (nullable JSValue *)scriptObjectWithObject:(nonnull NSObject *)anObject
                                     context:(nonnull JSContext *)context
                                 initializer:(nullable id (^)(NSArray *))initializer
                              createIfNeeded:(BOOL)createdIfNeed;
- (nonnull NSArray<JSValue *> *)scriptObjectsWithObject:(nonnull NSObject *)anObject;

@end
