//
//  EDOExport.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import "EDOExporter.h"
#import "EDOExportable.h"
#import "NSObject+EDOObjectRef.h"
#import "EDOObjectTransfer.h"

@interface EDOObjectReference: NSObject

@property (nonatomic, strong) NSObject *value;
@property (nonatomic, strong) JSManagedValue *metaClassManagedValue;
@property (nonatomic, assign) NSInteger edo_retainCount;

@end

@implementation EDOObjectReference

- (instancetype)initWithValue:(NSObject *)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

@end

@interface EDOExporter ()

@property (nonatomic, strong) NSDictionary<NSString *, EDOExportable *> *exportables;
@property (nonatomic, strong) NSMutableDictionary<NSString *, EDOObjectReference *> *references;
@property (nonatomic, strong) NSMutableDictionary<NSString *, JSManagedValue *> *scriptObjects;

@end

@implementation EDOExporter

+ (EDOExporter *)sharedExporter {
    static EDOExporter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [EDOExporter new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _exportables = @{};
        _references = [NSMutableDictionary dictionary];
        _scriptObjects = [NSMutableDictionary dictionary];
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(runGC) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runGC) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)runGC {
#ifdef DEV
    NSLog(@"[EDOExporter] GC Running.");
#endif
    @synchronized(self) {
        NSDictionary<NSString *, EDOObjectReference *> *copy = self.references.copy;
        for (NSString *key in copy) {
            if (copy[key].metaClassManagedValue.value == nil) {
                [self.references removeObjectForKey:key];
                [self.scriptObjects removeObjectForKey:key];
#ifdef DEV
                NSLog(@"[EDOExporter] %@ object released", key);
#endif
            }
        }
    }
}

- (void)exportWithContext:(JSContext *)context {
    NSMutableString *script = [NSMutableString string];
    [script appendString:@"var __extends=(this&&this.__extends)||(function(){var extendStatics=Object.setPrototypeOf||({__proto__:[]}instanceof Array&&function(d,b){d.__proto__=b})||function(d,b){for(var p in b)if(b.hasOwnProperty(p))d[p]=b[p]};return function(d,b){extendStatics(d,b);function __(){this.constructor=d}d.prototype=b===null?Object.create(b):(__.prototype=b.prototype,new __())}})();var _EDO_MetaClass = /** @class */ (function () { function _EDO_MetaClass(classname, objectRef) { this.classname = classname; this.objectRef = objectRef; } return _EDO_MetaClass; }());var _EDO_Callback=(function(){function _EDO_Callback(func){this.func=func;this._meta_class={classname:\"__Function\"}}return _EDO_Callback}());var EDOObject=(function(){function EDOObject(){this.__callbacks=[]}EDOObject.prototype.__convertToJSValue=function(parameter){if(typeof parameter===\"function\"){var callback=new _EDO_Callback(parameter);this.__callbacks.push(callback);callback._meta_class.idx=this.__callbacks.length-1;return callback}return parameter};EDOObject.prototype.__invokeCallback=function(idx,args){if(this.__callbacks[idx]){this.__callbacks[idx].func.apply(this,args)}};return EDOObject}());"];
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classKey, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *constructorScript = [NSString stringWithFormat:@"function Initializer(){var _this = _super.call(this) || this;if(arguments[0]instanceof _EDO_MetaClass){_this._meta_class=arguments[0]}else{var args=[];for(var key in arguments){args.push(_this.__convertToJSValue(arguments[key]))}_this._meta_class=ENDO.createInstanceWithNameArgumentsOwner(\"%@\",args,_this)}return _this;}", classKey];
        NSMutableString *propsScript = [NSMutableString string];
        [obj.exportedProps enumerateObjectsUsingBlock:^(NSString * _Nonnull propKey, NSUInteger idx, BOOL * _Nonnull stop) {
            [propsScript appendFormat:@"Object.defineProperty(Initializer.prototype,\"%@\",{get:function(){return ENDO.valueWithPropertyNameOwner(\"%@\",this)},set:function(value){ENDO.setValueWithPropertyNameValueOwner(\"%@\",value,this)},enumerable:false,configurable:true});",
             [propKey stringByReplacingOccurrencesOfString:@"edo_" withString:@""],
             propKey,
             propKey];
        }];
        NSMutableString *bindMethodScript = [NSMutableString string];
        [obj.bindedMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull methodKey, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *methodName = [methodKey componentsSeparatedByString:@":"].firstObject;
            [bindMethodScript appendFormat:@"Initializer.prototype.%@=function(){};Initializer.prototype.__%@=function(){this.%@.apply(this,arguments)};", methodName, methodName, methodName];
        }];
        NSMutableString *exportMethodScript = [NSMutableString string];
        [obj.exportedMethods enumerateObjectsUsingBlock:^(NSString * _Nonnull methodKey, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *methodName = [methodKey componentsSeparatedByString:@":"].firstObject;
            [exportMethodScript appendFormat:@"Initializer.prototype.%@ = function () {var args=[];for(var key in arguments){args.push(this.__convertToJSValue(arguments[key]))}return ENDO.callMethodWithNameArgumentsOwner(\"%@\", args, this);};",
             [methodName stringByReplacingOccurrencesOfString:@"edo_" withString:@""],
             methodKey];
        }];
        NSString *clazzScript = [NSString stringWithFormat:@";var %@ = /** @class */ (function (_super) {;__extends(Initializer, _super) ;%@ ;%@ ;%@ ;%@ ;return Initializer; }(EDOObject));",
                                 classKey, constructorScript, propsScript, bindMethodScript, exportMethodScript];
        [script appendString:clazzScript];
    }];
    context[@"ENDO"] = [EDOExporter sharedExporter];
    [context evaluateScript:script];
}

