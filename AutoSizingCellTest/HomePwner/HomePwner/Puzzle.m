//
//  Puzzle.m
//  HomePwner
//
//  Created by Hanguang on 26/11/2016.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "Puzzle.h"

@interface PuzzleFrame : NSObject
@property (nonatomic, copy) NSString *steps;
@property (nonatomic, assign) char *frame;
@property (nonatomic) NSInteger previousStep;
@property (nonatomic) NSInteger currentStep;
@end

@implementation PuzzleFrame

- (NSString *)description {
    return [NSString stringWithFormat:@"frame: %s, steps: %@, previousStep: %ld, currentStep: %ld", _frame, _steps, (long)_previousStep, (long)_currentStep];
}

@end

@interface Puzzle ()
@property (nonatomic) NSUInteger totalStepCounts;
@property (nonatomic, strong) NSMutableDictionary *frameSnapshot;
@property (nonatomic, strong) NSMutableArray *stepResults;

@end

@implementation Puzzle {
    CFAbsoluteTime _startTime;
    CFAbsoluteTime _executionTime;
}

- (instancetype)initWithBeginFrame:(NSString *)beginFrame endFrame:(NSString *)endFrame columns:(NSInteger)columns row:(NSInteger)rows {
    self = [super init];
    if (self) {
        _beginFrame = beginFrame;
        _endFrame = endFrame;
        _columns = columns;
        _rows = rows;
    }
    return self;
}

- (NSInteger)totalTilesCount {
    return _columns * _rows;
}

- (void)calculateSteps {
    NSMutableArray *routes = [NSMutableArray new];
    _frameSnapshot = [NSMutableDictionary new];
    _stepResults = [NSMutableArray new];
    _totalStepCounts = 0;
    
    PuzzleFrame *frame = [PuzzleFrame new];
    frame.previousStep = 0;
    frame.currentStep = 0;
    frame.steps = @"";
    
    const char *beginChar = _beginFrame.UTF8String;
    char *chars = malloc(_beginFrame.length+1);
    memcpy(chars, beginChar, _beginFrame.length+1);
    frame.frame = chars;
    [routes addObject:frame];
    _frameSnapshot[[NSString stringWithFormat:@"%s", chars]] = @(frame.steps.length);
    
    _executionTime = 0.0;
    while (true) {
        @autoreleasepool {
            NSMutableArray *routesNext = [NSMutableArray new];
            for (PuzzleFrame *previousFrame in routes) {
                NSInteger previousStep = previousFrame.previousStep;
                NSInteger currentStep = previousFrame.currentStep;
                NSInteger nextStep = 0;
                
                // upward
                nextStep = currentStep - 4;
                if (nextStep >= 0 && nextStep != previousStep) {
                    [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"U" routesNext:routesNext];
                }
                
                // downward
                nextStep = currentStep + 4;
                if (nextStep < [self totalTilesCount] && nextStep != previousStep) {
                    [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"D" routesNext:routesNext];
                }
                
                // leftward
                nextStep = currentStep - 1;
                if (currentStep % _columns - 1 >= 0 && nextStep != previousStep) {
                    [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"L" routesNext:routesNext];
                }
                
                // rightward
                nextStep = currentStep + 1;
                if (currentStep % _columns + 1 < _columns && nextStep != previousStep) {
                    [self moveTileWithFrame:previousFrame nextStep:nextStep direction:@"R" routesNext:routesNext];
                }
            }
            
            if (_stepResults.count > 0) {
                for (NSString *result in _stepResults) {
                    NSLog(@"Totoal calc time: %f s, steps: %@, steps count: %ld total count %ld", _executionTime, result, (long)result.length, (long)_totalStepCounts);
                }
                return;
            }
            
            routes = routesNext;
        }
    }
}

- (void)moveTileWithFrame:(PuzzleFrame *)puzzleFrame nextStep:(NSInteger)nextStep direction:(NSString *)direction routesNext:(NSMutableArray *)routesNext {
    _startTime = CFAbsoluteTimeGetCurrent();
    
    char *chars = malloc(_endFrame.length+1);
    memcpy(chars, puzzleFrame.frame, _endFrame.length+1);
    
    NSString *steps = [puzzleFrame.steps stringByAppendingString:direction];
    NSInteger currentStep = puzzleFrame.currentStep;
    
    char temp = chars[currentStep];
    chars[currentStep] = chars[nextStep];
    chars[nextStep] = temp;
    
    NSString *newFrame = [NSString stringWithFormat:@"%s", chars];
    NSNumber *length = _frameSnapshot[newFrame];
    if (length != nil) {
        if ([length integerValue] < steps.length) {
            return;
        }
    } else {
        if (newFrame.hash == _endFrame.hash) {
            [_stepResults addObject:steps];
        }
        _frameSnapshot[newFrame] = @(steps.length);
    }
    
    PuzzleFrame *newPuzzleFrame = [PuzzleFrame new];
    newPuzzleFrame.frame = chars;
    newPuzzleFrame.steps = steps;
    newPuzzleFrame.previousStep = currentStep;
    newPuzzleFrame.currentStep = nextStep;
    
    [routesNext addObject:newPuzzleFrame];
    _totalStepCounts += 1;
    
    _executionTime += (CFAbsoluteTimeGetCurrent() - _startTime);
}

@end
