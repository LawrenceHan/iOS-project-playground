//
//  RWTFlickrSearchViewModel.m
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/6/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import "RWTFlickrSearchViewModel.h"
#import "RWTSearchResultsViewModel.h"

@interface RWTFlickrSearchViewModel ()

@property (nonatomic, weak) id <RWTViewModelServices> services;

@end

@implementation RWTFlickrSearchViewModel

- (instancetype)initWithServices:(id<RWTViewModelServices>)services {
    self = [super init];
    if (self) {
        _services = services;
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.title = @"Flickr Search";
    
    RACSignal *validSearchSingal = [[RACObserve(self, searchText)
                                     map:^id(NSString *text) {
                                         return @(text.length > 3);
                                     }]
                                    distinctUntilChanged];
    [validSearchSingal subscribeNext:^(id x) {
        NSLog(@"search text is valid %@", x);
    }];
    
    self.executeSearch = [[RACCommand alloc] initWithEnabled:validSearchSingal signalBlock:^RACSignal *(id input) {
        return [self executeSearchSingal];
    }];
}

- (RACSignal *)executeSearchSingal {
    return [[[[self.services getFlickrSearchService]
             flickrSearchSingal:self.searchText]
            logAll]
            doNext:^(id results) {
                RWTSearchResultsViewModel *resultsViewModel =
                [[RWTSearchResultsViewModel alloc] initWithSearchResults:results services:self.services];
                [self.services pushViewModel:resultsViewModel];
            }];
}

@end
