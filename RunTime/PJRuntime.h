//
//  PJRuntime.h
//  RunTime
//
//  Created by JBT on 2018/4/16.
//  Copyright © 2018年 JBT. All rights reserved.
//

/**
 
 runtime 的方法汇总以及简单使用
 
 */


#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger,PJGetMethod) {
    PJGetMethodClass = 0,// Class method
    PJGetMethodInstance // Instance method
};

@interface PJRuntime : NSObject

/**
 Runtime dynamic exchange method.
 
 For example, in each controller viewwillApear, the same function is implemented to write a taxonomy for UIVIewCOntroller, and then the method exchange in the +load method.

 @param selector1 and  selector2    (@selector())  get
 @param class ===  The method of exchange belongs to which class.
 @param getMethod === You want to swap the class method or the instance method.
 */
+ (void)PJ_ChangeMethodWith:(SEL)selector1 methodTwo:(SEL)selector2 class:(Class)class ClassOrInstance:(PJGetMethod)getMethod;

/**
 动态创建类

 @param selfClass 传过来的self
 @param className 类名
 @return 返回一个类
 */
+ (Class)PJCreatClassWith:(id)selfClass className:(NSString *)className;

@end
