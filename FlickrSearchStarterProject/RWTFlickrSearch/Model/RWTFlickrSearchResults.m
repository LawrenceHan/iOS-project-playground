//
//  RWTFlickrSearchResults.m
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/8/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import "RWTFlickrSearchResults.h"

@implementation RWTFlickrSearchResults

- (NSString *)description {
    return [NSString stringWithFormat:@"searchString=%@, totalResults=%lU, photos=%@",
            self.searchString, self.totalResults, self.photos];
}

@end
