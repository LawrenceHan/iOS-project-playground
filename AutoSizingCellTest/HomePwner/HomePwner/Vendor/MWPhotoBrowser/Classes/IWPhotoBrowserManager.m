//
//  IWPhotoBrowserManager.m
//  HomePwner
//
//  Created by Hanguang on 1/11/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "IWPhotoBrowserManager.h"
#import "MWPhotoBrowser.h"

@interface IWPhotoBrowserManager () <MWPhotoBrowserDelegate>

@property (nonatomic, weak) MWPhotoBrowser *photoBrowser;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, readonly) NSArray *selectedPhotos;

@end

@implementation IWPhotoBrowserManager {
    NSInteger _currentIndex;
    UIViewController *_presentingViewController;
}

#pragma mark - Initialize
+ (instancetype)sharedInstance {
    static IWPhotoBrowserManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] initPrivate];
    });
    
    return _sharedInstance;
}

- (instancetype)initPrivate {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    [self loadPhotos];
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

+ (instancetype)new NS_UNAVAILABLE
{
    return nil;
}


#pragma mark - Load photo
- (void)loadPhotos {
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    
    // MARK: - To be removed
    // Test photos
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5" ofType:@"jpg"]]];
    //photo.caption = @"White Tower";
    [photos addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"jpg"]]];
    //photo.caption = @"The London Eye is a giant Ferris wheel situated on the banks of the River Thames, in London, England.";
    [photos addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
    //photo.caption = @"York Floods";
    [photos addObject:photo];
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4" ofType:@"jpg"]]];
    //photo.caption = @"Campervan";
    [photos addObject:photo];
    
    // Thumbs
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5t" ofType:@"jpg"]]];
    [thumbs addObject:photo];
    photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo2t" ofType:@"jpg"]]];
    [thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3t" ofType:@"jpg"]]];
    [thumbs addObject:photo];
    photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo4t" ofType:@"jpg"]]];
    [thumbs addObject:photo];
    
    // Web photo
    photo = [MWPhoto
             photoWithURL:[NSURL
                           URLWithString:@"http://images.99pet.com/InfoImages/wm600_450/ef48d0d8e8f64172a28b9451fc5a941d.jpg"]];
    
    //photo.caption = @"Dog n Cat";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://images.99pet.com/InfoImages/wm600_450/ef48d0d8e8f64172a28b9451fc5a941d.jpg"]]];
    
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://ww1.sinaimg.cn/mw600/bce7ca57gw1e4rg0coeqqj20dw099myu.jpg"]];
    //photo.caption = @"Mannequin Half Light";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto
                       photoWithURL:[NSURL URLWithString:@"http://ww1.sinaimg.cn/mw600/bce7ca57gw1e4rg0coeqqj20dw099myu.jpg"]]];
    
    photo = [MWPhoto
             photoWithURL:[NSURL
                           URLWithString:@"http://images.99pet.com/InfoImages/wm600_450/5b3aa91249cc4f529726a739ab0df6e4.jpg"]];
    //photo.caption = @"Mannequin Side Light";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto
                       photoWithURL:[NSURL URLWithString:@"http://images.99pet.com/InfoImages/wm600_450/5b3aa91249cc4f529726a739ab0df6e4.jpg"]]];
    
    photo = [MWPhoto
             photoWithURL:[NSURL URLWithString:@"http://img1.ali213.net/picfile/News/2014/04/18/pm/xs55.gif"]];
    //photo.caption = @"Mannequin Side Light";
    [photos addObject:photo];
    [thumbs addObject:[MWPhoto
                       photoWithURL:[NSURL URLWithString:@"http://img1.ali213.net/picfile/News/2014/04/18/pm/xs55.gif"]]];
    
    self.photos = photos;
    self.thumbs = thumbs;
}

- (void)loadAssets {
    if (NSClassFromString(@"PHAsset") != nil) {
        
        // TODO: Use photo permission manager
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
        
    }
}

- (void)performLoadAssets {
    // Initialise
    _assets = [NSMutableArray new];
    
    // Load
    if (NSClassFromString(@"PHAsset") != nil) {
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithOptions:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
            if (fetchResults.count > 0) {
                [self addAssetsToPhotos];
            }
        });
    }
}

- (void)addAssetsToPhotos {
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [self.photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [self.thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
            
            [_photoBrowser performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }
}

#pragma mark - PhotoBrowser delegate
- (void)showPhotoBrowserInViewController:(UIViewController *)controller modally:(BOOL)modally {
    _presentingViewController = controller;
    
    // load assets if needed
    if (self.showAssets) {
        if (!_assets) {
            [self loadAssets];
        }
    }
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    _photoBrowser = browser;
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:_currentIndex];
    
    if (modally) {
        [controller presentViewController:browser animated:YES completion:nil];
    } else {
        [controller.navigationController pushViewController:browser animated:YES];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deletePhotosAtIndexPaths:(NSArray<NSIndexPath *> *)indexes {
    if (indexes.count) {
        NSMutableArray *photosToBeDeleted = [NSMutableArray new];
        NSMutableArray *thumbsToBeDeleted = [NSMutableArray new];
        for (NSIndexPath *indexPath in indexes) {
            MWPhoto *photo = self.photos[indexPath.row];
            MWPhoto *thumbPhoto = self.thumbs[indexPath.row];
            
            [photosToBeDeleted addObject:photo];
            [thumbsToBeDeleted addObject:thumbPhoto];
        }
        
        [self.photos removeObjectsInArray:photosToBeDeleted];
        [self.thumbs removeObjectsInArray:thumbsToBeDeleted];
        
        [photoBrowser deletePhotosWithAnimationAtIndexPaths:indexes];
        
        if ([_delegate respondsToSelector:@selector(photoManager:deletePhotosAtIndexPaths:)]) {
            [_delegate photoManager:self deletePhotosAtIndexPaths:indexes];
        }
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
    _currentIndex = index;
}

/* Photo title delegate
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
}
 */

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [photoBrowser dismissViewControllerAnimated:YES completion:nil];
}


@end
