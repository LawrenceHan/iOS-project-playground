//
//  RWTFlickrSearch.h
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/6/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Foundation/Foundation.h>

@protocol RWTFlickrSearch <NSObject>

- (RACSignal *)flickrSearchSingal:(NSString *)searchString;
- (RACSignal *)flickrImageMetadata:(NSString *)photoId;

@end
