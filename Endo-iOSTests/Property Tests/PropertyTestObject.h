//
//  PropertyTestObject.h
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/7/11.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FooObject.h"

@interface PropertyTestObject : NSObject

@property (nonatomic, assign) NSInteger intValue;
@property (nonatomic, assign) float floatValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, assign) CGRect rectValue;
@property (nonatomic, assign) CGSize sizeValue;
@property (nonatomic, assign) CGAffineTransform affineTransformValue;
@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) NSArray *arrayValue;
@property (nonatomic, strong) NSDictionary *dictValue;
@property (nonatomic, strong) id nilValue;
@property (nonatomic, strong) FooObject *objectValue;
@property (nonatomic, assign) NSInteger readonlyIntValue;

@end
