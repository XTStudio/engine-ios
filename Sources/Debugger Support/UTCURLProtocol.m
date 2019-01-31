//
//  UTURLProtocol.m
//  URLTalk-Client
//
//  Created by PonyCui on 2019/1/30.
//  Copyright © 2019年 XT Studio. All rights reserved.
//

#import "UTCURLProtocol.h"
#import "UTCClient.h"

static NSArray *targets;

@implementation UTCURLProtocol

+ (void)load {
#if !TARGET_IPHONE_SIMULATOR
    [NSURLProtocol registerClass:[self class]];
#endif
}

+ (void)addTarget:(NSString *)target {
    NSMutableArray *t = [targets mutableCopy] ?: [NSMutableArray array];
    [t addObject:target];
    targets = [t copy];
}

+ (void)addExpressionTarget:(NSRegularExpression *)expressionTarget {
    NSMutableArray *t = [targets mutableCopy] ?: [NSMutableArray array];
    [t addObject:expressionTarget];
    targets = [t copy];
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    NSString *URLString = task.originalRequest.URL.absoluteString;
    for (id target in targets) {
        if ([target isKindOfClass:[NSString class]]) {
            if ([URLString hasPrefix:target]) {
                return YES;
            }
        }
        else if ([target isKindOfClass:[NSRegularExpression class]]) {
            if ([target matchesInString:URLString options:NSMatchingReportCompletion range:NSMakeRange(0, URLString.length)].count > 0) {
                return YES;
            }
        }
    }
    return NO;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *URLString = request.URL.absoluteString;
    for (id target in targets) {
        if ([target isKindOfClass:[NSString class]]) {
            if ([URLString hasPrefix:target]) {
                return YES;
            }
        }
        else if ([target isKindOfClass:[NSRegularExpression class]]) {
            if ([target matchesInString:URLString options:NSMatchingReportCompletion range:NSMakeRange(0, URLString.length)].count > 0) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    [[UTCClient sharedClient] sendRequest:self.request
                         completionBlock:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) {
                             if (response != nil) {
                                 [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                             }
                             if (data != nil) {
                                 [self.client URLProtocol:self
                                              didLoadData:data];
                             }
                             if (error != nil) {
                                 [self.client URLProtocol:self
                                         didFailWithError:error];
                             }
                             [self.client URLProtocolDidFinishLoading:self];
                         }];
}

- (void)stopLoading {
    
}

@end
