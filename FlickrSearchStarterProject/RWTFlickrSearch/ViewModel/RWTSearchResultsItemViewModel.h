//
//  RWTSearchResultsItemViewModel.h
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/9/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWTFlickrPhoto.h"
#import "RWTViewModelServices.h"

@interface RWTSearchResultsItemViewModel : NSObject

@property (nonatomic) BOOL isVisible;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSNumber *favorites;
@property (nonatomic, strong) NSNumber *comments;

- (instancetype)initWithPhoto:(RWTFlickrPhoto *)photo services:(id <RWTViewModelServices>)services;

@end
