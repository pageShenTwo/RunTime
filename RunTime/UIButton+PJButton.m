//
//  UIButton+PJButton.m
//  RunTime
//
//  Created by JBT on 2018/4/18.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import "UIButton+PJButton.h"
#import <objc/message.h>
#define  defauleTimeJG 1

@interface UIButton ()

// yes 不能重复点击  No可以
@property (assign, nonatomic) BOOL isNoAndYes;

@end


@implementation UIButton (PJButton)

static char *const yesOrno = "yesOrno";
static char *const defauleJG = "defauleJG";


- (NSTimeInterval)eventTimeInterval{
    return  [objc_getAssociatedObject([self class], defauleJG) doubleValue];
}
- (void)setEventTimeInterval:(NSTimeInterval)eventTimeInterval{
    objc_setAssociatedObject([self class], defauleJG, @(eventTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isNoAndYes{
    return [objc_getAssociatedObject([self class], yesOrno) boolValue];
}
- (void)setIsNoAndYes:(BOOL)isNoAndYes
{
    objc_setAssociatedObject([self class], yesOrno, @(isNoAndYes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA,selB;
        selA = @selector(sendAction:to:forEvent:);
        selB = @selector(PJ_sendAction:to:forEvent:);
        Method methodA = class_getInstanceMethod([self class], selA);
        Method methodB = class_getInstanceMethod([self class], selB);
       BOOL isADD = class_addMethod([self class], selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        
        if (isADD) {
            class_replaceMethod([self class], selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            method_exchangeImplementations(methodA, methodB);
        }
    });
}
- (void)PJ_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    self.eventTimeInterval = self.eventTimeInterval == 0?defauleTimeJG:self.eventTimeInterval;
    if (self.isNoAndYes) {
        return;
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.eventTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setIsNoAndYes:NO];
        });
    }
    self.isNoAndYes = YES;
    [self PJ_sendAction:action to:target forEvent:event];
    
}

@end
