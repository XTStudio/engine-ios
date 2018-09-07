//
//  EDOExport.m
//  Endo-iOS
//
//  Created by PonyCui on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Aspects/Aspects.h>
#import <objc/runtime.h>
#import <UULog/UULog.h>
#import "EDOExporter.h"
#import "EDOExportable.h"
#import "NSObject+EDOObjectRef.h"
#import "EDOObjectTransfer.h"
#import "JSContext+EDOThread.h"

@interface EDOContextWrapper: NSObject

@property (nonatomic, weak) JSContext *context;

@end

@implementation EDOContextWrapper

@end

@interface EDOExporter ()

@property (nonatomic, copy) NSDictionary<NSString *, EDOExportable *> *exportables;
@property (nonatomic, copy) NSDictionary<NSString *, id> *exportedConstants;
@property (nonatomic, copy) NSSet<NSString *> *exportedKeys;
@property (nonatomic, copy) NSArray<EDOContextWrapper *> *contexts;

@end

@implementation EDOExporter

+ (EDOExporter *)sharedExporter {
    static EDOExporter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EDOExporter alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _exportables = @{};
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(runGC) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runGC) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)runGC {
    for (EDOContextWrapper *contextWrapper in self.contexts) {
        JSContext *context = contextWrapper.context;
        if (context != nil) {
            [context edo_garbageCollect];
        }
    }
}

