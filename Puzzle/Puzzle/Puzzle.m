//
//  Puzzle.m
//  HomePwner
//
//  Created by Hanguang on 26/11/2016.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "Puzzle.h"
#import "PUZTimeRecord.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>
#import <pthread.h>
#include <sys/sysctl.h>
#define SHOWLOG

@interface PuzzleFrame : NSObject
@property (nonatomic, copy) NSString *steps;
@property (nonatomic, assign) char *frame;
@property (nonatomic, assign) int previousStep;
@property (nonatomic, assign) int currentStep;
@end

@implementation PuzzleFrame

- (NSString *)description {
    return [NSString stringWithFormat:@"frame: %s, steps: %@, previousStep: %ld, currentStep: %ld", _frame, _steps, (long)_previousStep, (long)_currentStep];
}

@end

@interface Puzzle ()
@property (nonatomic, assign) NSUInteger totalStepCounts;
@property (nonatomic, strong) NSMutableDictionary *frameSnapshot;
@property (nonatomic, strong) NSMutableArray *stepResults;
@property (nonatomic, assign) BOOL foundResults;
@property (nonatomic, assign) int threadCount;
@property (nonatomic, assign) int routesCount;
@property (nonatomic, assign) int routesIndex;
@property (nonatomic, strong) NSArray *routesQueue;
@property (nonatomic, strong) NSMutableArray *routesNextQueue;
@property (nonatomic, assign) BOOL isThreadRunning;

@end

static NSString *getIndexKey = @"getIndex";
static NSString *charKey = @"char";
static NSString *stringKey = @"string";
static NSString *hashKey = @"hash";
static NSString *frameKey = @"frame";
static NSString *routesKey = @"routes";

@implementation Puzzle {
    NSLock * _routesQueueLock;
    NSLock * _routesIndexLock;
    NSLock * _frameLock;
    NSLock * _stepResultLock;
    int32_t volatile _frameLockFlag;
    int32_t volatile _routesIndexFlag;
    os_unfair_lock _routesIndexSpinLock;
    os_unfair_lock _routesQueueSpinLock;
    os_unfair_lock _frameSpinLock;
    pthread_mutex_t _routesIndexMutexLock;
    NSMutableDictionary *_moveTileCountDict;
    PUZTimeRecord *_timeRecorder;
}

- (instancetype)initWithBeginFrame:(NSString *)beginFrame endFrame:(NSString *)endFrame columns:(int)columns row:(int)rows {
    self = [super init];
    if (self) {
        _beginFrame = beginFrame;
        _endFrame = endFrame;
        _columns = columns;
        _rows = rows;
        
        _routesQueueLock = [[NSLock alloc] init];
        _routesIndexLock = [[NSLock alloc] init];
        _frameLock = [[NSLock alloc] init];
        _stepResultLock = [[NSLock alloc] init];
        _timeRecorder = [PUZTimeRecord new];
        _frameLockFlag = 0;
        _routesIndexFlag = 0;
        _routesIndexSpinLock = OS_UNFAIR_LOCK_INIT;
        _routesQueueSpinLock = OS_UNFAIR_LOCK_INIT;
        _frameSpinLock = OS_UNFAIR_LOCK_INIT;
        pthread_mutex_init(&_routesIndexMutexLock, NULL);
        _moveTileCountDict = [NSMutableDictionary new];
    }
    return self;
}

- (int)totalTilesCount {
    return _columns * _rows;
}

