//
//  UIColor+EDOExporting.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/6.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "UIColor+EDOExporting.h"
#import "EDOExporter.h"

@implementation UIColor (EDOExporting)

+ (void)load {
    EDO_EXPORT_CLASS(@"UIColor", nil);
    EDO_EXPORT_INITIALIZER({
        if (arguments.count >= 4) {
            return [UIColor colorWithRed:[arguments[0] floatValue]
                                   green:[arguments[1] floatValue]
                                    blue:[arguments[2] floatValue]
                                   alpha:[arguments[3] floatValue]];
        }
        else {
            return [UIColor clearColor];
        }
    });
}

@end
