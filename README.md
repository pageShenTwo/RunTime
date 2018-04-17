# RunTime
可以利用文档就行动态创建类交换方法增加属性

PJ_ChangeMethodWith  交换方法 实现

(void)load { SEL sel1, sel2; sel1 = @selector(viewWillAppear:); sel2 = @selector(PJ_viewWillAppear:); // exchange method [PJRuntime PJ_ChangeMethodWith:sel1 methodTwo:sel2 class:[self class] ClassOrInstance:PJGetMethodInstance]; }
// PJCreatClassWith创建类,demo中自定义KVO用到 自定义KVO调用方式 PJPerson *p = [[PJPerson alloc] init];

[p PJ_addObserver:self forKeyPath:@"name" block:^(id self, NSString *keyPaht, id oldValue, id newValue) {
    NSLog(@"%@   %@    %@  %@",self, keyPaht, oldValue, newValue);
}];

p.name = @"PJ";

p.name = @"天王盖地虎";