- (void)calculateSteps {
    _routesQueue = [NSArray new];
    _routesNextQueue = [NSMutableArray new];
    _frameSnapshot = [NSMutableDictionary new];
    _stepResults = [NSMutableArray new];
    _totalStepCounts = 0;
    _threadCount = 0;
    _routesIndex = -1;
    
    PuzzleFrame *frame = [PuzzleFrame new];
    frame.previousStep = 0;
    frame.currentStep = 0;
    frame.steps = @"";
    
    const char *beginChar = _beginFrame.UTF8String;
    char *chars = malloc(_beginFrame.length+1);
    memcpy(chars, beginChar, _beginFrame.length+1);
    frame.frame = chars;
    _routesQueue = @[frame];
    _routesCount = (int)_routesQueue.count;
    _frameSnapshot[[NSString stringWithFormat:@"%s", chars]] = @(frame.steps.length);
    
    _isThreadRunning = YES;
    int availableThreadCount = 4;//cpuCoreCount();
    NSMutableArray *threads = [NSMutableArray arrayWithCapacity:availableThreadCount];
    for (int i = 0; i < availableThreadCount; i++) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startCalcOnThread) object:nil];
        thread.qualityOfService = NSQualityOfServiceUserInitiated;
        thread.name = [NSString stringWithFormat:@"T_%i", i];
        [threads addObject:thread];
        [thread start];
    }
    
    _foundResults = NO;
    while (_foundResults == NO) {
        [NSThread sleepForTimeInterval:0];
    }
    
    if (_isThreadRunning == NO) {
        //        NSLog(@"Total MT_Count: %@", _moveTileCountDict[@"total"]);
        for (NSThread *thread in threads) {
#ifdef SHOWLOG
            NSLog(@"index:%@, char:%@, string:%@, hash:%@, frame:%@, routes:%@, %@",
                  [_timeRecorder totalTimeElapsed:getIndexKey thread:thread],
                  [_timeRecorder totalTimeElapsed:charKey thread:thread],
                  [_timeRecorder totalTimeElapsed:stringKey thread:thread],
                  [_timeRecorder totalTimeElapsed:hashKey thread:thread],
                  [_timeRecorder totalTimeElapsed:frameKey thread:thread],
                  [_timeRecorder totalTimeElapsed:routesKey thread:thread],
                  thread.name);
#endif
            [thread cancel];
        }
    }
}

- (void)startCalcOnThread {
    while (_isThreadRunning) { @autoreleasepool {
        int index = [self getShareIndex];
        if (index == -1) {
            [NSThread sleepForTimeInterval:0];
        } else {
            PuzzleFrame *previousFrame = _routesQueue[index];
            int previousStep = previousFrame.previousStep;
            int currentStep = previousFrame.currentStep;
            int nextStep = 0;
            
            // upward
            nextStep = currentStep - 4;
            if (nextStep >= 0 && nextStep != previousStep) {
                [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"U"];
            }
            
            // downward
            nextStep = currentStep + 4;
            if (nextStep < [self totalTilesCount] && nextStep != previousStep) {
                [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"D"];
            }
            
            // leftward
            nextStep = currentStep - 1;
            if (currentStep % _columns - 1 >= 0 && nextStep != previousStep) {
                [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"L"];
            }
            
            // rightward
            nextStep = currentStep + 1;
            if (currentStep % _columns + 1 < _columns && nextStep != previousStep) {
                [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"R"];
            }
            
            //        [_routesIndexLock lock];
            os_unfair_lock_lock(&_routesIndexSpinLock);
            _threadCount -= 1;
            os_unfair_lock_unlock(&_routesIndexSpinLock);
            //        [_routesIndexLock unlock];
        }
    }}
}

- (int)getShareIndex {
#ifdef SHOWLOG
    [_timeRecorder beginTimeRecord:getIndexKey];
#endif
//    [_routesIndexLock lock];
    os_unfair_lock_lock(&_routesIndexSpinLock);
    if (_routesIndex < _routesCount - 1) {
        _routesIndex += 1;
        _threadCount += 1;
    } else {
        if (_threadCount == 0) {
            if (_stepResults.count > 0) {
                _isThreadRunning = NO;
                _foundResults = YES;
                for (NSString *result in _stepResults) {
                    NSLog(@"Steps: %@, steps count: %ld == thread: %@", result, (long)result.length, [NSThread currentThread].name);
                }
                _stepResults = nil;
//                [_routesIndexLock unlock];
                os_unfair_lock_unlock(&_routesIndexSpinLock);
#ifdef SHOWLOG
                [_timeRecorder continueTimeRecord:getIndexKey];
#endif
                return -1;
            } else {
                _routesIndex = 0;
                _threadCount += 1;
                _routesQueue = [_routesNextQueue copy];
                [_routesNextQueue removeAllObjects];
                _routesCount = (int)_routesQueue.count;
            }
        } else {
//            [_routesIndexLock unlock];
            os_unfair_lock_unlock(&_routesIndexSpinLock);
#ifdef SHOWLOG
            [_timeRecorder continueTimeRecord:getIndexKey];
#endif
            return -1;
        }
    }
    os_unfair_lock_unlock(&_routesIndexSpinLock);
//    [_routesIndexLock unlock];
    
#ifdef SHOWLOG
    [_timeRecorder continueTimeRecord:getIndexKey];
#endif
    
    return _routesIndex;
}

