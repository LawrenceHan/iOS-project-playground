//
//  NSHipsterViewController.m
//  HomePwner
//
//  Created by Hanguang on 2/21/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

#import "NSHipsterViewController.h"

@implementation NSHipsterViewController

- (void)viewDidLoad {
    // Dispatching Work Asynchronously to a Background Queue
    [self dispatching_Work_Asynchronously_to_a_Background_Queue];
    
    // Benchmarking the Execution Time of an operation
    [self benchmarking_the_Execution_Time_of_an_operation];
    
    // Monitoring Local File Changes
    [self monitoring_Local_File_Changes];
    
    // Monitoring the Parent Process PID
    [self monitoring_the_Parent_Process_PID];
    
    // Reading from STDIN
    [self reading_from_STDIN];
    
    // Dispatching a Timer
    [self dispatching_a_Timer];
}

- (void)dispatching_Work_Asynchronously_to_a_Background_Queue {
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        // Do Work
        NSLog(@"Do background work here.");
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            // Return Result
            NSLog(@"Finished background work!");
        });
    });
}

- (void)benchmarking_the_Execution_Time_of_an_operation {
    size_t const objectCount = 1000;
    uint64_t t = dispatch_benchmark(10000, ^{
        @autoreleasepool {
            id obj = @42;
            NSMutableArray *array = [NSMutableArray array];
            for (size_t i = 0; i < objectCount; ++i) {
                [array addObject:obj];
            }
        }
    });
    NSLog(@"-[NSMutableArray addObject:] : %llu ns", t);
}

- (void)monitoring_Local_File_Changes {
    NSURL *fileURL = [[[NSFileManager defaultManager]
                       URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    int fileDescriptor = open([fileURL fileSystemRepresentation], O_EVTONLY);
    unsigned long mask = DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE;
    __block dispatch_source_t source =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor,
                           mask,
                           queue);
    dispatch_source_set_event_handler(source, ^{
        dispatch_source_vnode_flags_t flags = dispatch_source_get_data(source);
        if (flags) {
            dispatch_source_cancel(source);
            dispatch_async(dispatch_get_main_queue(), ^{
                // ...
                NSLog(@"Handled flags: %lu", flags);
            });
        }
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fileDescriptor);
    });
    dispatch_resume(source);
}

- (void)monitoring_the_Parent_Process_PID {
    pid_t ppid = getppid();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t source =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC, ppid,
                           DISPATCH_PROC_EXIT,
                           globalQueue);
    if (source) {
        dispatch_source_set_event_handler(source, ^{
            NSLog(@"pid: %d Exited", ppid);
            dispatch_source_cancel(source);
        });
        dispatch_resume(source);
    }
}

- (void)reading_from_STDIN {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t stdinReadSource =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, STDIN_FILENO,
                           0,
                           globalQueue);
    dispatch_source_set_event_handler(stdinReadSource, ^{
        uint8_t buffer[1024];
        NSInteger length = read(STDIN_FILENO, buffer, sizeof(buffer));
        if (length > 0) {
            NSString *string =
            [[NSString alloc] initWithBytes:buffer
                                     length:length
                                   encoding:NSUTF8StringEncoding];
            NSLog(@"%@", string);
        }
    });
    dispatch_resume(stdinReadSource);
}

- (void)dispatching_a_Timer {
    dispatch_queue_t queue =
    dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    int64_t delay = 10 * NSEC_PER_SEC;
    int64_t leeway = 5 * NSEC_PER_SEC;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, delay , leeway);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"Ding Dong!");
    });
    dispatch_resume(timer);
}

@end
