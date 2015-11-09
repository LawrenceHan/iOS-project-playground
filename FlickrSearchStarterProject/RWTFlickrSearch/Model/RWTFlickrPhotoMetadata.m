//
//  RWTFlickrPhotoMetadata.m
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/9/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import "RWTFlickrPhotoMetadata.h"

@implementation RWTFlickrPhotoMetadata

- (NSString *)description {
    return [NSString stringWithFormat:@"metadata: comments=%lU, favorites:%lU", self.comments, self.favorites];
}

@end
