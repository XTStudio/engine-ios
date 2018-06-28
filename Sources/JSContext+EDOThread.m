//
//  JSContext+EndoThread.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/28.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "JSContext+EDOThread.h"
#import "NSObject+EDOObjectRef.h"
#import "EDOExporter.h"
#import "EDOExportable.h"
#import <objc/runtime.h>

@implementation EDOObjectReference

- (instancetype)initWithValue:(NSObject *)value {
    self = [super init];
    if (self) {
        _value = value;
        value.edo_refCount++;
    }
    return self;
}

@end

@implementation JSContext (EDOThread)

static int kReferenceTag;

- (NSMutableDictionary<NSString *,EDOObjectReference *> *)references {
    if (objc_getAssociatedObject(self, &kReferenceTag) == nil) {
        self.references = [NSMutableDictionary dictionary];
    }
    return objc_getAssociatedObject(self, &kReferenceTag);
}

- (void)setReferences:(NSMutableDictionary<NSString *,EDOObjectReference *> *)references {
    objc_setAssociatedObject(self, &kReferenceTag, references, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JSValue *)edo_createMetaClass:(NSObject *)anObject {
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    return [self evaluateScript:[NSString stringWithFormat:@"new _EDO_MetaClass(\"%@\", \"%@\")",
                                 NSStringFromClass(anObject.class), anObject.edo_objectRef]];
}

- (void)edo_storeScriptObject:(NSObject *)anObject scriptObject:(JSValue *)scriptObject {
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    @synchronized(self) {
        EDOObjectReference *ref = self.references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
        ref.soManagedValue = [JSManagedValue managedValueWithValue:scriptObject andOwner:self];
        [self.references setObject:ref forKey:anObject.edo_objectRef];
    }
}

- (id)edo_nsValueWithObjectRef:(NSString *)objectRef {
    @synchronized(self) {
        return self.references[objectRef].value;
    }
}

- (JSValue *)edo_jsValueWithObject:(NSObject *)anObject initializer:(id (^)(NSArray *, BOOL))initializer createIfNeeded:(BOOL)createIfNeeded {
    if ([anObject isKindOfClass:[JSValue class]]) {
        return (id)anObject;
    }
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    if (self.references[anObject.edo_objectRef].soManagedValue.value != nil) {
        return self.references[anObject.edo_objectRef].soManagedValue.value;
    }
    else if (createIfNeeded) {
        for (NSString *aKey in [EDOExporter sharedExporter].exportables) {
            EDOExportable *exportable = [EDOExporter sharedExporter].exportables[aKey];
            if (exportable.clazz == anObject.class) {
                if (initializer != nil) {
                    JSValue *objectMetaClass = [self evaluateScript:[NSString stringWithFormat:@"new _EDO_MetaClass(\"%@\", \"%@\")",
                                                                     exportable.name,
                                                                     anObject.edo_objectRef]];
                    JSValue *scriptObject = initializer(@[objectMetaClass], YES);
                    @synchronized(self) {
                        EDOObjectReference *ref = self.references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
                        ref.soManagedValue = [JSManagedValue managedValueWithValue:scriptObject];
                        [self.references setObject:ref forKey:anObject.edo_objectRef];
                    }
                    return scriptObject;
                }
                else {
                    JSValue *scriptObject = [self evaluateScript:[NSString stringWithFormat:@"new %@(new _EDO_MetaClass(\"%@\", \"%@\"))",
                                                                  exportable.name,
                                                                  exportable.name,
                                                                  anObject.edo_objectRef]];
                    @synchronized(self) {
                        EDOObjectReference *ref = self.references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
                        ref.soManagedValue = [JSManagedValue managedValueWithValue:scriptObject];
                        [self.references setObject:ref forKey:anObject.edo_objectRef];
                    }
                    return scriptObject;
                }
            }
        }
    }
    return nil;
}

- (void)edo_garbageCollect {
    NSMutableArray *removingKeys = [NSMutableArray array];
    @synchronized(self) {
        [self.references enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOObjectReference * _Nonnull obj, BOOL * _Nonnull stop) {
            long retainCount = (long)CFGetRetainCount((__bridge CFTypeRef)(obj.value));
            if (retainCount <= obj.value.edo_refCount) {
                [removingKeys addObject:key];
            }
        }];
        for (NSString *removeKey in removingKeys) {
            [self.virtualMachine removeManagedReference:self.references[removeKey].soManagedValue withOwner:self];
            self.references[removeKey].value.edo_refCount--;
            [self.references removeObjectForKey:removeKey];
        }
    }
}

@end
