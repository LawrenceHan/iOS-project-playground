//
//  BNRImageTransformer.m
//  
//
//  Created by Hanguang on 8/28/15.
//
//

#import "BNRImageTransformer.h"

@implementation BNRImageTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

- (id)transformedValue:(id)value {
    if (!value) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
    return [UIImage imageWithData:value];
}

@end