- (void)exportWithContext:(JSContext *)context {
    [UULog attachToContext:context];
    if ([context[@"global"] isUndefined]) {
        [context evaluateScript:@"var global = this;" withSourceURL:nil];
    }
    NSMutableString *script = [NSMutableString string];
    [script appendString:@"var __EDO_SUPERCLASS_TOKEN = '__EDO_SUPERCLASS_TOKEN__';"];
    [script appendString:@"var __extends=this&&this.__extends||function(){var extendStatics=Object.setPrototypeOf||{__proto__:[]}instanceof Array&&function(d,b){d.__proto__=b}||function(d,b){for(var p in b)if(b.hasOwnProperty(p))d[p]=b[p]};return function(d,b){extendStatics(d,b);function __(){this.constructor=d}d.prototype=b===null?Object.create(b):(__.prototype=b.prototype,new __)}}();(function(exports){\"use strict\";function EventEmitter(){}var proto=EventEmitter.prototype;var originalGlobalValue=exports.EventEmitter;function indexOfListener(listeners,listener){var i=listeners.length;while(i--){if(listeners[i].listener===listener){return i}}return-1}function alias(name){return function aliasClosure(){return this[name].apply(this,arguments)}}proto.getListeners=function getListeners(evt){var events=this._getEvents();var response;var key;if(evt instanceof RegExp){response={};for(key in events){if(events.hasOwnProperty(key)&&evt.test(key)){response[key]=events[key]}}}else{response=events[evt]||(events[evt]=[])}return response};proto.flattenListeners=function flattenListeners(listeners){var flatListeners=[];var i;for(i=0;i<listeners.length;i+=1){flatListeners.push(listeners[i].listener)}return flatListeners};proto.getListenersAsObject=function getListenersAsObject(evt){var listeners=this.getListeners(evt);var response;if(listeners instanceof Array){response={};response[evt]=listeners}return response||listeners};function isValidListener(listener){if(typeof listener===\"function\"||listener instanceof RegExp){return true}else if(listener&&typeof listener===\"object\"){return isValidListener(listener.listener)}else{return false}}proto.addListener=function addListener(evt,listener){if(!isValidListener(listener)){throw new TypeError(\"listener must be a function\")}var listeners=this.getListenersAsObject(evt);var listenerIsWrapped=typeof listener===\"object\";var key;for(key in listeners){if(listeners.hasOwnProperty(key)&&indexOfListener(listeners[key],listener)===-1){listeners[key].push(listenerIsWrapped?listener:{listener:listener,once:false})}}ENDO.addListenerWithNameOwner(evt,this);return this};proto.on=alias(\"addListener\");proto.addOnceListener=function addOnceListener(evt,listener){return this.addListener(evt,{listener:listener,once:true})};proto.once=alias(\"addOnceListener\");proto.defineEvent=function defineEvent(evt){this.getListeners(evt);return this};proto.defineEvents=function defineEvents(evts){for(var i=0;i<evts.length;i+=1){this.defineEvent(evts[i])}return this};proto.removeListener=function removeListener(evt,listener){var listeners=this.getListenersAsObject(evt);var index;var key;for(key in listeners){if(listeners.hasOwnProperty(key)){index=indexOfListener(listeners[key],listener);if(index!==-1){listeners[key].splice(index,1)}}}return this};proto.off=alias(\"removeListener\");proto.addListeners=function addListeners(evt,listeners){return this.manipulateListeners(false,evt,listeners)};proto.removeListeners=function removeListeners(evt,listeners){return this.manipulateListeners(true,evt,listeners)};proto.manipulateListeners=function manipulateListeners(remove,evt,listeners){var i;var value;var single=remove?this.removeListener:this.addListener;var multiple=remove?this.removeListeners:this.addListeners;if(typeof evt===\"object\"&&!(evt instanceof RegExp)){for(i in evt){if(evt.hasOwnProperty(i)&&(value=evt[i])){if(typeof value===\"function\"){single.call(this,i,value)}else{multiple.call(this,i,value)}}}}else{i=listeners.length;while(i--){single.call(this,evt,listeners[i])}}return this};proto.removeEvent=function removeEvent(evt){var type=typeof evt;var events=this._getEvents();var key;if(type===\"string\"){delete events[evt]}else if(evt instanceof RegExp){for(key in events){if(events.hasOwnProperty(key)&&evt.test(key)){delete events[key]}}}else{delete this._events}return this};proto.removeAllListeners=alias(\"removeEvent\");proto.emitEvent=function emitEvent(evt,args){var listenersMap=this.getListenersAsObject(evt);var listeners;var listener;var i;var key;var response;for(key in listenersMap){if(listenersMap.hasOwnProperty(key)){listeners=listenersMap[key].slice(0);for(i=0;i<listeners.length;i++){listener=listeners[i];if(listener.once===true){this.removeListener(evt,listener.listener)}response=listener.listener.apply(this,args||[]);if(response===this._getOnceReturnValue()){this.removeListener(evt,listener.listener)}}}}return this};proto.val=function emitEventWithReturnValue(evt){var args=Array.prototype.slice.call(arguments,1);var listenersMap=this.getListenersAsObject(evt);var listeners;var listener;var i;var key;for(key in listenersMap){if(listenersMap.hasOwnProperty(key)){listeners=listenersMap[key].slice(0);for(i=0;i<listeners.length;i++){listener=listeners[i];if(listener.once===true){this.removeListener(evt,listener.listener)}return listener.listener.apply(this,args||[])}}}return undefined};proto.trigger=alias(\"emitEvent\");proto.emit=function emit(evt){var args=Array.prototype.slice.call(arguments,1);return this.emitEvent(evt,args)};proto.setOnceReturnValue=function setOnceReturnValue(value){this._onceReturnValue=value;return this};proto._getOnceReturnValue=function _getOnceReturnValue(){if(this.hasOwnProperty(\"_onceReturnValue\")){return this._onceReturnValue}else{return true}};proto._getEvents=function _getEvents(){return this._events||(this._events={})};exports.EventEmitter=EventEmitter})(this||{});var _EDO_MetaClass=function(){function _EDO_MetaClass(classname,objectRef){this.classname=classname;this.objectRef=objectRef}return _EDO_MetaClass}();var _EDO_Callback=function(){function _EDO_Callback(func){this.func=func;this._meta_class={classname:\"__Function\"}}return _EDO_Callback}();var EDOObject=function(_super){__extends(EDOObject,_super);function EDOObject(){var _this=_super!==null&&_super.apply(this,arguments)||this;_this.__callbacks=[];return _this}EDOObject.prototype.__convertToJSValue=function(parameter){if(typeof parameter===\"function\"){var callback=new _EDO_Callback(parameter);this.__callbacks.push(callback);callback._meta_class.idx=this.__callbacks.length-1;return callback}else if(parameter instanceof ArrayBuffer){return{_meta_class:{classname:\"__ArrayBuffer\",bytes:Array.from(new Uint8Array(parameter))}}}return parameter};EDOObject.prototype.__invokeCallback=function(idx,args){if(this.__callbacks[idx]){return this.__callbacks[idx].func.apply(this,args)}};return EDOObject}(EventEmitter);"];
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
            if ([obj.superName isEqualToString:@"ENUM"]) {
                [script appendString:obj.exportedScripts.firstObject];
                [exported addObject:obj.name];
                [exportables removeObjectForKey:classKey];
                exportingLoopCount++;
                return;
            }
            if (![exported containsObject:obj.superName]) {
                return;
            }
            NSString *constructorScript = [NSString stringWithFormat:@"function Initializer(isParent){var _this = _super.call(this, __EDO_SUPERCLASS_TOKEN) || this;if(arguments[0]instanceof _EDO_MetaClass){_this._meta_class=arguments[0]}else if(isParent !== __EDO_SUPERCLASS_TOKEN){var args=[];for(var key in arguments){args.push(_this.__convertToJSValue(arguments[key]))}_this._meta_class=ENDO.createInstanceWithNameArgumentsOwner(\"%@\",args,_this)}return _this;}", classKey];
            NSMutableString *propsScript = [NSMutableString string];
            [obj.exportedProps enumerateObjectsUsingBlock:^(NSString * _Nonnull propKey, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.readonlyProps containsObject:propKey]) {
                    if ([propKey hasPrefix:@"s."]) {
                        [propsScript appendFormat:@"Object.defineProperty(Initializer,\"%@\",{get:function(){return ENDO.valueWithPropertyNameOwner(\"%@\",\"%@\")},set:function(value){},enumerable:false,configurable:true});",
                         [[propKey stringByReplacingOccurrencesOfString:@"edo_" withString:@""] stringByReplacingOccurrencesOfString:@"s." withString:@""],
                         propKey,
                         NSStringFromClass(obj.clazz)];
                    }
                    else {
                        [propsScript appendFormat:@"Object.defineProperty(Initializer.prototype,\"%@\",{get:function(){return ENDO.valueWithPropertyNameOwner(\"%@\",this)},set:function(value){},enumerable:false,configurable:true});",
                         [propKey stringByReplacingOccurrencesOfString:@"edo_" withString:@""],
                         propKey];
                    }
                }
                else {
                    if ([propKey hasPrefix:@"s."]) {
                        [propsScript appendFormat:@"Object.defineProperty(Initializer,\"%@\",{get:function(){return ENDO.valueWithPropertyNameOwner(\"%@\",\"%@\")},set:function(value){ENDO.setValueWithPropertyNameValueOwner(\"%@\",[value],\"%@\")},enumerable:false,configurable:true});",
                         [[propKey stringByReplacingOccurrencesOfString:@"edo_" withString:@""] stringByReplacingOccurrencesOfString:@"s." withString:@""],
                         propKey,
                         NSStringFromClass(obj.clazz),
                         propKey,
                         NSStringFromClass(obj.clazz)];
                    }
                    else {
                        [propsScript appendFormat:@"Object.defineProperty(Initializer.prototype,\"%@\",{get:function(){return ENDO.valueWithPropertyNameOwner(\"%@\",this)},set:function(value){ENDO.setValueWithPropertyNameValueOwner(\"%@\",value,this)},enumerable:false,configurable:true});",
                         [propKey stringByReplacingOccurrencesOfString:@"edo_" withString:@""],
                         propKey,
                         propKey];
                    }
                }
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
            NSMutableString *innerScript = [NSMutableString string];
            [obj.innerScripts enumerateObjectsUsingBlock:^(NSString * _Nonnull script, NSUInteger idx, BOOL * _Nonnull stop) {
                [innerScript appendFormat:@";%@;", script];
            }];
            NSMutableString *exportedScript = [NSMutableString string];
            [obj.exportedScripts enumerateObjectsUsingBlock:^(NSString * _Nonnull script, NSUInteger idx, BOOL * _Nonnull stop) {
                [exportedScript appendFormat:@";%@;", script];
            }];
            NSString *clazzScript = [NSString stringWithFormat:@";var %@ = /** @class */ (function (_super) {;__extends(Initializer, _super) ;%@;%@;%@;%@;%@;return Initializer; }(%@));%@",
                                     classKey,
                                     constructorScript,
                                     propsScript,
                                     bindMethodScript,
                                     exportMethodScript,
                                     innerScript,
                                     obj.superName,
                                     exportedScript];
            [script appendString:clazzScript];
            [exported addObject:obj.name];
            [exportables removeObjectForKey:classKey];
            exportingLoopCount++;
        }];
        NSAssert(exportingLoopCount > 0, @"Did you forgot to export some class superClass?");
    }
    context[@"ENDO"] = [EDOExporter sharedExporter];
    [context evaluateScript:script];
    [self.exportedConstants enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        context[key] = [EDOObjectTransfer convertToJSValueWithObject:obj context:context];
    }];
    BOOL shouldAddToContexts = YES;
    for (EDOContextWrapper *contextWrapper in self.contexts) {
        JSContext *weakContext = contextWrapper.context;
        if (weakContext == context) {
            shouldAddToContexts = NO;
            break;
        }
    }
    if (shouldAddToContexts) {
        NSMutableArray *contexts = [self.contexts mutableCopy] ?: [NSMutableArray array];
        EDOContextWrapper *contextWrapper = [[EDOContextWrapper alloc] init];
        contextWrapper.context = context;
        [contexts addObject:contextWrapper];
        self.contexts = contexts;
    }
}

