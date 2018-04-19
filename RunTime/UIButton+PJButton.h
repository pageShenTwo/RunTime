//
//  UIButton+PJButton.h
//  RunTime
//
//  Created by JBT on 2018/4/18.
//  Copyright © 2018年 JBT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (PJButton)
/**
 *  为按钮添加点击间隔 eventTimeInterval秒
 */
@property (nonatomic, assign) NSTimeInterval eventTimeInterval;
@end
