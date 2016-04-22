//
//  BNRDetailViewController.m
//  HomePwner
//
//  Created by John Gallagher on 1/7/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

@import CoreImage;

#import "BNRDetailViewController.h"
#import "BNRItem.h"
#import "BNRImageStore.h"
#import "BNRItemStore.h"
#import "UIImageEffects.h"
#import "VBFDownloadButton.h"
#import "UIColor+FlatColors.h"

@interface BNRDetailViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,
    UITextFieldDelegate, UIPopoverControllerDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) UIPopoverController *imagePickerPopover;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (nonatomic) CGAffineTransform transformToUIKit;
@property (nonatomic) NSInteger latestCount;

- (IBAction)takePicture:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end

@implementation BNRDetailViewController {
    CALayer *blurLayer;
    BOOL shouldIgnoreSnapshot;
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    BOOL isNew = NO;
    if (identifierComponents.count == 3) {
        isNew = YES;
    }
    
    return [[self alloc] initForNewItem:isNew];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.item.itemKey forKey:@"item.itemKey"];
    
    self.item.itemName = self.nameField.text;
    self.item.serialNumber = self.serialNumberField.text;
    self.item.valueInDollars = [self.valueField.text intValue];
    
    [[BNRItemStore sharedStore] saveChanges];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
    
    for (BNRItem *item in [[BNRItemStore sharedStore] allItems]) {
        if ([itemKey isEqualToString:item.itemKey]) {
            self.item = item;
            break;
        }
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

- (instancetype)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:nil bundle:nil];

    if (self) {
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(save:)];
            self.navigationItem.rightBarButtonItem = doneItem;

            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = cancelItem;
        }
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initForNewItem:"
                                 userInfo:nil];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addDownloadButton];
    
    // Register notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applicationResigningActive:)
               name:UIApplicationWillResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(applicationBecameActive:)
               name:UIApplicationDidBecomeActiveNotification object:nil];

    UIImageView *iv = [[UIImageView alloc] initWithImage:nil];

    // The contentMode of the image view in the XIB was Aspect Fit:
    iv.contentMode = UIViewContentModeScaleAspectFit;

    // Do not produce a translated constraint for this view
    iv.translatesAutoresizingMaskIntoConstraints = NO;

    // The image view was a subview of the view
    [self.view addSubview:iv];

    // The image view was pointed to by the imageView property
    self.imageView = iv;

    NSDictionary *nameMap = @{@"imageView": self.imageView,
                              @"dateLabel": self.dateLabel,
                              @"toolbar": self.toolbar};

    // imageView is 0 pts from superview at left and right edges
    NSArray *horizontalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                options:0
                                                metrics:nil
                                                  views:nameMap];

    // imaveView is 8 pts from dateLabel at its top edge...
    // ... and 8 pts from toolbar at its bottom edge
    NSArray *verticalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateLabel]-[imageView]-[toolbar]"
                                                options:0
                                                metrics:nil
                                                  views:nameMap];

    [self.view addConstraints:horizontalConstraints];
    [self.view addConstraints:verticalConstraints];
    
    /*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor blueColor];
    button.frame = CGRectMake(100, 200, 40, 40);
    [self.view addSubview:button];
     */
    
    [[self.nameField.rac_textSignal
      map:^id(NSString *text) {
          UIColor *color = text.length > 3 ? [UIColor whiteColor] : [UIColor yellowColor];
          NSLog(@"%@", text);
          return color;
      }] subscribeNext:^(UIColor *color) {
          self.nameField.backgroundColor = color;
      }];
    
    _latestCount = 0;
    RAC(self.valueField, text) = [[self.nameField.rac_textSignal map:^id(id value) {
        return [self latestSignal];
    }] switchToLatest];
}

- (void)addDownloadButton {
    VBFDownloadButton *downloadButton = [[VBFDownloadButton alloc]initWithButtonDiameter:60
                                                                                  center:self.view.center
                                                                                   color:[UIColor flatSunFlowerColor]
                                                                       progressLineColor:[UIColor flatCloudsColor]
                                                                            downloadIcon:[UIImage imageNamed:@"downloadCloud"]
                                                                      progressViewLength:200];

    [self.view addSubview:downloadButton];
}

