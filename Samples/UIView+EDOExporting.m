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
    EDO_BIND_METHOD(layoutSubviews);
    EDO_EXPORT_METHOD(removeFromSuperview);
    EDO_EXPORT_METHOD(addSubview:);
}

@end
