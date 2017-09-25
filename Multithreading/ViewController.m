//
//  ViewController.m
//  Multithreading
//
//  Created by 王涛 on 2017/9/14.
//  Copyright © 2017年 王涛. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self concurrentQueueDemo];
//    [self serialQueueDemo];
//    [self semaphoreDemo];
//    [self dispatchBarrierDemo];
    //[self dispatchApplyDemo];
    
    // obj-C 正确示范，最常用的 GCD
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (int index = 0; index < 10; ++index) {
//            sleep(1);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"index - %d", index);
//                NSLog(@"更新UI");
//            });
//        }
//    });

    //关于同步异步，串行，并行的思考
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t serialQueue = dispatch_queue_create("test.Lision.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("test.Lision.MyCustomQueue", DISPATCH_QUEUE_CONCURRENT);
    
    [self dispatchAsyncWith:mainQueue];
    /* 打印结果
     2017-09-20 19:25:40.815678+0800 Multithreading[34153:2558588] 任务C
     当前线程：<NSThread: 0x604000077440>{number = 1, name = main}
     2017-09-20 19:25:42.843920+0800 Multithreading[34153:2558588] 任务A
     当前线程：<NSThread: 0x604000077440>{number = 1, name = main}
     2017-09-20 19:25:44.845176+0800 Multithreading[34153:2558588] 任务B
     当前线程：<NSThread: 0x604000077440>{number = 1, name = main}
     */
    
    //[self dispatchAsyncWith:globalQueue];
    /* 打印结果：A/B的顺序随机
     2017-09-20 19:28:26.395395+0800 Multithreading[34347:2580292] 任务C
     当前线程：<NSThread: 0x60400006dc80>{number = 1, name = main}
     2017-09-20 19:28:28.397384+0800 Multithreading[34347:2580443] 任务B
     当前线程：<NSThread: 0x604000275ac0>{number = 3, name = (null)}
     2017-09-20 19:28:28.397384+0800 Multithreading[34347:2580446] 任务A
     当前线程：<NSThread: 0x60c00007c680>{number = 4, name = (null)}
     */
    
    //[self dispatchAsyncWith:serialQueue];
    /* 打印结果：串行队列生成一个新线程，AB顺序执行
     2017-09-20 19:29:45.542392+0800 Multithreading[34394:2585219] 任务C
     当前线程：<NSThread: 0x60000007f880>{number = 1, name = main}
     2017-09-20 19:29:47.547666+0800 Multithreading[34394:2585681] 任务A
     当前线程：<NSThread: 0x604000277540>{number = 3, name = (null)}
     2017-09-20 19:29:49.550736+0800 Multithreading[34394:2585681] 任务B
     当前线程：<NSThread: 0x604000277540>{number = 3, name = (null)}
     */
    
    //[self dispatchAsyncWith:concurrentQueue];
    /* 打印结果 A/B的顺序随机，AB并行执行，生成两个线程，最多生成几个线程由系统决定
     2017-09-20 19:30:56.998360+0800 Multithreading[34446:2593417] 任务C
     当前线程：<NSThread: 0x60400006ba40>{number = 1, name = main}
     2017-09-20 19:30:59.001208+0800 Multithreading[34446:2593777] 任务B
     当前线程：<NSThread: 0x608000275ac0>{number = 3, name = (null)}
     2017-09-20 19:30:59.001206+0800 Multithreading[34446:2593775] 任务A
     当前线程：<NSThread: 0x60400007ae40>{number = 4, name = (null)}
     */

    //[self dispatchSyncWith:mainQueue];//死锁
    /*
     死锁原因：我们要在主线程同步执行任务A，但是同步执行任务A也算一个任务，我们称呼它为W。mainQueue是顺序执行的，当前正在执行的任务是W，W的内容是要执行A，所以把A加到mainQueue的尾部等待执行。A要执行，必须等W完成，W要完成，必须要执行A，相互等待，进入死锁。
     所以，同步的时候，不能将任务添加到当前线程的串行Queue中
     */
    //[self dispatchSyncWith:globalQueue];
    /* 打印结果 同步阻塞，顺序执行ABC
     2017-09-20 19:59:25.961727+0800 Multithreading[34773:2655128] 任务A
     当前线程：<NSThread: 0x60c000261bc0>{number = 1, name = main}
     2017-09-20 19:59:27.962571+0800 Multithreading[34773:2655128] 任务B
     当前线程：<NSThread: 0x60c000261bc0>{number = 1, name = main}
     2017-09-20 19:59:27.962824+0800 Multithreading[34773:2655128] 任务C
     当前线程：<NSThread: 0x60c000261bc0>{number = 1, name = main}
     */
//    [self dispatchSyncWith:serialQueue];
    /*
     自己猜
     */
//    [self dispatchSyncWith:concurrentQueue];
    /*
     自己猜
     */
}

//异步调用各种Queue
- (void)dispatchAsyncWith:(dispatch_queue_t)queue {
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务A\n当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务B\n当前线程：%@",[NSThread currentThread]);
    });
    NSLog(@"任务C\n当前线程：%@",[NSThread currentThread]);
}

