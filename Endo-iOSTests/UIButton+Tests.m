//
//  UIButton+Tests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "UIButton+Tests.h"
#import "EDOExporter.h"

@implementation UIButton (Tests)

+ (void)load {
    EDO_EXPORT_CLASS(@"UIButton", @"UIView");
}

@end
