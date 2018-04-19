//
//  PJPerson.h
//  RunTime
//
//  Created by JBT on 2018/4/17.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJPerson : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *age;
@property (copy, nonatomic) NSString *height;
@property (copy, nonatomic) NSString *weight;

- (void)eat;

@end