- (void)exportClass:(Class)clazz name:(NSString *)name {
    EDOExportable *exportable = [[EDOExportable alloc] init];
    exportable.clazz = clazz;
    exportable.name = name;
    NSMutableDictionary *mutableExportables = [self.exportables mutableCopy];
    [mutableExportables setObject:exportable forKey:name];
    self.exportables = mutableExportables.copy;
}

- (void)exportInitializer:(Class)clazz initializer:(EDOInitializer)initializer {
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            obj.initializer = initializer;
        }
    }];
}

- (void)exportProperty:(Class)clazz propName:(NSString *)propName {
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            NSMutableArray *mutableProps = (obj.exportedProps ?: @[]).mutableCopy;
            if (![mutableProps containsObject:propName]) {
                [mutableProps addObject:propName];
            }
            obj.exportedProps = mutableProps.copy;
        }
    }];
}

- (void)bindMethodToJavaScript:(Class)clazz selector:(SEL)aSelector {
    NSString *selectorName = NSStringFromSelector(aSelector);
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            NSAssert(![obj.exportedMethods containsObject:selectorName], @"Can not bindMethod while it has been exported before.");
            NSMutableArray *bindedMethods = (obj.bindedMethods ?: @[]).mutableCopy;
            if (![bindedMethods containsObject:selectorName]) {
                [bindedMethods addObject:selectorName];
            }
            obj.bindedMethods = bindedMethods.copy;
        }
    }];
    [clazz aspect_hookSelector:aSelector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        if ([aspectInfo.instance isKindOfClass:[NSObject class]]) {
            NSObject *target = aspectInfo.instance;
            if ([target edo_objectRef] != nil) {
                JSValue *scriptObject = self.scriptObjects[target.edo_objectRef].value;
                if (scriptObject != nil) {
                    [scriptObject invokeMethod:[NSString stringWithFormat:@"__%@", [[NSStringFromSelector(aspectInfo.originalInvocation.selector) componentsSeparatedByString:@":"] firstObject]]
                                 withArguments:@[]];
                }
            }
        }
    } error:NULL];
}

- (void)exportMethodToJavaScript:(Class)clazz selector:(SEL)aSelector {
    NSString *selectorName = NSStringFromSelector(aSelector);
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            NSAssert(![obj.bindedMethods containsObject:selectorName], @"Can not exportMethod while it has been binded before.");
            NSMutableArray *exportedMethods = (obj.exportedMethods ?: @[]).mutableCopy;
            if (![exportedMethods containsObject:selectorName]) {
                [exportedMethods addObject:selectorName];
            }
            obj.exportedMethods = exportedMethods.copy;
        }
    }];
}

- (JSValue *)createInstanceWithName:(NSString *)name arguments:(NSArray *)arguments owner:(JSValue *)owner {
    if ([name isKindOfClass:[NSString class]] && self.exportables[name] != nil) {
        NSObject *newInstance = self.exportables[name].initializer != nil ? self.exportables[name].initializer(arguments) : [self.exportables[name].clazz new];
        return [self createMetaClassWithObject:newInstance context:[JSContext currentContext] owner:owner];
    }
    return nil;
}

- (JSValue *)createMetaClassWithObject:(NSObject *)anObject context:(JSContext *)context owner:(JSValue *)owner {
    if (anObject.edo_objectRef == nil) {
        anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
    }
    EDOObjectReference *objectReference = [[EDOObjectReference alloc] initWithValue:anObject];
    JSValue *objectMetaClass = [context evaluateScript:[NSString stringWithFormat:@"new _EDO_MetaClass(\"%@\", \"%@\")", NSStringFromClass(anObject.class), anObject.edo_objectRef]];
    objectReference.metaClassManagedValue = [[JSManagedValue alloc] initWithValue:objectMetaClass];
    @synchronized(self) {
        [self.references setObject:objectReference forKey:anObject.edo_objectRef];
        if (owner != nil) {
            [self.scriptObjects setObject:[JSManagedValue managedValueWithValue:owner] forKey:anObject.edo_objectRef];
        }
    }
    return objectMetaClass;
}

- (JSValue *)valueWithPropertyName:(NSString *)name owner:(JSValue *)owner {
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        @try {
            id returnValue = [ownerObject valueForKey:name];
            return [EDOObjectTransfer convertToJSValueWithObject:returnValue context:owner.context];
        } @catch (NSException *exception) { } @finally { }
    }
    return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
}

