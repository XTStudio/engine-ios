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
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            self.responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        if (response != nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            self.status = [(NSHTTPURLResponse *)response statusCode];
        }
        dispatch_semaphore_signal(semaphore);
        if (self.async) {
            if (self.onloadend) {
                [self.onloadend callWithArguments:nil];
            }
        }
        self.onloadend = nil;
    }] resume];
    if (!self.async) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

@end
