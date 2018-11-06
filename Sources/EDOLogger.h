//
//  UULog.h
//  UULog
//
//  Created by PonyCui on 2018/7/3.
//  Copyright © 2018年 XT Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol EDOLoggerExports<JSExport>

+ (void)verbose:(NSArray *)values;
+ (void)error:(NSArray *)values;
+ (void)warn:(NSArray *)values;
+ (void)info:(NSArray *)values;
+ (void)debug:(NSArray *)values;

@end

@interface EDOLogger : NSObject<EDOLoggerExports>

+ (void)attachToContext:(JSContext *)context;

@end
