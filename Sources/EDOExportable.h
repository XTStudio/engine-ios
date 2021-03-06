//
//  EDOExportable.h
//  Endo-iOS
//
//  Created by PonyCui on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDOExporter.h"

@interface EDOExportable : NSObject

@property (nonatomic, assign) Class clazz;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *superName;
@property (nonatomic, copy) EDOInitializer initializer;
@property (nonatomic, copy) NSArray<NSString *> *exportedProps;
@property (nonatomic, copy) NSArray<NSString *> *readonlyProps;
@property (nonatomic, copy) NSArray<NSString *> *bindedMethods;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *exportedMethods;
@property (nonatomic, copy) NSArray<NSString *> *innerScripts;
@property (nonatomic, copy) NSArray<NSString *> *exportedScripts;

@end