- (void)setValueWithPropertyName:(NSString *)name value:(JSValue *)value owner:(JSValue *)owner {
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        @try {
            char ret[256];
            method_getReturnType(class_getInstanceMethod(ownerObject.class, NSSelectorFromString(name)), ret, 256);
            [ownerObject setValue:[EDOObjectTransfer convertToNSValueWithJSValue:value
                                                                    eageringType:[NSString stringWithUTF8String:ret]
                                                                           owner:owner] forKey:name];
        } @catch (NSException *exception) { } @finally { }
    }
}

- (JSValue *)callMethodWithName:(NSString *)name arguments:(NSArray *)jsArguments owner:(JSValue *)owner {
    NSArray *arguments = [EDOObjectTransfer convertToNSArgumentsWithJSArguments:jsArguments owner:owner];
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    SEL selector = NSSelectorFromString(name);
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        @try {
            char ret[256];
            method_getReturnType(class_getInstanceMethod(ownerObject.class, selector), ret, 256);
            if (strcmp(ret, "v") == 0) {
                [ownerObject performSelector:selector
                                  withObject:0 < arguments.count && arguments[0] != [NSNull null] ? arguments[0] : nil
                                  withObject:1 < arguments.count && arguments[1] != [NSNull null] ? arguments[1] : nil];
            }
            else {
                id returnValue = [ownerObject performSelector:selector
                                                   withObject:0 < arguments.count && arguments[0] != [NSNull null] ? arguments[0] : nil
                                                   withObject:1 < arguments.count && arguments[1] != [NSNull null] ? arguments[1] : nil];
                return [EDOObjectTransfer convertToJSValueWithObject:returnValue context:owner.context];
            }
        } @catch (NSException *exception) { } @finally { }
    }
    return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
}

- (id)nsValueWithJSValue:(JSValue *)value {
    if (value.isObject) {
        JSValue *metaClassValue = [value objectForKeyedSubscript:@"_meta_class"];
        if (metaClassValue.isObject) {
            NSDictionary *metaClassInfo = metaClassValue.toDictionary;
            if ([metaClassInfo[@"objectRef"] isKindOfClass:[NSString class]]) {
                return [self nsValueWithObjectRef:metaClassInfo[@"objectRef"]];
            }
        }
    }
    return nil;
}

- (id)nsValueWithObjectRef:(NSString *)objectRef {
    if ([objectRef isKindOfClass:[NSString class]]) {
        EDOObjectReference *weakRef = self.references[objectRef];
        if ([weakRef isKindOfClass:[EDOObjectReference class]]) {
            NSObject *anObject = weakRef.value;
            return anObject;
        }
    }
    return nil;
}

- (JSValue *)scriptObjectWithObject:(NSObject *)anObject {
    if (anObject.edo_objectRef != nil && self.scriptObjects[anObject.edo_objectRef].value != nil) {
        return self.scriptObjects[anObject.edo_objectRef].value;
    }
    else {
        for (NSString *aKey in self.exportables) {
            if (self.exportables[aKey].clazz == anObject.class) {
                anObject.edo_objectRef = [[NSUUID UUID] UUIDString];
                JSValue *scriptObject = [[JSContext currentContext] evaluateScript:[NSString stringWithFormat:@"new %@(new _EDO_MetaClass(\"%@\", \"%@\"))",
                                                                                    self.exportables[aKey].name,
                                                                                    self.exportables[aKey].name,
                                                                                    anObject.edo_objectRef]];
                EDOObjectReference *objectReference = [[EDOObjectReference alloc] initWithValue:anObject];
                JSValue *objectMetaClass = [scriptObject objectForKeyedSubscript:@"_meta_class"];
                objectReference.metaClassManagedValue = [[JSManagedValue alloc] initWithValue:objectMetaClass];
                @synchronized(self) {
                    [self.references setObject:objectReference forKey:anObject.edo_objectRef];
                    [self.scriptObjects setObject:[JSManagedValue managedValueWithValue:scriptObject] forKey:anObject.edo_objectRef];
                }
                return scriptObject;
            }
        }
        return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
    }
}

#pragma mark - owner management

- (void)retain:(NSObject *)anObject {
    if (anObject.edo_objectRef != nil) {
        JSManagedValue *managedObject = self.scriptObjects[anObject.edo_objectRef];
        EDOObjectReference *objectReference = self.references[anObject.edo_objectRef];
        if (managedObject != nil && managedObject.value != nil && objectReference != nil) {
            objectReference.edo_retainCount++;
            [[managedObject.value.context virtualMachine] addManagedReference:managedObject withOwner:self];
        }
    }
}

- (void)release:(NSObject *)anObject {
    if (anObject.edo_objectRef != nil) {
        JSManagedValue *managedObject = self.scriptObjects[anObject.edo_objectRef];
        EDOObjectReference *objectReference = self.references[anObject.edo_objectRef];
        if (managedObject != nil && managedObject.value != nil && objectReference != nil) {
            objectReference.edo_retainCount--;
            if (objectReference.edo_retainCount <= 0) {
                [[managedObject.value.context virtualMachine] removeManagedReference:managedObject withOwner:self];
            }
            
        }
    }
}

@end
