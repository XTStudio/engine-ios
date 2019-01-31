//
//  UTURLProtocol.h
//  URLTalk-Client
//
//  Created by PonyCui on 2019/1/30.
//  Copyright © 2019年 XT Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UTCURLProtocol : NSURLProtocol

+ (void)addTarget:(NSString *)target;
+ (void)addExpressionTarget:(NSRegularExpression *)expressionTarget;

@end

NS_ASSUME_NONNULL_END
