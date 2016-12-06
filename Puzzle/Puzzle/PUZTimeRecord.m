//
//  PUZTimeRecord.m
//  Puzzle
//
//  Created by Hanguang on 05/12/2016.
//  Copyright © 2016 Hanguang. All rights reserved.
//

#import "PUZTimeRecord.h"

@interface Record : NSObject
@property (nonatomic, assign) CFAbsoluteTime lastUpdateTime;
@property (nonatomic, assign) CFAbsoluteTime executionTime;

@end

@implementation Record

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastUpdateTime = 0.0;
        _executionTime = 0.0;
    }
    return self;
}

@end

@interface PUZTimeRecord ()
@property (nonatomic, strong) NSMutableDictionary *records;

@end

@implementation PUZTimeRecord

- (instancetype)init {
    self = [super init];
    if (self) {
        _records = [NSMutableDictionary new];
    }
    return self;
}

- (void)beginTimeRecord:(NSString *)key {
    Record *record = nil;
    if ([_records objectForKey:key] != nil) {
        record = _records[key];
    } else {
        record = [Record new];
        _records[key] = record;
    }
    record.lastUpdateTime = CFAbsoluteTimeGetCurrent();
}

- (void)continueTimeRecord:(NSString *)key {
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    Record *record = _records[key];
    record.executionTime += (currentTime - record.lastUpdateTime);
    record.lastUpdateTime = currentTime;
}

- (NSString *)totalTimeElapsed:(NSString *)key {
    return [NSString stringWithFormat:@"%f s", [(Record *)_records[key] executionTime]];
}

@end
