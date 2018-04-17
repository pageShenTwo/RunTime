//
//  UIViewController+runtime.m
//  RunTime
//
//  Created by JBT on 2018/4/16.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import "UIViewController+runtime.h"
#import "PJRuntime.h"

@implementation UIViewController (runtime)
+ (void)load
{
    SEL sel1, sel2;
    sel1 = @selector(viewWillAppear:);
    sel2 = @selector(PJ_viewWillAppear:);
    // exchange method
    [PJRuntime PJ_ChangeMethodWith:sel1 methodTwo:sel2 class:[self class] ClassOrInstance:PJGetMethodInstance];
}

- (void)PJ_viewWillAppear:(BOOL)animated{
    [self PJ_viewWillAppear:animated];
    NSLog(@"change Method Imp  %s",__FUNCTION__);
}

@end
