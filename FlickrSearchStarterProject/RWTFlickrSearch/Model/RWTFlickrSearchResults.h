//
//  RWTFlickrSearchResults.h
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/8/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RWTFlickrSearchResults : NSObject

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic) NSUInteger totalResults;

@end
