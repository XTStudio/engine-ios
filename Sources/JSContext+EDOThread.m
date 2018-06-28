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

- (NSMutableDictionary<NSString *,EDOObjectReference *> *)edo_references {
    if (objc_getAssociatedObject(self, &kReferenceTag) == nil) {
        self.edo_references = [NSMutableDictionary dictionary];
    }
    return objc_getAssociatedObject(self, &kReferenceTag);
}

- (void)setEdo_references:(NSMutableDictionary<NSString *,EDOObjectReference *> *)references {
    objc_setAssociatedObject(self, &kReferenceTag, references, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JSValue *)edo_createMetaClass:(NSObject *)anObject {
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    @synchronized(self) {
        EDOObjectReference *ref = self.edo_references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
        [self.edo_references setObject:ref forKey:anObject.edo_objectRef];
    }
    return [self evaluateScript:[NSString stringWithFormat:@"new _EDO_MetaClass(\"%@\", \"%@\")",
                                 NSStringFromClass(anObject.class), anObject.edo_objectRef]];
}

- (void)edo_storeScriptObject:(NSObject *)anObject scriptObject:(JSValue *)scriptObject {
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    @synchronized(self) {
        EDOObjectReference *ref = self.edo_references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
        ref.soManagedValue = [JSManagedValue managedValueWithValue:scriptObject andOwner:self];
        [self.edo_references setObject:ref forKey:anObject.edo_objectRef];
    }
}

- (id)edo_nsValueWithObjectRef:(NSString *)objectRef {
    @synchronized(self) {
        return self.edo_references[objectRef].value;
    }
}

- (JSValue *)edo_jsValueWithObject:(NSObject *)anObject initializer:(id (^)(NSArray *, BOOL))initializer createIfNeeded:(BOOL)createIfNeeded {
    if ([anObject isKindOfClass:[JSValue class]]) {
        return (id)anObject;
    }
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    if (self.edo_references[anObject.edo_objectRef].soManagedValue.value != nil) {
        return self.edo_references[anObject.edo_objectRef].soManagedValue.value;
    }
    else if (createIfNeeded) {
        for (NSString *aKey in [EDOExporter sharedExporter].exportables) {
            EDOExportable *exportable = [EDOExporter sharedExporter].exportables[aKey];
            if (exportable.clazz == anObject.class) {
                if (initializer != nil) {
                    EDOObjectReference *ref;
                    @synchronized(self) {
                        ref = self.edo_references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
                        [self.edo_references setObject:ref forKey:anObject.edo_objectRef];
                    }
                    JSValue *objectMetaClass = [self evaluateScript:[NSString stringWithFormat:@"new _EDO_MetaClass(\"%@\", \"%@\")",
                                                                     exportable.name,
                                                                     anObject.edo_objectRef]];
                    JSValue *scriptObject = initializer(@[objectMetaClass], YES);
                    ref.soManagedValue = [JSManagedValue managedValueWithValue:scriptObject];
                    return scriptObject;
                }
                else {
                    EDOObjectReference *ref;
                    @synchronized(self) {
                        EDOObjectReference *ref = self.edo_references[anObject.edo_objectRef] ?: [[EDOObjectReference alloc] initWithValue:anObject];
                        [self.edo_references setObject:ref forKey:anObject.edo_objectRef];
                    }
                    JSValue *scriptObject = [self evaluateScript:[NSString stringWithFormat:@"new %@(new _EDO_MetaClass(\"%@\", \"%@\"))",
                                                                  exportable.name,
                                                                  exportable.name,
                                                                  anObject.edo_objectRef]];
                    ref.soManagedValue = [JSManagedValue managedValueWithValue:scriptObject];
                    return scriptObject;
                }
            }
        }
    }
    return nil;
}

- (void)edo_garbageCollect {
#ifdef DEV
    NSLog(@"GC Running");
#endif
    NSMutableArray *removingKeys = [NSMutableArray array];
    @synchronized(self) {
        [self.edo_references enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOObjectReference * _Nonnull obj, BOOL * _Nonnull stop) {
            CFIndex retainCount = (CFIndex)CFGetRetainCount((__bridge CFTypeRef)(obj.value));
            if (retainCount <= obj.value.edo_refCount + 1) {
                [self.virtualMachine removeManagedReference:obj.soManagedValue withOwner:self];
            }
            else {
                [self.virtualMachine addManagedReference:obj.soManagedValue withOwner:self];
            }
            if (retainCount <= obj.value.edo_refCount + 1 && obj.soManagedValue.value == nil) {
                [removingKeys addObject:key];
#ifdef DEV
                NSLog(@"remove - %@, %@", key, obj.value.class);
#endif
            }
        }];
        for (NSString *removeKey in removingKeys) {
            [self.virtualMachine removeManagedReference:self.edo_references[removeKey].soManagedValue withOwner:self];
            self.edo_references[removeKey].value.edo_refCount--;
            [self.edo_references removeObjectForKey:removeKey];
        }
    }
}

@end