- (RACSignal *)latestSignal {
    NSString *latestCount = [NSString stringWithFormat:@"latest signal %ld", (long)_latestCount++];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:latestCount];
            [subscriber sendCompleted];
        });

        return nil;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    [self prepareViewsForOrientation:io];

    BNRItem *item = self.item;

    self.nameField.text = item.itemName;
    self.serialNumberField.text = item.serialNumber;
    self.valueField.text = [NSString stringWithFormat:@"%d", item.valueInDollars];

    // You need a NSDateFormatter that will turn a date into a simple date string
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }

    // Use filtered NSDate object to set dateLabel contents
    self.dateLabel.text = [dateFormatter stringFromDate:item.dateCreated];

    NSString *itemKey = self.item.itemKey;
    if (itemKey) {
        // Get image for image key from the image store
        UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:itemKey];

        // Use that image to put on the screen in imageView
        self.imageView.image = imageToDisplay;
    } else {
        // Clear the imageView
        self.imageView.image = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Clear first responder
    [self.view endEditing:YES];

    // "Save" changes to item
    BNRItem *item = self.item;
    item.itemName = [self pinyinWithString:self.nameField.text];
    item.serialNumber = self.serialNumberField.text;
    item.valueInDollars = [self.valueField.text intValue];
}

- (NSString *)pinyinWithString:(NSString *)string {
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    CFMutableStringRef stringRef = (__bridge CFMutableStringRef)(mutableString);
    CFStringTransform(stringRef, NULL, kCFStringTransformToLatin, NO);
    return mutableString;
}

- (void)prepareViewsForOrientation:(UIInterfaceOrientation)orientation
{
    // Is it an iPad? No preparation necessary
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return;
    }

    // Is it landscape?
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.imageView.hidden = YES;
        self.cameraButton.enabled = NO;
    } else {
        self.imageView.hidden = NO;
        self.cameraButton.enabled = YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [self prepareViewsForOrientation:toInterfaceOrientation];
}

- (void)setItem:(BNRItem *)item
{
    _item = item;
    self.navigationItem.title = _item.itemName;
}

- (void)save:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (void)cancel:(id)sender
{
    // If the user cancelled, then remoce the BNRItem from the store
    [[BNRItemStore sharedStore] removeItem:self.item];

    [self.presentingViewController dismissViewControllerAnimated:YES completion:self.dismissBlock];
}

- (IBAction)takePicture:(id)sender
{
    if ([self.imagePickerPopover isPopoverVisible]) {
        // If the popover is already up, get rid of it
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
        return;
    }

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

    // If the device ahs a camera, take a picture, otherwise,
    // just pick from the photo library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.delegate = self;

    // Place image picker on the screen
    // Check for iPad device before instantiating the popover controller
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // Create a new popover controller that will display the imagePicker
        self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];

        self.imagePickerPopover.delegate = self;

        // Display the popover controller; sender
        // is the camera bar button item
        [self.imagePickerPopover presentPopoverFromBarButtonItem:sender
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:NULL];
    }
}

- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *oldKey = self.item.itemKey;
    
    // Did the item already have an image?
    if (oldKey) {
        // Delete the old image
        [[BNRImageStore sharedStore] deleteImageForKey:oldKey];
    }
    
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
//    NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
//    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
//                                                  context:nil
//                                                  options:options];
//    
//    CGRect bounds = CGRectZero;
//    NSArray *features =
//    [faceDetector featuresInImage:[CIImage imageWithCGImage:[image CGImage]] options:nil];
//    
//    UIImage *face;
//    for (CIFaceFeature *feature in features) {
//        CGRect faceRect = CGRectUnion(bounds, feature.bounds);
//        CGImageRef faceRef = CGImageCreateWithImageInRect(image.CGImage, faceRect);
//        face = [UIImage imageWithCGImage:faceRef];
//        CGImageRelease(faceRef);
//    }
    
    
    //this is the translation from the CIImage coordinates to the UIKit coordinates
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    self.transformToUIKit = CGAffineTransformTranslate(transform, 0, -image.size.height);
    
    
    //a context and our image to get started!
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage * coreImage = 	[[CIImage alloc] initWithImage:image];
    
    
    //TODO: 14 create a NSDictionary with the key CIDetectorAccuracy set to CIDetectorAccuracyHigh
    NSDictionary * detectorOptions = @{CIDetectorAccuracy:CIDetectorAccuracyHigh};
    
    
    //TODO: 15 create a CIDetector of type CIDetectorTypeFace
    //HINT: use the context from the top and the detectorOptions you just created
    CIDetector * detector =	[CIDetector detectorOfType:CIDetectorTypeFace context:context options:detectorOptions];
    
    
    //TODO: 16 get all CIFaceFeatures the detector can find in the coreImage
    //HINT: use -featuresInImage:
    NSArray * foundFaces = [detector featuresInImage:coreImage];
    
    
    
    //TODO: 17 loop over the CIFaceFeatures and mark each face you found with the -addRectangleFromCGRect:toView:withColor: method
    //HINT: the position of the face can be found in the bounds-property
    
    //TODO: 18 Now mark the left and right eye as well as the mouth. (also in the loop)
    //HINT: use leftEyePosition, rightEyePosition, mouthPosition as well as -addCircleAroundPoint:toView:withColor:andWidth:
    
    for (CIFaceFeature * feature in foundFaces) {
        CGRect translatedRect = CGRectApplyAffineTransform(feature.bounds, self.transformToUIKit);
        CGRect bounds = CGRectZero;
        CGRect faceRect = CGRectUnion(bounds, translatedRect);
        CGImageRef faceRef = CGImageCreateWithImageInRect(image.CGImage, translatedRect);
        image = [UIImage imageWithCGImage:faceRef];
        CGImageRelease(faceRef);
//        CGRect translatedRect = CGRectApplyAffineTransform(feature.bounds, transformToUIKit);
//        
//        UIView * newView = [[UIView alloc] initWithFrame:translatedRect];
//        newView.layer.cornerRadius = 10;
//        newView.alpha = 0.3;
//        newView.backgroundColor = [UIColor redColor];
//        [self.view addSubview:newView];
        
//        [self addRectangleFromCGRect:feature.bounds toView:view withColor:[UIColor redColor]];
        
//        [self addCircleAroundPoint:feature.leftEyePosition toView:view withColor:[UIColor greenColor] andWidth:20];
//        
//        [self addCircleAroundPoint:feature.rightEyePosition toView:view withColor:[UIColor greenColor] andWidth:20];
//        
//        [self addCircleAroundPoint:feature.mouthPosition toView:view withColor:[UIColor blueColor] andWidth:40];
    }
    
    
    
    
    [self.item setThumbnailFromImage:image];//image];
    
    // Store the image in the BNRImageStore for this key
    [[BNRImageStore sharedStore] setImage:image /*mage*/ forKey:self.item.itemKey];
    
    // Put that image onto the screen in our image view
     self.imageView.image = image;//image;
    
    // Do I have a popover?
    if (self.imagePickerPopover) {
        
        // Dismiss it
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        
        // Dismiss the modal image picker
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    self.imagePickerPopover = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)applicationResigningActive:(NSNotification *)note {
    // Add blur effect
    if (!blurLayer) {
        blurLayer = [[CALayer alloc] init];
        blurLayer.frame = self.navigationController.view.bounds;
        blurLayer.backgroundColor = [UIColor yellowColor].CGColor;
        float scale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, scale);
        [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:NO];
        __block UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage,
                                                           CGRectMake(blurLayer.frame.origin.x * scale,
                                                                      blurLayer.frame.origin.y * scale,
                                                                      blurLayer.frame.size.width * scale,
                                                                      blurLayer.frame.size.height * scale));
        image = [UIImage imageWithCGImage:imageRef];
        image = [UIImageEffects imageByApplyingLightEffectToImage:image];
        
        blurLayer.contents = (__bridge id)(image.CGImage);
        CFRelease(imageRef);
    }
    
    [self.navigationController.view.layer addSublayer:blurLayer];
    shouldIgnoreSnapshot = NO;
    if (shouldIgnoreSnapshot) {
        [[UIApplication sharedApplication] ignoreSnapshotOnNextApplicationLaunch];
    }
}

- (void)applicationBecameActive:(NSNotification *)note {
    // Remove blur effect if there's any
    if (blurLayer.superlayer == self.navigationController.view.layer) {
        [blurLayer removeFromSuperlayer];
    }
}


/**
 *  Adds a rectangle-view to the passed view
 *
 *  @param rect  the dimensions and position of the new rectangle
 *  @param view  the parent-view
 *  @param color the color of the rectangle (will have an alpha-value of 0.3)
 */
- (void) addRectangleFromCGRect:(CGRect)rect toView:(UIView *) view withColor:(UIColor *) color
{
    CGRect translatedRect = CGRectApplyAffineTransform(rect, self.transformToUIKit);
    
    UIView * newView = [[UIView alloc] initWithFrame:translatedRect];
    newView.layer.cornerRadius = 10;
    newView.alpha = 0.3;
    newView.backgroundColor = color;
    [view addSubview:newView];
}

/**
 *  adds a circle-view to the passed view
 *
 *  @param point the center of the circle
 *  @param view  the parent-view
 *  @param color the color of the circle (will have an alpha-value of 0.3)
 *  @param width the diameter of the circle
 */
- (void) addCircleAroundPoint:(CGPoint) point toView:(UIView *) view withColor:(UIColor *) color andWidth:(NSInteger) width
{
    CGPoint translatedPoint = CGPointApplyAffineTransform(point, self.transformToUIKit);
    CGRect circleRect = CGRectMake(translatedPoint.x-width/2, translatedPoint.y-width/2, width, width);
    
    UIView * circleView = [[UIView alloc] initWithFrame:circleRect];
    circleView.layer.cornerRadius = width/2;
    circleView.alpha = 0.7;
    circleView.backgroundColor = color;
    [view addSubview:circleView];
}


@end
