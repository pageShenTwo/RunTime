//
//  NSObject+PJKVO.m
//  RunTime
//
//  Created by JBT on 2018/4/17.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import "NSObject+PJKVO.h"
#import <objc/message.h>
#import "PJRuntime.h"

/**
    自定义KVO简单步骤:
    1.动态创建子类
    2.重写SET方法
    3.消息转发
 */

static NSString *const PJNewClassPrefix = @"PJKVOClassPrefix_";
static NSString *const PJAssociatedKey = @"PJAssociatedKey";

//PJNotifaceModel中间类   处理回调通知
@interface PJNotifaceModel : NSObject
@property (weak, nonatomic) NSObject *observe;
@property (strong, nonatomic) NSString *key;
@property (copy, nonatomic) PJKVOBlock block;

@end
@implementation PJNotifaceModel

- (instancetype)initWithObservice:(NSObject *)observice key:(NSString *)key block:(PJKVOBlock)block{
    if (self= [super init]) {
        _observe = observice;
        _key = key;
        _block = block;
    }
    return self;
}

@end


#pragma MARK - 分类自定义通知
@implementation NSObject (PJKVO)


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
// your override
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    // 指定转发的消息接受者为空
    return nil;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // 重写该方法为了防止crash方法的调用
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *message = NSStringFromSelector(aSelector);
    if ([message hasPrefix:@"_"]) {//对私用方法不收集崩溃日志
        return nil;
    }
    NSString *newMessage = [NSString stringWithFormat:@"[%@ %@] 未知的方法",NSStringFromClass([self class]),NSStringFromSelector(aSelector)];
    NSMethodSignature *sin = [[self class] instanceMethodSignatureForSelector:@selector(PJColloctMessageMethod:)];
    [self PJColloctMessageMethod:newMessage];
    return sin;
}

- (void)PJColloctMessageMethod:(NSString *)message{
    NSLog(@"%@",message);
}


#pragma clang diagnostic pop


//setterforgetter 根据Get方法生成set方法
static NSString *setterforgetter(NSString *getter){
    if (getter <= 0) {
        return nil;
    }
    NSString *firstLetter = [[getter substringToIndex:1] uppercaseString];
    NSString *otherLetter = [getter substringFromIndex:1];
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:",firstLetter,otherLetter];
    return setterName;
}
//getterforSetter 根据set方法生成get方法
static NSString *getterforSetter(NSString *setter){
    if (setter <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    NSRange range = NSMakeRange(3, setter.length - 4);
   NSString *key = [setter substringWithRange:range];
    NSString *firstString = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    return key;
}

// 实现子类的setter方法并进行消息转发
static void PJ_Setter (id self, SEL _cmd,id newValue){
   NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getName = getterforSetter(setterName);
    if (!getName) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ don^s have selector %@",self,getName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        return;
    }
    id oldValue = [self valueForKey:getName];
    struct objc_super superclazz = {
        .receiver = self, // 转发给谁
        .super_class = class_getSuperclass(object_getClass(self))// 父类
    };
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperCasted(&superclazz,_cmd,newValue); // 转发
    
    //PJNotifaceModel用来回调
    NSMutableArray *observices = objc_getAssociatedObject(self, (__bridge const void *)(PJAssociatedKey));
    for (PJNotifaceModel *model in observices) {
        if ([model.key isEqualToString:getName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                model.block(self, getName, oldValue, newValue);
            });
        }
    }
    
}

- (void)PJ_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(PJKVOBlock)block{
    SEL setterSel = NSSelectorFromString(setterforgetter(keyPath));
    Method setMothod = class_getInstanceMethod([self class], setterSel);
    if (!setMothod) {
        NSString *resion = [NSString stringWithFormat:@"Object %@ don^s have an selector for key%@",self,keyPath];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:resion userInfo:nil];
    }
    Class currentClass = object_getClass(self);
    NSString *className = NSStringFromClass(currentClass);
    if (![className hasPrefix:PJNewClassPrefix]) {
        // 动态创建类
        currentClass = [PJRuntime PJCreatClassWith:self className:className];
        // Swizing  黑魔法   改变isa指针
        object_setClass(self, currentClass);
    }
    
    // 判断有没有setter方法
    if (![self hasSetterSelector:setterSel]) {
        const char *types = method_getTypeEncoding(setMothod);
        class_addMethod(currentClass, setterSel, (IMP)PJ_Setter, types);
    }
    
    // 用来记录observice,key,和block回调
    PJNotifaceModel *model = [[PJNotifaceModel alloc] initWithObservice:observer key:keyPath block:block];
    NSMutableArray *observices = objc_getAssociatedObject(self, (__bridge const void *)(PJAssociatedKey));
    if (!observices) {
        observices = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *)(PJAssociatedKey), observices, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observices addObject:model];
}

- (void)PJ_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    NSMutableArray *observices = objc_getAssociatedObject(self, (__bridge const void *)(PJAssociatedKey));
    PJNotifaceModel *tempModel;
    // 移除observice
    for (PJNotifaceModel *model in observices) {
        if (model.observe == observer && [model.key isEqual:keyPath]) {
            tempModel = model;
            break;
        }
    }
    [observices removeObject:tempModel];
}
/**
    // 判断当前类有没有setter方法
        1.获取累的方法列表  ---->  class_copyMethodList
        2.根据方法获取方法编号(SEL) ----->method_getName
        3.判断编号是否相等 (SEL可以之间==判断是否相等)
 */
- (BOOL)hasSetterSelector:(SEL)selector{
    
    //得到当前类
    Class currentClass = object_getClass(self);
    unsigned int methondCount = 0;
    Method *methodList = class_copyMethodList(currentClass, &methondCount);
    for (int i = 0; i < methondCount; i++) {
        SEL thisSEL = method_getName(methodList[i]);
        if (thisSEL == selector) {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}
@end
