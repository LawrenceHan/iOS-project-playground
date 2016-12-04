//
//  Puzzle.m
//  HomePwner
//
//  Created by Hanguang on 26/11/2016.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "Puzzle.h"
#import <pthread.h>
#include <sys/sysctl.h>

//#define SHOWLOG

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
@property (nonatomic, strong) NSMutableArray *routesQueue;
@property (nonatomic, strong) NSMutableArray *routesNextQueue;
@property (nonatomic, assign) BOOL isThreadRunning;

@end

@implementation Puzzle {
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _executionTime;
    pthread_mutex_t _routesQueueLock;
    pthread_mutex_t _routesIndexLock;
    pthread_mutex_t _frameLock;
    pthread_mutex_t _stepResultLock;
    pthread_mutex_t _timerLock;
}

- (instancetype)initWithBeginFrame:(NSString *)beginFrame endFrame:(NSString *)endFrame columns:(int)columns row:(int)rows {
    self = [super init];
    if (self) {
        _beginFrame = beginFrame;
        _endFrame = endFrame;
        _columns = columns;
        _rows = rows;
        pthread_mutex_init(&_routesQueueLock, NULL);
        pthread_mutex_init(&_routesIndexLock, NULL);
        pthread_mutex_init(&_frameLock, NULL);
        pthread_mutex_init(&_stepResultLock, NULL);
        pthread_mutex_init(&_timerLock, NULL);
    }
    return self;
}

- (int)totalTilesCount {
    return _columns * _rows;
}

- (void)calculateSteps {
    _routesQueue = [NSMutableArray new];
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
    [_routesQueue addObject:frame];
    _routesCount = (int)_routesQueue.count;
    _frameSnapshot[[NSString stringWithFormat:@"%s", chars]] = @(frame.steps.length);
        _executionTime = 0.0;
    
    _isThreadRunning = YES;
    int availableThreadCount = cpuCoreCount();
    NSMutableArray *threads = [NSMutableArray arrayWithCapacity:availableThreadCount];
    for (int i = 0; i < availableThreadCount; i++) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startCalcOnThread) object:nil];
        thread.qualityOfService = NSQualityOfServiceUserInitiated;
        thread.name = [NSString stringWithFormat:@"thread: %i", i];
        [threads addObject:thread];
        [thread start];
    }
    
    _foundResults = NO;
    while (_foundResults == NO) {
        [NSThread sleepForTimeInterval:0];
    }
}

