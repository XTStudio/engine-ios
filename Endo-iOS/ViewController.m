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
    [ctx setExceptionHandler:^(JSContext *context, JSValue *exception) {
        NSLog(@"%@", exception);
    }];
    [[EDOExporter sharedExporter] exportWithContext:ctx];
    [ctx evaluateScript:@"var s = new UIView; s.backgroundColor = new UIColor(1.0, 1.0, 0.0, 1.0); var slider = new UISlider(); slider.value = 0.5; slider.frame = {x:100,y:100,width:200,height:36}; s.addSubview(slider); s.on('ttt', function(){ emitted() }); s.sss(function(){}, UIViewContentMode.scaleAspectFill); "];
    UIView *sView = [[EDOExporter sharedExporter] nsValueWithJSValue:[ctx objectForKeyedSubscript:@"s"]];
    [self.view addSubview:sView];
    [sView setFrame:CGRectMake(0, 0, 300, 300)];
}

@end
