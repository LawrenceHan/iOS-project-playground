//
//  SpinLockThreadSafeDictionary.m
//  FastestThreadsafeDictionary-iOS
//
//  Created by trongbangvp@gmail.com on 9/27/16.
//  Copyright © 2016 trongbangvp@gmail.com. All rights reserved.
//

//#import <libkern/OSAtomic.h>
#import <os/lock.h>
#import "SpinLockThreadSafeDictionary.h"
@interface SpinLockThreadSafeDictionary()
{
    os_unfair_lock _spinLock;
}
@property(atomic, strong) NSMutableDictionary* dic;
@end

@implementation SpinLockThreadSafeDictionary
-(id) init
{
    if(self = [super init])
    {
        _spinLock = OS_UNFAIR_LOCK_INIT;
        _dic = [NSMutableDictionary new];
    }
    return self;
}
-(void)dealloc
{
}

#pragma mark - Read operation
//Read operation is lockless, just checking lock-write

-(NSUInteger)count
{
    os_unfair_lock_lock(&_spinLock);
    
    NSUInteger n = self.dic.count;
    
    os_unfair_lock_unlock(&_spinLock);
    return n;
}

-(id) objectForKey:(id)aKey
{
    os_unfair_lock_lock(&_spinLock);
    
    id val = [self.dic objectForKey:aKey];
    
    os_unfair_lock_unlock(&_spinLock);
    return val;
}

- (NSEnumerator*)keyEnumerator
{
    os_unfair_lock_lock(&_spinLock);
    
    id val = [self.dic keyEnumerator];
    
    os_unfair_lock_unlock(&_spinLock);
    return val;
}
- (NSArray*)allKeys
{
    os_unfair_lock_lock(&_spinLock);
    
    id val = [self.dic allKeys];
    
    os_unfair_lock_unlock(&_spinLock);
    return val;
}
- (NSArray*)allValues
{
    os_unfair_lock_lock(&_spinLock);
    
    id val = [self.dic allValues];
    
    os_unfair_lock_unlock(&_spinLock);
    return val;
}

#pragma mark - Write operation
-(void) setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    os_unfair_lock_lock(&_spinLock);
    
    [self.dic setObject:anObject forKey:aKey];
    
    os_unfair_lock_unlock(&_spinLock);
}

- (void)addEntriesFromDictionary:(NSDictionary*)otherDictionary
{
    os_unfair_lock_lock(&_spinLock);
    
    [self.dic addEntriesFromDictionary:otherDictionary];
    
    os_unfair_lock_unlock(&_spinLock);
}

- (void)removeObjectForKey:(id)aKey
{
    os_unfair_lock_lock(&_spinLock);
    
    [self.dic removeObjectForKey:aKey];
    
    os_unfair_lock_unlock(&_spinLock);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray
{
    os_unfair_lock_lock(&_spinLock);
    
    [self.dic removeObjectsForKeys:keyArray];
    
    os_unfair_lock_unlock(&_spinLock);
}

- (void)removeAllObjects
{
    os_unfair_lock_lock(&_spinLock);
    
    [self.dic removeAllObjects];
    
    os_unfair_lock_unlock(&_spinLock);
}
@end
