//
//  XTSHttpRequest.m
//  ooo
//
//  Created by PonyCui on 2019/1/25.
//  Copyright © 2019年 Pony Cui. All rights reserved.
//

#import "XTSHttpRequest.h"

@interface XTSHttpRequest ()

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) BOOL async;

@end

@implementation XTSHttpRequest

+ (void)attachToContext:(JSContext *)context {
    context[@"_XTSHttpRequest"] = [XTSHttpRequest class];
    context[@"XTSHttpRequest"] = ^{
        return [XTSHttpRequest new];
    };
}

- (void)open:(NSString *)method url:(NSString *)url async:(BOOL)async {
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                       timeoutInterval:60];
    self.request.HTTPMethod = method;
    self.async = async;
}

- (void)setRequestHeader:(NSString *)aKey aValue:(NSString *)aValue {
    [self.request setValue:aValue forHTTPHeaderField:aKey];
}

- (void)send:(NSString *)data {
    self.request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    if (!self.async) {
        NSURLResponse *response;
        NSError *error;
        NSData *syncData = [NSURLConnection sendSynchronousRequest:self.request
                                                 returningResponse:&response
                                                             error:&error];
        if (syncData != nil) {
            self.responseText = [[NSString alloc] initWithData:syncData encoding:NSUTF8StringEncoding];
        }
        if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            self.status = [(NSHTTPURLResponse *)response statusCode];
        }
        self.onloadend = nil;
    }
    else {
        [NSURLConnection sendAsynchronousRequest:self.request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (data != nil) {
                self.responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                self.status = [(NSHTTPURLResponse *)response statusCode];
            }
            if (self.onloadend) {
                [self.onloadend callWithArguments:nil];
            }
            self.onloadend = nil;
        }];
    }
}

@end
