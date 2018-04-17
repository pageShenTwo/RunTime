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

static Class PJ_class (id self, SEL _cmd){
    return class_getSuperclass(object_getClass(self));
}

@end
