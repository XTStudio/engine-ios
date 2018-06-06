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
    [ctx evaluateScript:@"var s = new UIView; s.backgroundColor = new UIColor(1.0, 1.0, 0.0, 1.0); (function(){ var ss = new UIView; s.addSubview(ss); ss.backgroundColor = new UIColor(1.0, 0.0, 0.0, 1.0); ss.frame = {x: 100, y: 100, width: 44, height: 44}; ss.transform = {a: 1.0, b: 0.5, c: 0.0, d: 2.0, tx: 0.0, ty: 0.0} })() "];
    UIView *sView = [[EDOExporter sharedExporter] nsValueWithJSValue:[ctx objectForKeyedSubscript:@"s"]];
    [self.view addSubview:sView];
    [sView setFrame:CGRectMake(0, 0, 300, 300)];
}

@end
