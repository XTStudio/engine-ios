//
//  XTSHttpRequest.h
//  ooo
//
//  Created by PonyCui on 2019/1/25.
//  Copyright © 2019年 Pony Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

//mockRequest.open("POST", "http://" + this.serverAddress + "/" + event)
//mockRequest.setRequestHeader("device-uuid", this.deviceUUID)
//mockRequest.send(JSON.stringify(params))
//if (mockRequest.status === 200) {
//    return JSON.parse(mockRequest.responseText)
//}

@class XTSHttpRequest;

@protocol XTSHttpRequestExport <JSExport>

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy, nullable) NSString *responseText;
@property (nonatomic, strong, nullable) JSValue *onloadend;

JSExportAs(open, - (void)open:(NSString *)method url:(NSString *)url async:(BOOL)async);
JSExportAs(setRequestHeader, - (void)setRequestHeader:(NSString *)aKey aValue:(NSString *)aValue);
- (void)send:(NSString *)data;

@end

@interface XTSHttpRequest : NSObject<XTSHttpRequestExport>

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy, nullable) NSString *responseText;
@property (nonatomic, strong, nullable) JSValue *onloadend;

+ (void)attachToContext:(JSContext *)context;

@end

NS_ASSUME_NONNULL_END
