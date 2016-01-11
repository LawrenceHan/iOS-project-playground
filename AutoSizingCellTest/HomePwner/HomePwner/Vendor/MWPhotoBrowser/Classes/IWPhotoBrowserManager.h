//
//  IWPhotoBrowserManager.h
//  HomePwner
//
//  Created by Hanguang on 1/11/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IWPhotoBrowserManager;

@protocol IWPhotoBrowserManagerDelegate <NSObject>

@optional

- (void)photoManager:(IWPhotoBrowserManager *)mamanger deletePhotosAtIndexPaths:(NSArray <NSIndexPath *> *)indexes;

@end

@interface IWPhotoBrowserManager : NSObject
@property (nonatomic, weak) id <IWPhotoBrowserManagerDelegate> delegate;
@property (nonatomic) BOOL showAssets;

+ (instancetype)sharedInstance;

- (void)showPhotoBrowserInViewController:(UIViewController *)controller modally:(BOOL)modally;

@end