- (void)exportEnum:(NSString *)name values:(NSDictionary *)values {
    EDOExportable *exportable = [[EDOExportable alloc] init];
    exportable.name = name;
    exportable.superName = @"ENUM";
    NSMutableString *valueScript = [NSMutableString string];
    [values enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [valueScript appendFormat:@"%@[%@[\"%@\"] = %@] = \"%@\";", exportable.name, exportable.name, key, obj, key];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            [valueScript appendFormat:@"%@[%@[\"%@\"] = \"%@\"] = \"%@\";", exportable.name, exportable.name, key, obj, key];
        }
    }];
    NSString *script = [NSString stringWithFormat:@"var %@;(function (%@) {%@})(%@ || (%@ = {}));",
                        exportable.name,
                        exportable.name,
                        valueScript,
                        exportable.name,
                        exportable.name];
    exportable.exportedScripts = @[script];
    NSMutableDictionary *mutableExportables = [self.exportables mutableCopy];
    [mutableExportables setObject:exportable forKey:name];
    self.exportables = mutableExportables.copy;
}

- (void)exportConst:(NSString *)name value:(id)value {
    NSMutableDictionary *mutableExportedConstants = [self.exportedConstants mutableCopy] ?: [NSMutableDictionary dictionary];
    [mutableExportedConstants setObject:value forKey:name];
    self.exportedConstants = mutableExportedConstants;
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

- (void)exportProperty:(Class)clazz propName:(NSString *)propName readonly:(BOOL)readonly {
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            NSMutableArray *mutableProps = (obj.exportedProps ?: @[]).mutableCopy;
            if (![mutableProps containsObject:propName]) {
                [mutableProps addObject:propName];
            }
            obj.exportedProps = mutableProps.copy;
            if (readonly) {
                NSMutableArray *readonlyProps = (obj.readonlyProps ?: @[]).mutableCopy;
                if (![readonlyProps containsObject:propName]) {
                    [readonlyProps addObject:propName];
                }
                obj.readonlyProps = readonlyProps;
            }
        }
    }];
    NSMutableSet *exportedKeys = [self.exportedKeys mutableCopy] ?: [NSMutableSet set];
    [exportedKeys addObject:[NSString stringWithFormat:@"%@.%@", NSStringFromClass(clazz), propName]];
    self.exportedKeys = exportedKeys;
}

