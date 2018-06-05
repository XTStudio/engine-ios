//
//  EDOExportable.h
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDOExporter.h"

@interface EDOExportable : NSObject

@property (nonatomic, assign) Class clazz;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) EDOInitializer initializer;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *props;

@end