- (void)moveTileWithFrame:(PuzzleFrame *)puzzleFrame nextStep:(int)nextStep direction:(NSString *)direction/* tempLog:(NSString *)tempLog tempIndex:(int)tempIndex */ {
#ifdef SHOWLOG
    [_timeRecorder beginTimeRecord:charKey];
#endif
    //    NSNumber *totalCount;
    //    if ([_moveTileCountDict objectForKey:@"total"] == nil) {
    //        totalCount = @1;
    //    } else {
    //        int total = [[_moveTileCountDict objectForKey:@"total"] intValue];
    //        total +=1;
    //        totalCount = @(total);
    //    }
    //    _moveTileCountDict[@"total"] = totalCount;
    //
    //    NSNumber *moveTileCount;
    //    if ([_moveTileCountDict objectForKey:[NSThread currentThread].name] == nil) {
    //        moveTileCount = @1;
    //    } else {
    //        int count = [[_moveTileCountDict objectForKey:[NSThread currentThread].name] intValue];
    //        count +=1;
    //        moveTileCount = @(count);
    //    }
    //    _moveTileCountDict[[NSThread currentThread].name] = moveTileCount;
    
    char *chars = malloc(_endFrame.length+1);
    memcpy(chars, puzzleFrame.frame, _endFrame.length+1);
    
#ifdef SHOWLOG
    [_timeRecorder continueTimeRecord:charKey];
#endif
    
#ifdef SHOWLOG
    [_timeRecorder beginTimeRecord:stringKey];
#endif
    
    NSString *steps = [puzzleFrame.steps stringByAppendingString:direction];
    int currentStep = puzzleFrame.currentStep;
    
    char temp = chars[currentStep];
    chars[currentStep] = chars[nextStep];
    chars[nextStep] = temp;
    NSString *newFrame = [NSString stringWithFormat:@"%s", chars];
    
#ifdef SHOWLOG
    [_timeRecorder continueTimeRecord:stringKey];
#endif
    
#ifdef SHOWLOG
    [_timeRecorder beginTimeRecord:hashKey];
#endif
    
    if (newFrame.hash == _endFrame.hash) {
        [_stepResultLock lock];
        [_stepResults addObject:steps];
        [_stepResultLock unlock];
        NSLog(@"%@ + step:%@ = %@, %@", puzzleFrame.steps, direction, steps, [NSThread currentThread].name);
    }
#ifdef SHOWLOG
    [_timeRecorder continueTimeRecord:hashKey];
#endif
    
#ifdef SHOWLOG
    [_timeRecorder beginTimeRecord:frameKey];
#endif
    
//    while(!OSAtomicCompareAndSwap32(0, 1, &_frameLockFlag));
    os_unfair_lock_lock(&_frameSpinLock);
    NSInteger length = [[_frameSnapshot objectForKey:newFrame] integerValue];
    os_unfair_lock_unlock(&_frameSpinLock);
//    OSAtomicCompareAndSwap32(1, 0, &_frameLockFlag);
    
    if (length != 0) {
        if (length < steps.length) {
            return;
        }
    } else {
//        while(!OSAtomicCompareAndSwap32(0, 1, &_frameLockFlag));
        os_unfair_lock_lock(&_frameSpinLock);
        [_frameSnapshot setObject:@(steps.length) forKey:newFrame];
        os_unfair_lock_unlock(&_frameSpinLock);
//        OSAtomicCompareAndSwap32(1, 0, &_frameLockFlag);
    }
    
#ifdef SHOWLOG
    [_timeRecorder continueTimeRecord:frameKey];
#endif
    
#ifdef SHOWLOG
    [_timeRecorder beginTimeRecord:routesKey];
#endif
    
    PuzzleFrame *newPuzzleFrame = [PuzzleFrame new];
    newPuzzleFrame.frame = chars;
    newPuzzleFrame.steps = steps;
    newPuzzleFrame.previousStep = currentStep;
    newPuzzleFrame.currentStep = nextStep;
    
//    [_routesQueueLock lock];
    os_unfair_lock_lock(&_routesQueueSpinLock);
    [_routesNextQueue addObject:newPuzzleFrame];
    os_unfair_lock_unlock(&_routesQueueSpinLock);
//    [_routesQueueLock unlock];
    
#ifdef SHOWLOG
    [_timeRecorder continueTimeRecord:routesKey];
#endif
}

int cpuCoreCount() {
    static int count = 0;
    if (count == 0) {
        size_t len;
        unsigned int ncpu;
        
        len = sizeof(ncpu);
        sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
        count = ncpu;
    }
    
    return count;
}

@end