- (void)exportStaticProperty:(Class)clazz propName:(NSString *)propName readonly:(BOOL)readonly {
    [self exportProperty:clazz propName:[NSString stringWithFormat:@"s.%@", propName] readonly:readonly];
}

- (void)bindMethodToJavaScript:(Class)clazz selector:(SEL)aSelector {
    [self bindMethodToJavaScript:clazz selector:aSelector isBefore:NO];
}

- (void)bindMethodToJavaScript:(Class)clazz selector:(SEL)aSelector isBefore:(BOOL)isBefore {
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
    [clazz aspect_hookSelector:aSelector withOptions:isBefore ? AspectPositionBefore : AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        if ([aspectInfo.instance isKindOfClass:[NSObject class]]) {
            NSObject *target = aspectInfo.instance;
            if (target.edo_objectRef != nil) {
                [[self scriptObjectsWithObject:target] enumerateObjectsUsingBlock:^(JSValue * _Nonnull scriptObject, NSUInteger idx, BOOL * _Nonnull stop) {
                    [scriptObject invokeMethod:[NSString stringWithFormat:@"__%@", [[selectorName componentsSeparatedByString:@":"] firstObject]]
                                 withArguments:[EDOObjectTransfer convertToJSArgumentsWithNSArguments:aspectInfo.arguments context:scriptObject.context]];
                }];
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
    NSMutableSet *exportedKeys = [self.exportedKeys mutableCopy] ?: [NSMutableSet set];
    [exportedKeys addObject:[NSString stringWithFormat:@"%@.(%@)", NSStringFromClass(clazz), selectorName]];
    self.exportedKeys = exportedKeys;
}

- (void)exportScriptToJavaScript:(Class)clazz script:(NSString *)script isInnerScript:(BOOL)isInnerScript {
    [self.exportables enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, EDOExportable * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.clazz == clazz) {
            if (isInnerScript) {
                NSMutableArray *innerScripts = (obj.innerScripts ?: @[]).mutableCopy;
                if (![innerScripts containsObject:script]) {
                    [innerScripts addObject:script];
                }
                obj.innerScripts = innerScripts.copy;
            }
            else {
                NSMutableArray *exportedScripts = (obj.exportedScripts ?: @[]).mutableCopy;
                if (![exportedScripts containsObject:script]) {
                    [exportedScripts addObject:script];
                }
                obj.exportedScripts = exportedScripts.copy;
            }
        }
    }];
}

- (JSValue *)createInstanceWithName:(NSString *)name arguments:(NSArray *)arguments owner:(JSValue *)owner {
    JSContext *context = owner.context;
    if (context == nil) {
        return nil;
    }
    if ([name isKindOfClass:[NSString class]] && self.exportables[name] != nil) {
        NSObject *newInstance = self.exportables[name].initializer != nil ? self.exportables[name].initializer([EDOObjectTransfer convertToNSArgumentsWithJSArguments:arguments owner:owner]) : [self.exportables[name].clazz new];
        if (newInstance == nil) {
            return [JSValue valueWithUndefinedInContext:owner.context];
        }
        [context edo_storeScriptObject:newInstance scriptObject:owner];
        return [context edo_createMetaClass:newInstance];
    }
    return [JSValue valueWithUndefinedInContext:owner.context];
}

- (JSValue *)valueWithPropertyName:(NSString *)name owner:(JSValue *)owner {
    if ([name hasPrefix:@"s."]) {
        @try {
            Class clazz = NSClassFromString(owner.toString);
            if (![self checkExported:clazz exportedKey:name]) {
                return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
            }
            char ret[256];
            SEL selector = NSSelectorFromString([name stringByReplacingOccurrencesOfString:@"s."
                                                                                withString:@""]);
            method_getReturnType(class_getClassMethod(clazz, selector), ret, 256);
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[clazz methodSignatureForSelector:selector]];
            [invocation setTarget:clazz];
            [invocation setSelector:selector];
            [invocation invoke];
            return [EDOObjectTransfer getReturnValueFromInvocation:invocation valueType:ret context:owner.context];
        } @catch (NSException *exception) {} @finally {}
    }
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        if (![self checkExported:ownerObject.class exportedKey:name]) {
            return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
        }
        @try {
            id returnValue = [ownerObject valueForKey:name];
            return [EDOObjectTransfer convertToJSValueWithObject:returnValue context:owner.context];
        } @catch (NSException *exception) { } @finally { }
    }
    return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
}

