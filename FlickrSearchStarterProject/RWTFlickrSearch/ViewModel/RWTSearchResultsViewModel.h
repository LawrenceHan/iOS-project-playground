//
//  RWTSearchResultsViewModel.h
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/9/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWTViewModelServices.h"
#import "RWTFlickrSearchResults.h"

@interface RWTSearchResultsViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *searchResults;

- (instancetype)initWithSearchResults:(RWTFlickrSearchResults *)results
                             services:(id <RWTViewModelServices>)services;

@end
