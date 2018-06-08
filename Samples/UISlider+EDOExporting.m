//
//  UISlider+EDOExporting.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/8.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "UISlider+EDOExporting.h"
#import "EDOExporter.h"

@implementation UISlider (EDOExporting)

+ (void)load {
    EDO_EXPORT_CLASS(@"UISlider", @"UIView");
    EDO_EXPORT_PROPERTY(@"value")
}

@end