- (void)setValueWithPropertyName:(NSString *)name value:(JSValue *)value owner:(JSValue *)owner {
    if ([name hasPrefix:@"s."]) {
        NSArray *arguments = [EDOObjectTransfer convertToNSArgumentsWithJSArguments:value.toArray owner:owner];
        @try {
            Class clazz = NSClassFromString(owner.toString);
            if (![self checkExported:clazz exportedKey:name]) {
                return ;
            }
            
            NSString *trimName = [name stringByReplacingOccurrencesOfString:@"s." withString:@""];
            NSString *selectorName = [NSString stringWithFormat:@"set%@%@:",
                                      [trimName substringToIndex:1].uppercaseString,
                                      [trimName substringFromIndex:1]];
            SEL selector = NSSelectorFromString(selectorName);
            char ret[256];
            method_getReturnType(class_getClassMethod(clazz, selector), ret, 256);
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[clazz methodSignatureForSelector:selector]];
            [invocation setTarget:clazz];
            [invocation setSelector:selector];
            [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                char argumentType[256] = {};
                method_getArgumentType(class_getClassMethod(clazz, selector), (unsigned int)(idx + 2), argumentType, 256);
                [EDOObjectTransfer setArgumentToInvocation:invocation idx:idx + 2 obj:obj argumentType:argumentType];
            }];
            [invocation invoke];
            return ;
        } @catch (NSException *exception) {} @finally {}
    }
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        if (![self checkExported:ownerObject.class exportedKey:name]) {
            return;
        }
        @try {
            NSString *ocClass;
            char ret[256];
            method_getReturnType(class_getInstanceMethod(ownerObject.class, NSSelectorFromString(name)), ret, 256);
            if (strcmp(ret, "@") == 0) {
                objc_property_t property = class_getProperty(ownerObject.class, [name UTF8String]);
                if (property != NULL) {
                    const char *attributes = property_getAttributes(property);
                    char buffer[1 + strlen(attributes)];
                    strcpy(buffer, attributes);
                    char *state = buffer, *attribute;
                    while ((attribute = strsep(&state, ",")) != NULL) {
                        if (attribute[0] == 'T' && attribute[1] != '@') {
                            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
                            ocClass = name;
                        }
                        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
                            ocClass = @"@";
                        }
                        else if (attribute[0] == 'T' && attribute[1] == '@') {
                            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
                            ocClass = name;
                        }
                    }
                }
                else {
                    ocClass = [NSString stringWithUTF8String:ret];
                }
            }
            else {
                ocClass = [NSString stringWithUTF8String:ret];
            }
            id convertedValue = [EDOObjectTransfer convertToNSValueWithJSValue:value
                                                                  eageringType:ocClass
                                                                         owner:owner];
            Class ocClazz = NSClassFromString(ocClass);
            if (ocClazz == NULL) {
                [ownerObject setValue:convertedValue forKey:name];
            }
            else if (ocClazz != NULL && [convertedValue isKindOfClass:ocClazz]) {
                [ownerObject setValue:convertedValue forKey:name];
            }
            else if (ocClazz != NULL && convertedValue == nil) {
                [ownerObject setValue:nil forKey:name];
            }
        } @catch (NSException *exception) { } @finally { }
    }
}

