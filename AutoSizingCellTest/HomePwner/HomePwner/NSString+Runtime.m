//
//  NSString+Runtime.m
//  HomePwner
//
//  Created by Hanguang on 11/2/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import "NSString+Runtime.h"
#import <objc/runtime.h>

@implementation NSString (Runtime)

/* TEST
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *string = @"";
        Class cls = [string class];
        
        SEL originalSelector = @selector(isEqualToString:);
        SEL swizzledSelector = @selector(run_isEqualToString:);
        
        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(cls, originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(cls, swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}
*/

#pragma mark - Method Swizzling
- (BOOL)run_isEqualToString:(NSString *)aString {
    BOOL isEqual = [self run_isEqualToString:aString];
    if (isEqual) {
        NSLog(@"Runtime check: two strings is equal");
    } else {
        NSLog(@"Runtime check: two strings is not equal");
    }
    
    return isEqual;
}

#pragma mark - Setter & Getter
- (void)setStringArray:(NSArray *)stringArray {
    objc_setAssociatedObject(self, @selector(stringArray), stringArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)stringArray {
    return objc_getAssociatedObject(self, @selector(stringArray));
}

@end
