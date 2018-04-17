//
//  NSObject+PJKVO.h
//  RunTime
//
//  Created by JBT on 2018/4/17.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^PJKVOBlock) (id self, NSString *keyPaht, id oldValue, id newValue);

@interface NSObject (PJKVO)
- (void)PJ_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath block:(PJKVOBlock)block;
- (void)PJ_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