//同步调用各种Queue
- (void)dispatchSyncWith:(dispatch_queue_t)queue {
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"任务A\n当前线程：%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"任务B\n当前线程：%@",[NSThread currentThread]);
    });
    NSLog(@"任务C\n当前线程：%@",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Dispatch Queue

- (void)serialQueueDemo {
    // 自定义串行队列,将任务ABC加到串行队列中，顺序执行
    dispatch_queue_t customSerialQueue = dispatch_queue_create("test.wangdachui.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(customSerialQueue, ^{
        NSLog(@"customSerialQueue-A");
    });
    dispatch_async(customSerialQueue, ^{
        NSLog(@"customSerialQueue-B");
    });
    dispatch_async(customSerialQueue, ^{
        NSLog(@"customSerialQueue-C");
    });
    // 由于上面是异步执行操作，所以很难知道下面的打印和上面异步操作中的打印谁先谁后
    NSLog(@"customSerialQueue-D");
    
    //多个串行队列并行执行，系统对于一个serialQueue就只生成并使用一个线程。如果生成2000个serialQueue，那么就生成2000个线程
    dispatch_queue_t customSerialQueue1 = dispatch_queue_create("test.wangdachui.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t customSerialQueue2 = dispatch_queue_create("test.wangdachui.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t customSerialQueue3 = dispatch_queue_create("test.wangdachui.MyCustomQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(customSerialQueue1, ^{
        NSLog(@"customSerialQueue1-A");
    });
    dispatch_async(customSerialQueue2, ^{
        NSLog(@"customSerialQueue2-B");
    });
    dispatch_async(customSerialQueue3, ^{
        NSLog(@"customSerialQueue3-C");
    });
    //注意：过多使用多线程，就会消耗大量内存问题，引起大量的上下文切换，大幅度降低系统的响应性能
}

- (void)concurrentQueueDemo {
    // 自定义并行队列,将任务1234567加到串行队列中
    dispatch_queue_t customConcurrentQueue = dispatch_queue_create("test.wangdachui.MyCustomQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk0");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk1");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk2");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk3");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk4");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk5");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    dispatch_async(customConcurrentQueue, ^{
        NSLog(@"blk6");
        NSLog(@"当前线程：%@",[NSThread currentThread]);
    });
    
    /*
     iOS和OS X的核心--XNU内核决定应当使用的线程数，并只生成所需的线程执行处理。另外，当处理结束，应当执行的处理数减少时，XNU内核会结束不再需要的线程。XNU内核仅使用Concurrent Dispatch Queue便可以完美地管理并行执行多个处理的线程。
     假设准备4个Concurrent Dispatch Queue 用线程。首先blk0在线程0中开始执行，接着blk1在线程1中、blk2在线程2中、blk3在线程3中开始执行。线程0中blk0执行结束后开始执行blk4，由于线程1中blk1的执行没有结束，因此线程2中blk2执行结束后开始执行blk5，就这样循环往复。
     像这样在Concurrent Dispatch Queue中执行处理时，执行顺序会根据处理内容和系统状态发生改变。
     为了说明线程分配原理，这里假设线程数为4，实测iOS11线程数可达20个，所以想测试的同学，在并发队列中必须追加20个以上的任务
     对于Concurrent Dispatch Queue来说，不管生成多少，由于XNU内核只使用有效管理的线程，因此不会发生串行队列的那些问题（过多使用多线程，降低系统的响应性能）
     */
}

