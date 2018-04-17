//
//  ViewController.m
//  RunTime
//
//  Created by JBT on 2018/4/16.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import "ViewController.h"
#import "PJPerson.h"
#import "NSObject+PJKVO.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self DefineKVOTest];// 自定义KVO调用方式
}
- (void)DefineKVOTest{
    PJPerson *p = [[PJPerson alloc] init];
    
    [p PJ_addObserver:self forKeyPath:@"name" block:^(id self, NSString *keyPaht, id oldValue, id newValue) {
        NSLog(@"%@   %@    %@  %@",self, keyPaht, oldValue, newValue);
    }];
    
    p.name = @"PJ";
    
    p.name = @"天王盖地虎";
}

// 不写也会进行方法调换
- (void)viewWillAppear:(BOOL)animated
{
    // 如果不添加[super viewWillAppear:animated];不会走交换的方法 添加后先打印PJ_viewWillAppear后打印test
    [super viewWillAppear:animated];
    NSLog(@"test");
}

@end
