//
//  RWTViewModelServices.h
//  RWTFlickrSearch
//
//  Created by Hanguang on 11/8/15.
//  Copyright © 2015 Colin Eberhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWTFlickrSearch.h"

@protocol RWTViewModelServices <NSObject>

- (id <RWTFlickrSearch>)getFlickrSearchService;
- (void)pushViewModel:(id)viewModel;

@end