- (JSValue *)callMethodWithName:(NSString *)name arguments:(NSArray *)jsArguments owner:(JSValue *)owner {
    NSArray *arguments = [EDOObjectTransfer convertToNSArgumentsWithJSArguments:jsArguments owner:owner];
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    SEL selector = NSSelectorFromString(name);
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        if (![self checkExported:ownerObject.class exportedKey:[NSString stringWithFormat:@"(%@)", name]]) {
            return [JSValue valueWithUndefinedInContext:[JSContext currentContext]];
        }
        @try {
            char ret[256];
            method_getReturnType(class_getInstanceMethod(ownerObject.class, selector), ret, 256);
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[ownerObject methodSignatureForSelector:selector]];
            [invocation setTarget:ownerObject];
            [invocation setSelector:selector];
            [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                char argumentType[256] = {};
                method_getArgumentType(class_getInstanceMethod([ownerObject class], selector), (unsigned int)(idx + 2), argumentType, 256);
                [EDOObjectTransfer setArgumentToInvocation:invocation idx:idx + 2 obj:obj argumentType:argumentType];
            }];
            [invocation invoke];
            return [EDOObjectTransfer getReturnValueFromInvocation:invocation valueType:ret context:owner.context];
        } @catch (NSException *exception) { } @finally { }
    }
    return [JSValue valueWithUndefinedInContext:owner.context];
}

