//
//  NSObject+EDOObjectRef.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EDOObjectRef)

@property (nonatomic, strong) NSString *edo_objectRef;
@property (nonatomic, strong) NSSet *edo_listeningEvents;

- (void)edo_emitWithEventName:(nonnull NSString *)named arguments:(nullable NSArray *)arguments;
- (id)edo_valueWithEventName:(nonnull NSString *)named arguments:(nullable NSArray *)arguments;

@end
