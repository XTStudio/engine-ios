//
//  ViewController.m
//  Endo-iOS
//
//  Created by 崔明辉 on 2018/6/5.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "EDOExporter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    static JSContext *ctx;
    ctx = [[JSContext alloc] init];
    [[EDOExporter sharedExporter] exportWithContext:ctx];
    [ctx evaluateScript:@"var s = new UIView; s.frame = {x: 100, y: 200, width: 30, height: 30};"];
}

@end
