//
//  PJRuntime.m
//  RunTime
//
//  Created by JBT on 2018/4/16.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import "PJRuntime.h"
#import <objc/message.h>

static NSString *const PJNewClassPrefix = @"PJKVOClassPrefix_";

@implementation PJRuntime

+ (void)PJ_ChangeMethodWith:(SEL)selector1 methodTwo:(SEL)selector2 class:(Class)class ClassOrInstance:(PJGetMethod)getMethod
{
    Method method,method1;
    if (getMethod == PJGetMethodClass) {
        method = class_getClassMethod(class, selector1);
        method1 = class_getClassMethod(class, selector2);
    }else{
        method = class_getInstanceMethod(class, selector1);
        method1 = class_getInstanceMethod(class, selector2);
    }
    method_exchangeImplementations(method, method1);
    
}

+ (Class)PJCreatClassWith:(id)selfClass className:(NSString *)className{
    Class newClass;
    
    NSString *newClassName = [PJNewClassPrefix stringByAppendingString:className];
    Class tempClass = NSClassFromString(newClassName);
    if (tempClass) {//是否已经有该了有直接返回没有创建
        return tempClass;
    }
    //得到当前类
    Class originClass = object_getClass(selfClass);
    newClass = objc_allocateClassPair(originClass, newClassName.UTF8String, 0);//创建
    Method tempMethod = class_getInstanceMethod(originClass, @selector(class));
    const char *types = method_getTypeEncoding(tempMethod);
    class_addMethod(newClass, @selector(class), (IMP)PJ_class, types);//添加class方法
    
    objc_registerClassPair(newClass);//注册
    return newClass;
}
// 动态创建类后添加的class方法
static Class PJ_class (id self, SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}

+ (NSMutableArray *)PJGetAllIvarFromClass:(NSString *)className{
    Class newClass = NSClassFromString(className);
    unsigned int ivarCount = 0;
    Ivar *ivar = class_copyIvarList(newClass, &ivarCount);
    NSMutableArray *ivarArr = [NSMutableArray array];
    for (int i = 0; i < ivarCount; i++) {
        Ivar ivarOne = ivar[i];
        const char *name = ivar_getName(ivarOne);
        NSString *Utf8String = [NSString stringWithUTF8String:name];
        [ivarArr addObject:Utf8String];
    }
    return ivarArr;
}
+ (NSMutableArray *)PJGetAllPrototyFromClass:(NSString *)className{
    Class NewClass = NSClassFromString(className);
    unsigned int prototyCount = 0;
   objc_property_t *prototy = class_copyPropertyList(NewClass, &prototyCount);
    NSMutableArray *proArray = [NSMutableArray array];
    for ( int i = 0; i <prototyCount; i++) {
        objc_property_t pro = prototy[i];
       const char *name = property_getName(pro);
        NSString *utf8String = [NSString stringWithUTF8String:name];
        [proArray addObject:utf8String];
    }
    return proArray;
}

@end
