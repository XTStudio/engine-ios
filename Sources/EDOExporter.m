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
            if (self.scriptObjects[key].value == nil || copy[key].metaClassManagedValue.value == nil) {
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
    [script appendString:@"!function(e){\"use strict\";function t(){}function n(e,t){for(var n=e.length;n--;)if(e[n].listener===t)return n;return-1}function r(e){return function(){return this[e].apply(this,arguments)}}function i(e){return\"function\"==typeof e||e instanceof RegExp||!(!e||\"object\"!=typeof e)&&i(e.listener)}var s=t.prototype,o=e.EventEmitter;s.getListeners=function(e){var t,n,r=this._getEvents();if(e instanceof RegExp){t={};for(n in r)r.hasOwnProperty(n)&&e.test(n)&&(t[n]=r[n])}else t=r[e]||(r[e]=[]);return t},s.flattenListeners=function(e){var t,n=[];for(t=0;t<e.length;t+=1)n.push(e[t].listener);return n},s.getListenersAsObject=function(e){var t,n=this.getListeners(e);return n instanceof Array&&(t={},t[e]=n),t||n},s.addListener=function(e,t){if(!i(t))throw new TypeError(\"listener must be a function\");var r,s=this.getListenersAsObject(e),o=\"object\"==typeof t;for(r in s)s.hasOwnProperty(r)&&n(s[r],t)===-1&&s[r].push(o?t:{listener:t,once:!1});return this},s.on=r(\"addListener\"),s.addOnceListener=function(e,t){return this.addListener(e,{listener:t,once:!0})},s.once=r(\"addOnceListener\"),s.defineEvent=function(e){return this.getListeners(e),this},s.defineEvents=function(e){for(var t=0;t<e.length;t+=1)this.defineEvent(e[t]);return this},s.removeListener=function(e,t){var r,i,s=this.getListenersAsObject(e);for(i in s)s.hasOwnProperty(i)&&(r=n(s[i],t),r!==-1&&s[i].splice(r,1));return this},s.off=r(\"removeListener\"),s.addListeners=function(e,t){return this.manipulateListeners(!1,e,t)},s.removeListeners=function(e,t){return this.manipulateListeners(!0,e,t)},s.manipulateListeners=function(e,t,n){var r,i,s=e?this.removeListener:this.addListener,o=e?this.removeListeners:this.addListeners;if(\"object\"!=typeof t||t instanceof RegExp)for(r=n.length;r--;)s.call(this,t,n[r]);else for(r in t)t.hasOwnProperty(r)&&(i=t[r])&&(\"function\"==typeof i?s.call(this,r,i):o.call(this,r,i));return this},s.removeEvent=function(e){var t,n=typeof e,r=this._getEvents();if(\"string\"===n)delete r[e];else if(e instanceof RegExp)for(t in r)r.hasOwnProperty(t)&&e.test(t)&&delete r[t];else delete this._events;return this},s.removeAllListeners=r(\"removeEvent\"),s.emitEvent=function(e,t){var n,r,i,s,o,u=this.getListenersAsObject(e);for(s in u)if(u.hasOwnProperty(s))for(n=u[s].slice(0),i=0;i<n.length;i++)r=n[i],r.once===!0&&this.removeListener(e,r.listener),o=r.listener.apply(this,t||[]),o===this._getOnceReturnValue()&&this.removeListener(e,r.listener);return this},s.trigger=r(\"emitEvent\"),s.emit=function(e){var t=Array.prototype.slice.call(arguments,1);return this.emitEvent(e,t)},s.setOnceReturnValue=function(e){return this._onceReturnValue=e,this},s._getOnceReturnValue=function(){return!this.hasOwnProperty(\"_onceReturnValue\")||this._onceReturnValue},s._getEvents=function(){return this._events||(this._events={})},t.noConflict=function(){return e.EventEmitter=o,t},\"function\"==typeof define&&define.amd?define(function(){return t}):\"object\"==typeof module&&module.exports?module.exports=t:e.EventEmitter=t}(this||{});var __extends=(this&&this.__extends)||(function(){var extendStatics=Object.setPrototypeOf||({__proto__:[]}instanceof Array&&function(d,b){d.__proto__=b})||function(d,b){for(var p in b)if(b.hasOwnProperty(p))d[p]=b[p]};return function(d,b){extendStatics(d,b);function __(){this.constructor=d}d.prototype=b===null?Object.create(b):(__.prototype=b.prototype,new __())}})();var _EDO_MetaClass = /** @class */ (function () { function _EDO_MetaClass(classname, objectRef) { this.classname = classname; this.objectRef = objectRef; } return _EDO_MetaClass; }());var _EDO_Callback=(function(){function _EDO_Callback(func){this.func=func;this._meta_class={classname:\"__Function\"}}return _EDO_Callback}());var EDOObject=(function(_super){; __extends(EDOObject, _super); function EDOObject(){var _this = _super.call(this, EDOObject) || this;_this.__callbacks=[]}EDOObject.prototype.__convertToJSValue=function(parameter){if(typeof parameter===\"function\"){var callback=new _EDO_Callback(parameter);this.__callbacks.push(callback);callback._meta_class.idx=this.__callbacks.length-1;return callback}return parameter};EDOObject.prototype.__invokeCallback=function(idx,args){if(this.__callbacks[idx]){this.__callbacks[idx].func.apply(this,args)}};return EDOObject}(EventEmitter));"];
    NSMutableDictionary<NSString *, EDOExportable *> *exportables = self.exportables.mutableCopy;
    NSMutableSet *exported = [NSMutableSet set];
    [exported addObject:@"EDOObject"];
    __block NSInteger exportingLoopCount = 0;
    while (exportables.count > 0) {
        exportingLoopCount = 0;
        [exportables.copy enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classKey, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.superName == nil) {
                [exportables removeObjectForKey:classKey];
                return;
            }
            if (![exported containsObject:obj.superName]) {
                return;
            }
            NSString *constructorScript = [NSString stringWithFormat:@"function Initializer(){var _this = _super.call(this, %@) || this;if(arguments[0]instanceof _EDO_MetaClass){_this._meta_class=arguments[0]}else{var args=[];for(var key in arguments){args.push(_this.__convertToJSValue(arguments[key]))}_this._meta_class=ENDO.createInstanceWithNameArgumentsOwner(\"%@\",args,_this)}return _this;}", classKey, classKey];
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
            [obj.exportedMethods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull methodSelector, NSString * _Nonnull jsName, BOOL * _Nonnull stop) {
                [exportMethodScript appendFormat:@"Initializer.prototype.%@ = function () {var args=[];for(var key in arguments){args.push(this.__convertToJSValue(arguments[key]))}return ENDO.callMethodWithNameArgumentsOwner(\"%@\", args, this);};",
                 jsName,
                 methodSelector];
            }];
            NSMutableString *exportedScript = [NSMutableString string];
            [obj.exportedScripts enumerateObjectsUsingBlock:^(NSString * _Nonnull script, NSUInteger idx, BOOL * _Nonnull stop) {
                [exportedScript appendString:script];
            }];
            NSString *clazzScript = [NSString stringWithFormat:@";var %@ = /** @class */ (function (_super) {;__extends(Initializer, _super) ;%@;%@;%@;%@;%@;return Initializer; }(%@));",
                                     classKey, constructorScript, propsScript, bindMethodScript, exportMethodScript, exportedScript, obj.superName];
            [script appendString:clazzScript];
            [exported addObject:obj.name];
            [exportables removeObjectForKey:classKey];
            exportingLoopCount++;
        }];
        NSAssert(exportingLoopCount > 0, @"Did you forgot to export some class superClass?");
    }
    context[@"ENDO"] = [EDOExporter sharedExporter];
    [context evaluateScript:script];
}

