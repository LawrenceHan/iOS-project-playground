//
//  RWTSearchResultsItemViewModel.m
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/9/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import "RWTSearchResultsItemViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RWTFlickrPhotoMetadata.h"

@interface RWTSearchResultsItemViewModel ()

@property (nonatomic, weak) id <RWTViewModelServices> services;
@property (nonatomic, strong) RWTFlickrPhoto *photo;
@end

@implementation RWTSearchResultsItemViewModel

- (instancetype)initWithPhoto:(RWTFlickrPhoto *)photo services:(id<RWTViewModelServices>)services {
    self = [super init];
    if (self) {
        _title = photo.title;
        _url = photo.url;
        _services = services;
        _photo = photo;
        
        [self initialize];
    }
    return self;
}

- (void)initialize {
    RACSignal *fetchMetadata = [RACObserve(self, isVisible)
                                filter:^BOOL(NSNumber *visible) {
                                    return [visible boolValue];
                                }];
    @weakify(self)
    [fetchMetadata subscribeNext:^(id x) {
        @strongify(self);
        [[[self.services getFlickrSearchService] flickrImageMetadata:self.photo.identifier]
    subscribeNext:^(RWTFlickrPhotoMetadata *metaData) {
        self.favorites = @(metaData.favorites);
        self.comments = @(metaData.comments);
    }];
    }];
}

@end
