//
//  BNRCollectionViewController.m
//  HomePwner
//
//  Created by Hanguang on 9/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRCollectionViewController.h"
#import "BNRCollectionViewCell.h"
#import "BNRFLowLayout.h"
#import "BNRDynamicFlowLayout.h"
#import "BNRCollectionLayout.h"
#import "BNRDetailCollectionViewController.h"

@interface BNRCollectionViewController () <BNRFlowLayoutDelegate>
@property (nonatomic, assign) NSInteger count;

@end

@implementation BNRCollectionViewController {
    BNRDynamicFlowLayout *dynamicFlowLayout;
}

static NSString * const reuseIdentifier = @"BNRCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[BNRCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
//    BNRCollectionLayout *layout = [[BNRCollectionLayout alloc] init];
//    self.collectionView.collectionViewLayout = layout;
//    
//    [self performSelector:@selector(userDidPressAddButton:) withObject:nil afterDelay:3];
}

- (void)userDidPressAddButton:(id)sender {
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.count inSection:0]]];
        self.count++;
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toInteractive"]) {
        BNRDetailCollectionViewController *cc = segue.destinationViewController;
        cc.useLayoutToLayoutNavigationTransitions = YES;
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BNRCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = [UIColor magentaColor];
    NSString *imageName = [NSString stringWithFormat:@"%ld.jpg", indexPath.row % 5];
    [cell setImage:[UIImage imageNamed:imageName]];
    cell.titleLabel.text = [NSString stringWithFormat:@"No.%ld", indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *supplementaryViewIdentifier = @"supplementaryViewIdentifier";
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                              withReuseIdentifier:supplementaryViewIdentifier
                                                     forIndexPath:indexPath];
}

#pragma mark - Flow layout delegate
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CGFloat randomHeight = 100 + (arc4random() % 140);
//    return CGSizeMake(100, randomHeight);
//}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(BNRFLowLayout *)layout heightForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat randomHeight = 100 + (arc4random() % 140);
    return randomHeight;
}

#pragma mark - Button methods
- (IBAction)changeLayout:(UIButton *)sender {
//    if (!dynamicFlowLayout) {
//        dynamicFlowLayout = [[BNRDynamicFlowLayout alloc] init];
//    }
//    BNRFLowLayout *layout = [[BNRFLowLayout alloc] init];
//    self.collectionView.collectionViewLayout = dynamicFlowLayout;
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
