//
//  ViewController.m
//  RunTime
//
//  Created by JBT on 2018/4/16.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import "ViewController.h"
#import "PJPerson.h"
#import "PJRuntime.h"
#import "NSObject+PJKVO.h"
#import "UIButton+PJButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self DefineKVOTest];// 自定义KVO调用方式
//    [self getAllIvarList];// 获取所有的Ivar列表
//    [self getAllProrotyList];// 获取所有的Proroty列表
    
    UIButton *ben = [UIButton buttonWithType:UIButtonTypeCustom];
    ben.frame = CGRectMake(100, 100, 100, 100);
    [ben addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    ben.eventTimeInterval = 10;
    [ben setTitle:@"sfag" forState:UIControlStateNormal];
    [ben setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:ben];
    
}

- (void)change{
    NSLog(@"%@",[NSDate new]);
}

- (void)getAllProrotyList{
    NSMutableArray *array = [PJRuntime PJGetAllPrototyFromClass:@"PJPerson"];
    NSLog(@"PrototyList ======== %@",array);
}

- (void)getAllIvarList{
    NSMutableArray *array = [PJRuntime PJGetAllIvarFromClass:@"PJPerson"];
    NSLog(@"IvarList ======== %@",array);
}

- (void)DefineKVOTest{
    PJPerson *p = [[PJPerson alloc] init];
    
    [p PJ_addObserver:self forKeyPath:@"name" block:^(id self, NSString *keyPaht, id oldValue, id newValue) {
        NSLog(@"%@   %@    %@  %@",self, keyPaht, oldValue, newValue);
    }];
    
    p.name = @"PJ";
    
    p.name = @"天王盖地虎";
    [p eat];
}

// 不写也会进行方法调换
- (void)viewWillAppear:(BOOL)animated
{
    // 如果不添加[super viewWillAppear:animated];不会走交换的方法 添加后先打印PJ_viewWillAppear后打印test
    [super viewWillAppear:animated];
    NSLog(@"test");
}

@end
