//
//  UIView+EDOExporting.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "UIView+EDOExporting.h"
#import "EDOExporter.h"
#import <Aspects/Aspects.h>

@implementation UIView (EDOExporting)

+ (void)load {
    EDO_EXPORT_CLASS(@"UIView");
    EDO_EXPORT_INITIALIZER({
        return [[UIView alloc] initWithFrame:CGRectZero];
    });
    EDO_EXPORT_PROPERTY(@"frame");
    EDO_EXPORT_PROPERTY(@"center");
    EDO_EXPORT_PROPERTY(@"intrinsicContentSize");
    EDO_EXPORT_PROPERTY(@"alpha");
    EDO_EXPORT_PROPERTY(@"transform");
    EDO_EXPORT_PROPERTY(@"layoutMargins");
    EDO_EXPORT_PROPERTY(@"userInteractionEnabled");
    EDO_EXPORT_PROPERTY(@"superview");
    EDO_EXPORT_PROPERTY(@"subviews");
    EDO_EXPORT_PROPERTY(@"backgroundColor");
    EDO_BIND_METHOD(layoutSubviews);
    EDO_EXPORT_METHOD(removeFromSuperview);
    EDO_EXPORT_METHOD(addSubview:);
    [self aspect_hookSelector:@selector(didAddSubview:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIView *subview) {
        EDO_RETAIN(subview);
    } error:NULL];
    [self aspect_hookSelector:@selector(willRemoveSubview:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIView *subview) {
        EDO_RELEASE(subview);
    } error:NULL];
}

@end
