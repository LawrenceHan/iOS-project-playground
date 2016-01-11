//
//  BNRTableViewController.m
//  HomePwner
//
//  Created by Hanguang on 8/31/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRTableViewController.h"
#import "BNRCollectionViewController.h"
#import "MWPhotoBrowser.h"
#import "SDImageCache.h"
#import "IWPhotoBrowserManager.h"

@interface BNRTableViewController () <MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;

@end

@implementation BNRTableViewController {
    NSMutableArray *_selections;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Clear cache for testing
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
//    [self loadPhotos];
//    [self loadAssets];
}

- (void)loadPhotos {
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo, *thumb;
    
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
    if (NSClassFromString(@"PHAsset")) {
        
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
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        });
    }
}

#pragma mark - Dismiss method

- (IBAction)unwindMethod:(UIStoryboardSegue *)sender {
    NSLog(@"Back from detail view controller, segue: %@", sender);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
//        [self showPhotoBrowser];
        [[IWPhotoBrowserManager sharedInstance] showPhotoBrowserInViewController:self modally:NO];
        
    } else if (indexPath.row == 4) {
        [IWPhotoBrowserManager sharedInstance].showAssets = YES;
        [[IWPhotoBrowserManager sharedInstance] showPhotoBrowserInViewController:self modally:YES];
        
//        @synchronized(_assets) {
//            NSMutableArray *copy = [_assets copy];
//            if (NSClassFromString(@"PHAsset")) {
//                // Photos library
//                UIScreen *screen = [UIScreen mainScreen];
//                CGFloat scale = screen.scale;
//                // Sizing is very rough... more thought required in a real implementation
//                CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
//                CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
//                CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
//                for (PHAsset *asset in copy) {
//                    [self.photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
//                    [self.thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
//                }
//            }
//            [self showPhotoBrowser];
//        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showPhotoBrowser {
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = YES;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (browser.displayActionButton) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < self.photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    // Test custom selection images
    //    browser.customImageSelectedIconName = @"ImageSelected.png";
    //    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    [self.navigationController pushViewController:browser animated:YES];
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
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