#pragma mark - Dispatch Group

- (void)dispatchGroupDemo {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    // 把 queue 加入到 group
    dispatch_group_async(group, queue, ^{
        // 一些异步操作任务
        sleep(2);
        NSLog(@"任务GroupA\n当前线程：%@",[NSThread currentThread]);
    });
    // code 你可以在这里写代码做一些不必等待 group 内任务的操作
    NSLog(@"任务GroupB\n当前线程：%@",[NSThread currentThread]);
    // 当你在 group 的任务没有完成的情况下不能做更多的事时，阻塞当前线程等待 group 完工
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"任务GroupC\n当前线程：%@",[NSThread currentThread]);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        // 从主线程上执行 UI 界面更新
        NSLog(@"任务GroupD\n当前线程：%@",[NSThread currentThread]);
    });
}

#pragma mark - dispatch_barrier_async

- (void)dispatchBarrierDemo {
    /*
     在访问数据库或文件时，为了高效地进行访问，读取处理追加到Concurrent Dispatch Queue中，写入处理在任一读取处理没有执行的状态下，追加到Serial Dispatch Queue中即可（在写入处理结束之前，读取处理不可执行）
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"blk0_for_reading");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk1_for_reading");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk2_for_writing");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk3_for_reading");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk4_for_reading");
    });
    /*如上，如果简单地在dispatch_async函数中加入写入处理，那么根据Concurrent Dispatch Queue的性质，就有可能在追加到写入处理前面的处理中读取到与期待不符的数据，还可能因非法访问导致应用程序异常结束。因此我们要使用dispatch_barrier_async函数。dispatch_barrier_async函数会等待追加到Concurrent Dispatch Queue上的并行执行的处理全部结束之后，再将指定的处理追加到该Concurrent Dispatch Queue中。然后在由dispatch_barrier_async函数追加的处理执行完毕后，Concurrent Dispatch Queue才恢复为一般的动作，追加到该Concurrent Dispatch Queue的处理又开始执行。*/
    dispatch_async(queue, ^{
        NSLog(@"blk0_for_reading");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk1_for_reading");
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"blk2_for_writing");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk3_for_reading");
    });
    dispatch_async(queue, ^{
        NSLog(@"blk4_for_reading");
    });
}

#pragma mark - 信号量

- (void)semaphoreDemo {
    // 创建信号量，并且设置值为10
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 100; i++)
    {   // 由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10次后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(queue, ^{
            NSLog(@"信号量-index=%i",i);
            NSLog(@"信号量当前线程：%@",[NSThread currentThread]);
            sleep(2);
            // 每次发送信号则semaphore会+1，
            dispatch_semaphore_signal(semaphore);
        });
    }
}

#pragma mark - dispatch_apply

- (void)dispatchApplyDemo {
    //dispatch_apply,该函数按指定的次数将指定的Block追加到指定的Queue中，并等待全部处理执行结束
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    NSLog(@"done");
    /*打印结果
     2017-09-20 10:49:29.760594+0800 Multithreading[11622:459025] 2
     2017-09-20 10:49:29.760594+0800 Multithreading[11622:458947] 3
     2017-09-20 10:49:29.760594+0800 Multithreading[11622:459027] 0
     2017-09-20 10:49:29.760594+0800 Multithreading[11622:459026] 1
     2017-09-20 10:49:29.760609+0800 Multithreading[11622:459077] 4
     2017-09-20 10:49:29.760634+0800 Multithreading[11622:459078] 5
     2017-09-20 10:49:29.760650+0800 Multithreading[11622:459079] 6
     2017-09-20 10:49:29.760653+0800 Multithreading[11622:459080] 7
     2017-09-20 10:49:29.760737+0800 Multithreading[11622:458947] 8
     2017-09-20 10:49:29.760738+0800 Multithreading[11622:459025] 9
     2017-09-20 10:49:29.761195+0800 Multithreading[11622:458947] done
     */
}

@end