- (void)exportClass:(Class)clazz name:(NSString *)name superName:(NSString *)superName {
    EDOExportable *exportable = [[EDOExportable alloc] init];
    exportable.clazz = clazz;
    exportable.name = name;
    exportable.superName = superName ?: @"EDOObject";
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
            NSAssert(obj.exportedMethods[selectorName] == nil, @"Can not bindMethod while it has been exported before.");
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
            if (target.edo_objectRef != nil) {
                JSValue *scriptObject = [self scriptObjectWithObject:target];
                if (scriptObject != nil) {
                    [scriptObject invokeMethod:[NSString stringWithFormat:@"__%@", [[selectorName componentsSeparatedByString:@":"] firstObject]]
                                 withArguments:@[]];
                }
            }
        }
    } error:NULL];
}

- (void)exportMethodToJavaScript:(Class)clazz selector:(SEL)aSelector {
    [self exportMethodToJavaScript:clazz selector:aSelector jsName:nil];
}

- (void)exportMethodToJavaScript:(Class)clazz selector:(SEL)aSelector jsName:(NSString *)jsName {
    NSString *selectorName = NSStringFromSelector(aSelector);
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            NSAssert(![obj.bindedMethods containsObject:selectorName], @"Can not exportMethod while it has been binded before.");
            NSMutableDictionary *exportedMethods = (obj.exportedMethods ?: @{}).mutableCopy;
            if (jsName != nil) {
                exportedMethods[selectorName] = jsName;
            }
            else {
                NSArray *components = [[selectorName stringByReplacingOccurrencesOfString:@"edo_" withString:@""] componentsSeparatedByString:@":"];
                NSMutableString *jsName = [NSMutableString string];
                [components enumerateObjectsUsingBlock:^(NSString * _Nonnull component, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (component.length < 1) {
                        return ;
                    }
                    if (idx == 0) {
                        [jsName appendString:component];
                    }
                    else {
                        [jsName appendFormat:@"%@%@", [component substringToIndex:1].uppercaseString, [component substringFromIndex:1]];
                    }
                }];
                exportedMethods[selectorName] = jsName.copy;
            }
            obj.exportedMethods = exportedMethods.copy;
        }
    }];
}