- (void)startCalcOnThread {
    while (_isThreadRunning) {
        int index = [self getShareIndex];
        int tempIndex = index;
        if (index == -1) {
            [NSThread sleepForTimeInterval:0];
            continue;
        }
        
#ifdef SHOWLOG
        NSLog(@"Thead started: %@", [NSThread currentThread]);
#endif
        PuzzleFrame *previousFrame = _routesQueue[index];
        NSString *tempSteps = previousFrame.steps;
        //            NSLog(@"== Start steps: %@ thread: %@", previousFrame.steps, [NSThread currentThread]);
        
        int previousStep = previousFrame.previousStep;
        int currentStep = previousFrame.currentStep;
        int nextStep = 0;
        
        NSString *tempLog = [NSString stringWithFormat:@"bSteps: %@", tempSteps];
        
        // upward
        nextStep = currentStep - 4;
        if (nextStep >= 0 && nextStep != previousStep) {
            [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"U" tempLog:tempLog tempIndex:tempIndex];
        }
        
        // downward
        nextStep = currentStep + 4;
        if (nextStep < [self totalTilesCount] && nextStep != previousStep) {
            [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"D" tempLog:tempLog tempIndex:tempIndex];
        }
        
        // leftward
        nextStep = currentStep - 1;
        if (currentStep % _columns - 1 >= 0 && nextStep != previousStep) {
            [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"L" tempLog:tempLog tempIndex:tempIndex];
        }
        
        // rightward
        nextStep = currentStep + 1;
        if (currentStep % _columns + 1 < _columns && nextStep != previousStep) {
            [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"R" tempLog:tempLog tempIndex:tempIndex];
        }
        
        pthread_mutex_lock(&_routesIndexLock);
        _threadCount--;
        pthread_mutex_unlock(&_routesIndexLock);
        
#ifdef SHOWLOG
        NSLog(@"Thead finished: %@", [NSThread currentThread]);
#endif
        
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ @autoreleasepool {
        //        }});
    }
}

- (int)getShareIndex {
    
    pthread_mutex_lock(&_routesIndexLock);
    
    if (_routesIndex < _routesCount - 1) {
        _routesIndex += 1;
        _threadCount += 1;
    } else {
        if (_threadCount == 0) {
            if (_stepResults.count > 0) {
                _isThreadRunning = NO;
                _foundResults = YES;
                for (NSString *result in _stepResults) {
                    NSLog(@"Steps: %@, steps count: %ld == thread: %@, execTime: %f s", result, (long)result.length, [NSThread currentThread].name, _executionTime);
                }
                [_stepResults removeAllObjects];
                pthread_mutex_unlock(&_routesIndexLock);
                return -1;
            } else {
                _routesIndex = 0;
                _threadCount += 1;
                _routesQueue = _routesNextQueue;
                _routesNextQueue = [NSMutableArray new];
                _routesCount = (int)_routesQueue.count;
            }
        } else {
            pthread_mutex_unlock(&_routesIndexLock);
            return -1;
        }
    }
    
    pthread_mutex_unlock(&_routesIndexLock);
    
    return _routesIndex;
}

- (void)moveTileWithFrame:(PuzzleFrame *)puzzleFrame nextStep:(int)nextStep direction:(NSString *)direction tempLog:(NSString *)tempLog tempIndex:(int)tempIndex {
    
    pthread_mutex_lock(&_timerLock);
    _startTime = CFAbsoluteTimeGetCurrent();
    pthread_mutex_unlock(&_timerLock);
    
    char *chars = malloc(_endFrame.length+1);
    memcpy(chars, puzzleFrame.frame, _endFrame.length+1);
    
    NSString *steps = [puzzleFrame.steps stringByAppendingString:direction];
    int currentStep = puzzleFrame.currentStep;
    
    char temp = chars[currentStep];
    chars[currentStep] = chars[nextStep];
    chars[nextStep] = temp;
    NSString *newFrame = [NSString stringWithFormat:@"%s", chars];
    
    pthread_mutex_lock(&_timerLock);
    _executionTime += (CFAbsoluteTimeGetCurrent() - _startTime);
    pthread_mutex_unlock(&_timerLock);
    
    if (newFrame.hash == _endFrame.hash) {
        pthread_mutex_lock(&_stepResultLock);
        [_stepResults addObject:steps];
        NSLog(@"%@ step: %@ AStep: %@, idx: %i, %@", tempLog, direction, steps, tempIndex, [NSThread currentThread].name);
        pthread_mutex_unlock(&_stepResultLock);
    }
    
    pthread_mutex_lock(&_frameLock);
    if (_frameSnapshot[newFrame] != nil) {
        if ([_frameSnapshot[newFrame] integerValue] < steps.length) {
            pthread_mutex_unlock(&_frameLock);
            return;
        }
    } else {
        _frameSnapshot[newFrame] = @(steps.length);
    }
    pthread_mutex_unlock(&_frameLock);
    
    PuzzleFrame *newPuzzleFrame = [PuzzleFrame new];
    newPuzzleFrame.frame = chars;
    newPuzzleFrame.steps = steps;
    newPuzzleFrame.previousStep = currentStep;
    newPuzzleFrame.currentStep = nextStep;
    
    pthread_mutex_lock(&_routesQueueLock);
    [_routesNextQueue addObject:newPuzzleFrame];
    pthread_mutex_unlock(&_routesQueueLock);
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
