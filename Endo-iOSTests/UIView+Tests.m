//
//  UIView+Tests.m
//  Endo-iOSTests
//
//  Created by PonyCui on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "UIView+Tests.h"
#import "EDOExporter.h"

@implementation UIView (Tests)

+ (void)load {
    EDO_EXPORT_CLASS(@"UIView", nil);
    EDO_EXPORT_PROPERTY(@"frame");
    EDO_EXPORT_PROPERTY(@"accessibilityHint");
    EDO_EXPORT_PROPERTY(@"alpha");
    [[EDOExporter sharedExporter] exportEnum:@"UIViewContentMode"
                                      values:@{
                                               @"top": @(UIViewContentModeTop),
                                               @"left": @(UIViewContentModeLeft),
                                               @"right": @(UIViewContentModeRight),
                                               @"bottom": @(UIViewContentModeBottom),
                                               }];
}

@end
