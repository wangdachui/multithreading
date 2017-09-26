//
//  WTOperation.m
//  Multithreading
//
//  Created by 王涛 on 2017/9/26.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "WTOperation.h"

@implementation WTOperation

- (void)main {
    for (int i = 0; i < 2; ++i) {
        NSLog(@"1-----%@",[NSThread currentThread]);
    }
}

@end