- (void)exportScriptToJavaScript:(Class)clazz script:(NSString *)script {
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            NSMutableArray *exportedScripts = (obj.exportedScripts ?: @[]).mutableCopy;
            if (![exportedScripts containsObject:script]) {
                [exportedScripts addObject:script];
            }
            obj.exportedScripts = exportedScripts.copy;
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
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[ownerObject methodSignatureForSelector:selector]];
            [invocation setTarget:ownerObject];
            [invocation setSelector:selector];
            [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                char argumentType[256] = {};
                method_getArgumentType(class_getInstanceMethod([ownerObject class], selector), (unsigned int)(idx + 2), argumentType, 256);
                if (strcmp(argumentType, "@") == 0) {
                    [invocation setArgument:&obj atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "i") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    int argument = [obj intValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "s") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    short argument = [obj shortValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "l") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    long argument = [obj longValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "q") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    long long argument = [obj longLongValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "I") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    unsigned int argument = [obj unsignedIntValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "S") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    unsigned short argument = [obj unsignedShortValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "L") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    unsigned long argument = [obj unsignedLongValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "Q") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    unsigned long long argument = [obj unsignedLongLongValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "f") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    float argument = [obj floatValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "d") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    double argument = [obj doubleValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else if (strcmp(argumentType, "B") == 0 && [obj isKindOfClass:[NSNumber class]]) {
                    bool argument = [obj boolValue];
                    [invocation setArgument:&argument atIndex:idx + 2];
                }
                else {
                    [invocation setArgument:&obj atIndex:idx + 2];
                }
            }];
            [invocation invoke];
            if (strcmp(ret, "v") != 0) {
                id returnValue;
                [invocation getReturnValue:&returnValue];
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
        @synchronized(self) {
            EDOObjectReference *weakRef = self.references[objectRef];
            if ([weakRef isKindOfClass:[EDOObjectReference class]]) {
                NSObject *anObject = weakRef.value;
                return anObject;
            }
        }
    }
    return nil;
}

- (JSValue *)scriptObjectWithObject:(NSObject *)anObject {
    @synchronized(self) {
        if (anObject.edo_objectRef != nil && self.scriptObjects[anObject.edo_objectRef] != nil) {
            return self.scriptObjects[anObject.edo_objectRef].value;
        }
        else if (anObject.edo_objectRef == nil) {
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
                    [self.references setObject:objectReference forKey:anObject.edo_objectRef];
                    [self.scriptObjects setObject:[JSManagedValue managedValueWithValue:scriptObject] forKey:anObject.edo_objectRef];
                    return scriptObject;
                }
            }
            return nil;
        }
        else {
            return nil;
        }
    }
}

#pragma mark - owner management

- (void)retain:(NSObject *)anObject {
    if (anObject.edo_objectRef != nil) {
        @synchronized(self) {
            JSManagedValue *managedObject = self.scriptObjects[anObject.edo_objectRef];
            EDOObjectReference *objectReference = self.references[anObject.edo_objectRef];
            if (managedObject != nil && managedObject.value != nil && objectReference != nil) {
                objectReference.edo_retainCount++;
                if (objectReference.edo_retainCount == 1) {
                    [managedObject.value.context.virtualMachine addManagedReference:managedObject withOwner:self];
                }
            }
        }
    }
}

- (void)release:(NSObject *)anObject {
    if (anObject.edo_objectRef != nil) {
        @synchronized(self) {
            JSManagedValue *managedObject = self.scriptObjects[anObject.edo_objectRef];
            EDOObjectReference *objectReference = self.references[anObject.edo_objectRef];
            if (managedObject != nil && managedObject.value != nil && objectReference != nil) {
                objectReference.edo_retainCount--;
                if (objectReference.edo_retainCount <= 0) {
                    [managedObject.value.context.virtualMachine removeManagedReference:managedObject withOwner:self];
                }
            }
        }
    }
}

@end
