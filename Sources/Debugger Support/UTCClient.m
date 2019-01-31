//
//  UTClient.m
//  URLTalk-Client
//
//  Created by PonyCui on 2019/1/30.
//  Copyright © 2019年 XT Studio. All rights reserved.
//

#import "UTCClient.h"
#import "UTCPTChannel.h"
#import "UTCPTProtocol.h"
#import "UTCURLProtocol.h"

@interface UTCClient ()<UTCPTChannelDelegate>

@property (nonatomic, strong) UTCPTChannel *serverChannel;
@property (nonatomic, strong) UTCPTChannel *peerChannel;
@property (atomic, strong) NSMutableDictionary<NSString *, NSURLRequest *> *requests;
@property (atomic, strong) NSMutableDictionary<NSString *, UTCRequestCallback> *callbacks;
@property (atomic, strong) NSMutableArray<NSString *> *requestQueue;

@end

@implementation UTCClient

+ (void)load {
    [[UTCClient sharedClient] startService];
    [UTCURLProtocol addTarget:@"http://127.0.0.1:8090"];
    [UTCURLProtocol addTarget:@"http://127.0.0.1:8091"];
}

+ (UTCClient *)sharedClient {
    static UTCClient *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UTCClient alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requests = [NSMutableDictionary dictionary];
        _callbacks = [NSMutableDictionary dictionary];
        _requestQueue = [NSMutableArray array];
    }
    return self;
}

- (void)startService {
#if !TARGET_IPHONE_SIMULATOR
    [self connect];
#endif
}

- (void)connect {
    UTCPTChannel *channel = [UTCPTChannel channelWithDelegate:self];
    [channel listenOnPort:60410
              IPv4Address:INADDR_LOOPBACK
                 callback:^(NSError *error) {
                     if (error) {
                         NSLog(@"%@", [NSString stringWithFormat:@"Failed to listen on 127.0.0.1:%ld: %@", (long)60410, error]);
                         
                     } else {
                         NSLog(@"%@", [NSString stringWithFormat:@"Listening on 127.0.0.1:%ld", (long)60410]);
                         self.serverChannel = channel;
                     }
                 }];
}

- (void)sendRequest:(NSURLRequest *)request
    completionBlock:(void (^)(NSData * _Nonnull, NSHTTPURLResponse * _Nonnull, NSError * _Nonnull))completionBlock {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    self.requests[uuid] = request;
    self.callbacks[uuid] = [completionBlock copy];
    [self.requestQueue addObject:uuid];
    [self dispose];
}

- (void)dispose {
    if (self.peerChannel) {
        for (NSString *uuid in self.requestQueue.copy) {
            NSURLRequest *request = self.requests[uuid];
            if (request != nil) {
                [self.peerChannel sendFrameOfType:UTCFrameTypeURLRequest
                                              tag:UTCPTFrameNoTag
                                      withPayload:[self buildRequest:request
                                                                uuid:uuid]
                                         callback:^(NSError *error) { }];
            }
        }
        [self.requestQueue removeAllObjects];
    }
}

#pragma mark - UTCPTChannelDelegate

- (void)ioFrameChannel:(UTCPTChannel *)channel didAcceptConnection:(UTCPTChannel *)otherChannel fromAddress:(UTCPTAddress *)address {
    self.peerChannel = otherChannel;
}

- (void)ioFrameChannel:(UTCPTChannel *)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(UTCPTData *)payload {
    if (type == UTCFrameTypeURLResponse) {
        NSData *data = [NSData utcpt_dataWithContentsOfDispatchData:payload.dispatchData];
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:kNilOptions
                                                                        error:NULL];
        NSString *uuid = responseObject[@"uuid"];
        if (uuid == nil && ![responseObject isKindOfClass:[NSDictionary class]]) {
            return;
        }
        [self sendCallback:uuid responseObject:responseObject];
    }
}

- (void)ioFrameChannel:(UTCPTChannel *)channel didEndWithError:(NSError *)error {
    self.peerChannel = nil;
}

- (dispatch_data_t)buildRequest:(NSURLRequest *)request
                           uuid:(NSString *)uuid {
    NSMutableDictionary *responseObject = [NSMutableDictionary dictionary];
    responseObject[@"uuid"] = uuid;
    responseObject[@"URLString"] = request.URL.absoluteString ?: @"";
    responseObject[@"cachePolicy"] = @(request.cachePolicy);
    responseObject[@"timeout"] = @(request.timeoutInterval);
    responseObject[@"HTTPMethod"] = request.HTTPMethod ?: @"GET";
    responseObject[@"headers"] = request.allHTTPHeaderFields ?: @{};
    if (request.HTTPBody != nil) {
        responseObject[@"HTTPBody"] = [request.HTTPBody base64EncodedStringWithOptions:kNilOptions];
    }
    NSData *finalData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                        options:kNilOptions
                                                          error:NULL];
    return [finalData utcpt_createReferencingDispatchData];
}

- (void)sendCallback:(NSString *)uuid
      responseObject:(NSDictionary *)responseObject {
    NSData *data;
    NSHTTPURLResponse *response;
    NSError *error;
    if (responseObject[@"data"] != nil) {
        data = [[NSData alloc] initWithBase64EncodedString:responseObject[@"data"] options:kNilOptions];
    }
    if (responseObject[@"URLString"] != nil) {
        response = [[NSHTTPURLResponse alloc]
                    initWithURL:[NSURL URLWithString:responseObject[@"URLString"]]
                    statusCode:[responseObject[@"statusCode"] integerValue]
                    HTTPVersion:nil
                    headerFields:responseObject[@"headers"]];
    }
    if (responseObject[@"error.code"] != nil) {
        error = [NSError errorWithDomain:responseObject[@"error.domain"]
                                    code:[responseObject[@"error.code"] integerValue]
                                userInfo:nil];
    }
    UTCRequestCallback callback = self.callbacks[uuid];
    if (callback != nil) {
        callback(data, response, error);
    }
}

- (void)setPeerChannel:(UTCPTChannel *)peerChannel {
    if (_peerChannel != nil) {
        [_peerChannel close];
    }
    _peerChannel = peerChannel;
    [self dispose];
}

@end
