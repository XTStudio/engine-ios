//
//  UIView+EDOExporting.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "UIView+EDOExporting.h"
#import "EDOExporter.h"

@implementation UIView (EDOExporting)

+ (void)load {
    [[EDOExporter sharedExporter] exportClass:[self class] name:@"UIView"];
    [[EDOExporter sharedExporter] exportInitializer:[self class] initializer:^id(NSArray *arguments) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }];
    [[EDOExporter sharedExporter] exportProperty:[self class] propName:@"alpha" propType:EDOPropTypeNumber];
    [[EDOExporter sharedExporter] exportProperty:[self class] propName:@"userInteractionEnabled" propType:EDOPropTypeBoolean];
    [[EDOExporter sharedExporter] exportStructProperty:[self class] propName:@"center" structType:EDOStructTypeCGPoint];
}

@end
