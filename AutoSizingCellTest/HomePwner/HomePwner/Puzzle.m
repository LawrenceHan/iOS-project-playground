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
@property (nonatomic, copy) NSString *frame;
@property (nonatomic) NSInteger previousStep;
@property (nonatomic) NSInteger currentStep;
@end

@implementation PuzzleFrame

- (NSString *)description {
    return [NSString stringWithFormat:@"frame: %@, steps: %@, previousStep: %ld, currentStep: %ld", _frame, _steps, (long)_previousStep, (long)_currentStep];
}

@end

@interface Puzzle ()
@property (nonatomic) NSUInteger totalStepCounts;
@property (nonatomic, strong) NSMutableDictionary *frameSnapshot;
@property (nonatomic, strong) NSMutableArray *stepResults;

@end

@implementation Puzzle

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
    frame.frame = _beginFrame;
    [routes addObject:frame];
    _frameSnapshot[frame.frame] = @(frame.steps.length);
    
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
                    NSLog(@"Steps: %@, steps count: %ld total count %ld", result, (long)result.length, (long)_totalStepCounts);
                }
                return;
            }
            
            routes = routesNext;
        }
    }
}

- (void)moveTileWithFrame:(PuzzleFrame *)puzzleFrame nextStep:(NSInteger)nextStep direction:(NSString *)direction routesNext:(NSMutableArray *)routesNext {
    __block NSMutableArray *previousFrameArray = [NSMutableArray arrayWithCapacity:puzzleFrame.frame.length];
    [puzzleFrame.frame enumerateSubstringsInRange:NSMakeRange(0, puzzleFrame.frame.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [previousFrameArray addObject:substring];
    }];
    
    NSString *steps = [puzzleFrame.steps stringByAppendingString:direction];
    NSInteger currentStep = puzzleFrame.currentStep;
    NSString *previousTile = previousFrameArray[currentStep];
    NSString *nextTile = previousFrameArray[nextStep];
    previousFrameArray[currentStep] = nextTile;
    previousFrameArray[nextStep] = previousTile;
    NSString *newFrame = [previousFrameArray componentsJoinedByString:@""];
    
    if (_frameSnapshot[newFrame] != nil) {
        if ([_frameSnapshot[newFrame] integerValue] < steps.length) {
            return;
        }
    } else {
        if (newFrame.hash == _endFrame.hash) {
            [_stepResults addObject:steps];
        }
        _frameSnapshot[newFrame] = @(steps.length);
    }
    
    PuzzleFrame *newPuzzleFrame = [PuzzleFrame new];
    newPuzzleFrame.frame = newFrame;
    newPuzzleFrame.steps = steps;
    newPuzzleFrame.previousStep = currentStep;
    newPuzzleFrame.currentStep = nextStep;
    
    [routesNext addObject:newPuzzleFrame];
    _totalStepCounts += 1;
}

@end
