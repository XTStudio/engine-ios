//
//  FooObject.h
//  Endo-iOSTests
//
//  Created by 崔明辉 on 2018/6/27.
//  Copyright © 2018年 UED Center, YY Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FooObject : NSObject

@property (nonatomic, assign) CGFloat privateValue;
@property (nonatomic, assign) BOOL barCalled;
@property (nonatomic, assign) BOOL fooBarCalled;
@property (nonatomic, assign) BOOL fooBarArgumentsCalled;
@property (nonatomic, assign) BOOL fooBarArgumentsAliasCalled;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, assign) CGFloat edo_aFloat;
@property (nonatomic, copy) NSArray *arrProperty;
@property (nonatomic, copy) NSDictionary *dictProperty;
@property (nonatomic, assign) BOOL readonlyProperty;

- (void)bindingMethod;
- (void)bar;
- (void)edo_fooBar;
- (void)edo_fooBarWithString:(NSString *)aString andView:(UIView *)aView;
- (void)edo_fooBar:(NSString *)aString andView:(UIView *)aView;
- (void)methodWithCallback:(id (^)(NSArray *))callback;
- (void)structMethod:(CGRect)rect;
- (CGSize)privateMethod;

@end
