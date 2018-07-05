//
//  NSObject+EDOObjectRef.m
//  Endo-iOS
//
//  Created by PonyCui on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "NSObject+EDOObjectRef.h"
#import <objc/runtime.h>
#import "EDOExporter.h"
#import "EDOObjectTransfer.h"

@implementation NSObject (EDOObjectRef)

static int edo_refCount_key;
static int edo_objectRef_key;
static int edo_listeningEvents_key;

- (NSInteger)edo_refCount {
    return [objc_getAssociatedObject(self, &edo_refCount_key) integerValue];
}

- (void)setEdo_refCount:(NSInteger)edo_refCount {
    objc_setAssociatedObject(self, &edo_refCount_key, @(edo_refCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)edo_objectRef {
    return objc_getAssociatedObject(self, &edo_objectRef_key);
}

- (void)setEdo_objectRef:(NSString *)edo_objectRef {
    objc_setAssociatedObject(self, &edo_objectRef_key, edo_objectRef, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSSet *)edo_listeningEvents {
    return objc_getAssociatedObject(self, &edo_listeningEvents_key);
}

- (void)setEdo_listeningEvents:(NSSet *)edo_listeningEvents {
    objc_setAssociatedObject(self, &edo_listeningEvents_key, edo_listeningEvents, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)edo_emitWithEventName:(NSString *)named arguments:(NSArray *)arguments {
    if ([self edo_objectRef] == nil) {
        return;
    }
    if (![self.edo_listeningEvents containsObject:named]) {
        return;
    }
    [[[EDOExporter sharedExporter] scriptObjectsWithObject:self] enumerateObjectsUsingBlock:^(JSValue * _Nonnull scriptObject, NSUInteger idx, BOOL * _Nonnull stop) {
        if (arguments != nil && arguments.count > 0) {
            NSMutableArray *jsArguments = [[EDOObjectTransfer convertToJSArgumentsWithNSArguments:arguments context:scriptObject.context] mutableCopy];
            [jsArguments insertObject:named atIndex:0];
            [scriptObject invokeMethod:@"emit" withArguments:jsArguments.copy];
        }
        else {
            [scriptObject invokeMethod:@"emit" withArguments:@[named]];
        }
    }];
}
    
- (id)edo_valueWithEventName:(NSString *)named arguments:(NSArray *)arguments {
    if ([self edo_objectRef] == nil) {
        return nil;
    }
    if (![self.edo_listeningEvents containsObject:named]) {
        return nil;
    }
    JSValue *scripObject = [[EDOExporter sharedExporter] scriptObjectsWithObject:self].firstObject;
    if (scripObject != nil) {
        if (arguments != nil && arguments.count > 0) {
            NSMutableArray *jsArguments = [[EDOObjectTransfer convertToJSArgumentsWithNSArguments:arguments context:scripObject.context] mutableCopy];
            [jsArguments insertObject:named atIndex:0];
            JSValue *returnValue = [scripObject invokeMethod:@"val" withArguments:jsArguments.copy];
            return [EDOObjectTransfer convertToNSValueWithJSValue:returnValue owner:returnValue];
        }
        else {
            JSValue *returnValue = [scripObject invokeMethod:@"val" withArguments:@[named]];
            return [EDOObjectTransfer convertToNSValueWithJSValue:returnValue owner:returnValue];
        }
    }
    return nil;
}

@end
