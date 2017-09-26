//
//  NSOperationVC.m
//  Multithreading
//
//  Created by 王涛 on 2017/9/26.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "NSOperationVC.h"
#import "WTOperation.h"
/**
 1. NSOperation简介
 
 NSOperation是苹果提供给我们的一套多线程解决方案。实际上NSOperation是基于GCD更高一层的封装，但是比GCD更简单易用、代码可读性也更高。
 
 NSOperation需要配合NSOperationQueue来实现多线程。因为默认情况下，NSOperation单独使用时系统同步执行操作，并没有开辟新线程的能力，只有配合NSOperationQueue才能实现异步执行。
 
 因为NSOperation是基于GCD的，那么使用起来也和GCD差不多，其中，NSOperation相当于GCD中的任务，而NSOperationQueue则相当于GCD中的队列。NSOperation实现多线程的使用步骤分为三步：
 
 创建任务：先将需要执行的操作封装到一个NSOperation对象中。
 创建队列：创建NSOperationQueue对象。
 将任务加入到队列中：然后将NSOperation对象添加到NSOperationQueue中。
 之后呢，系统就会自动将NSOperationQueue中的NSOperation取出来，在新线程中执行操作。

 */
@interface NSOperationVC ()

@end

@implementation NSOperationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NSOperation用法";
    //创建任务
    //[self creatTask];
    
    //创建队列
    //[self creatQueue];
    
    //控制串行执行和并行执行的关键
    [self maxConcurrentOperationCount];
    
    //操作依赖
    [self addDependency];
    
    //其他操作
    [self other];
}

/**
 1. 创建任务
 
 NSOperation是个抽象类，并不能封装任务。我们只有使用它的子类来封装任务。我们有三种方式来封装任务。
 
 使用子类NSInvocationOperation
 使用子类NSBlockOperation
 定义继承自NSOperation的子类，通过实现内部相应的方法来封装任务。
 在不使用NSOperationQueue，单独使用NSOperation的情况下系统同步执行操作，下面我们学习以下任务的三种创建方式。

 */
- (void)creatTask {
    //1.NSInvocationOperation,在没有使用NSOperationQueue、单独使用NSInvocationOperation的情况下，NSInvocationOperation在主线程执行操作，并没有开启新线程。
    NSInvocationOperation *invocationOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationFunc) object:nil];
    [invocationOp start];
    
    //2.NSBlockOperation,在没有使用NSOperationQueue、单独使用NSBlockOperation的情况下，NSBlockOperation也是在主线程执行操作，并没有开启新线程。
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        NSLog(@"NSBlockOperation %@", [NSThread currentThread]);
    }];
    [blockOp start];
    
    //但是，NSBlockOperation还提供了一个方法addExecutionBlock:，通过addExecutionBlock:就可以为NSBlockOperation添加额外的操作，这些额外的操作就会在其他线程并发执行。
    [self addExecutionBlock];
    
    //3.自定义NSOperation,在没有使用NSOperationQueue、单独使用自定义子类的情况下，是在主线程执行操作，并没有开启新线程。
    WTOperation *customOperation = [WTOperation new];
    [customOperation start];
}

/*
 2. 创建队列
 
 和GCD中的并发队列、串行队列略有不同的是：NSOperationQueue一共有两种队列：主队列、其他队列。其中其他队列同时包含了串行、并发功能。下边是主队列、其他队列的基本创建方法和特点。
 */
- (void)creatQueue {
    /*
     主队列:
     凡是添加到主队列中的任务（NSOperation），都会放到主线程中执行
     NSOperationQueue *queue = [NSOperationQueue mainQueue];
     
     其他队列（非主队列）:
     添加到这种队列中的任务（NSOperation），就会自动放到子线程中执行
     同时包含了：串行、并发功能
     NSOperationQueue *queue = [[NSOperationQueue alloc] init];
     */
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2. 创建操作
    // 创建NSInvocationOperation
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperationFunc) object:nil];
    // 创建NSBlockOperation
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"1-----%@", [NSThread currentThread]);
        }
    }];
    
    // 3. 添加操作到队列中：addOperation。NSInvocationOperation和NSOperationQueue结合后能够开启新线程，进行并发执行NSBlockOperation和NSOperationQueue也能够开启新线程，进行并发执行。
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    
    //NSOperationQueue还有一种更简易的方法添加任务
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; ++i) {
            NSLog(@"addOperationWithBlock %@", [NSThread currentThread]);
        }
    }];
    
}

- (void)maxConcurrentOperationCount {
    /*
     控制串行执行和并行执行的关键:
     之前我们说过，NSOperationQueue创建的其他队列同时具有串行、并发功能，上边我们演示了并发功能，那么他的串行功能是如何实现的？
     
     这里有个关键参数maxConcurrentOperationCount，叫做最大并发数。
     maxConcurrentOperationCount默认情况下为-1，表示不进行限制，默认为并发执行。
     当maxConcurrentOperationCount为1时，进行串行执行。
     当maxConcurrentOperationCount大于1时，进行并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整。
     */
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 设置最大并发操作数
    queue.maxConcurrentOperationCount = 3;
    //queue.maxConcurrentOperationCount = 1; // 就变成了串行队列
    
    // 添加操作
    [queue addOperationWithBlock:^{
        NSLog(@"1-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"2-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"3-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"4-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"5-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
    }];
    
    [queue addOperationWithBlock:^{
        NSLog(@"6-----%@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:1];
    }];
}

- (void)addDependency {
    //NSOperation和NSOperationQueue最吸引人的地方是它能添加操作之间的依赖关系。比如说有A、B两个操作，其中A执行完操作，B才能执行操作，那么就需要让B依赖于A。
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1-----%@", [NSThread  currentThread]);
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"2-----%@", [NSThread  currentThread]);
    }];
    
    [op2 addDependency:op1];    // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    [queue addOperation:op1];
    [queue addOperation:op2];
}

- (void)other {
    /*
     一些其他方法
     
     - (void)cancel; NSOperation提供的方法，可取消单个操作
     - (void)cancelAllOperations; NSOperationQueue提供的方法，可以取消队列的所有操作
     - (void)setSuspended:(BOOL)b; 可设置任务的暂停和恢复，YES代表暂停队列，NO代表恢复队列
     - (BOOL)isSuspended; 判断暂停状态
     */
}

#pragma mark - Tool

- (void)invocationOperationFunc {
    NSLog(@"NSInvocationOperation %@", [NSThread currentThread]);
}

- (void)addExecutionBlock {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        // 在主线程
        NSLog(@"1------%@", [NSThread currentThread]);
    }];
    
    // 添加额外的任务(在子线程执行)
    [op addExecutionBlock:^{
        NSLog(@"2------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"3------%@", [NSThread currentThread]);
    }];
    [op addExecutionBlock:^{
        NSLog(@"4------%@", [NSThread currentThread]);
    }];
    
    [op start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