- (void)addListenerWithName:(NSString *)name owner:(JSValue *)owner {
    NSObject *ownerObject = [EDOObjectTransfer convertToNSValueWithJSValue:owner owner:owner];
    if ([ownerObject isKindOfClass:[NSObject class]]) {
        NSMutableSet *mutable = [ownerObject.edo_listeningEvents mutableCopy] ?: [NSMutableSet set];
        [mutable addObject:name];
        ownerObject.edo_listeningEvents = mutable.copy;
    }
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
    for (EDOContextWrapper *contextWrapper in self.contexts) {
        JSContext *context = contextWrapper.context;
        if (context != nil) {
            id nsValue = [context edo_nsValueWithObjectRef:objectRef];
            if (nsValue != nil) {
                return nsValue;
            }
        }
    }
    return nil;
}

- (void)createScriptObjectIfNeed:(NSObject *)anObject
                         context:(JSContext *)context
                     initializer:(id (^)(NSArray *, BOOL))initializer
                  createIfNeeded:(BOOL)createdIfNeed {
    if (initializer != nil && !anObject.edo_customInitialized) {
        [context edo_unstoreScriptObject:anObject];
        [context edo_jsValueWithObject:anObject
                           initializer:initializer
                        createIfNeeded:createdIfNeed];
        anObject.edo_customInitialized = YES;
    }
}

- (JSValue *)scriptObjectWithObject:(NSObject *)anObject
                            context:(JSContext *)context
                        initializer:(id (^)(NSArray *, BOOL))initializer
                     createIfNeeded:(BOOL)createdIfNeed {
    return [context edo_jsValueWithObject:anObject
                              initializer:initializer
                           createIfNeeded:createdIfNeed];
}

- (NSArray<JSValue *> *)scriptObjectsWithObject:(NSObject *)anObject {
    NSMutableArray *results = [NSMutableArray array];
    for (EDOContextWrapper *contextWrapper in self.contexts) {
        JSContext *context = contextWrapper.context;
        if (context != nil) {
            JSValue *scriptObject = [self scriptObjectWithObject:anObject context:context initializer:nil createIfNeeded:NO];
            if (scriptObject != nil) {
                [results addObject:scriptObject];
            }
        }
    }
    return results.copy;
}

- (BOOL)checkExported:(Class)clazz exportedKey:(NSString *)exportedKey {
    Class cur = clazz;
    while (cur != NSObject.class && cur != NULL) {
        if ([self.exportedKeys containsObject:[NSString stringWithFormat:@"%@.%@", NSStringFromClass(cur), exportedKey]]) {
            if (cur != clazz) {
                NSMutableSet *exportedKeys = [self.exportedKeys mutableCopy] ?: [NSMutableSet set];
                [exportedKeys addObject:[NSString stringWithFormat:@"%@.%@", NSStringFromClass(cur), exportedKey]];
                self.exportedKeys = exportedKeys;
            }
            return YES;
        }
        cur = class_getSuperclass(cur);
    }
    return NO;
}

@end
