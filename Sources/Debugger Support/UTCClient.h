//
//  UTClient.h
//  URLTalk-Client
//
//  Created by PonyCui on 2019/1/30.
//  Copyright © 2019年 XT Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

enum {
    UTCFrameTypeURLRequest = 100,
    UTCFrameTypeURLResponse = 101,
};

typedef struct _UTCDataFrame {
    uint32_t length;
    uint8_t data[0];
} UTCDataFrame;

typedef void(^UTCRequestCallback)(NSData *data, NSHTTPURLResponse *response, NSError *error);

@interface UTCClient : NSObject

+ (UTCClient *)sharedClient;

- (void)sendRequest:(NSURLRequest *)request
    completionBlock:(UTCRequestCallback)completionBlock;

@end

NS_ASSUME_NONNULL_END
