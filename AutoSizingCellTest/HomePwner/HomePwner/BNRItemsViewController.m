//
//  BNRItemsViewController.m
//  HomePwner
//
//  Created by John Gallagher on 1/7/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRItemsViewController.h"
#import "BNRDetailViewController.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRCell.h"
#import "AutoSizingCell.h"

#define SYSTEM_VERSION                              ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS8_OR_ABOVE                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))

@interface BNRItemsViewController ()
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) AutoSizingCell *prototypeCell;

- (void)populateDataSource;

- (void)addSingleItemToDataSource;

@end

@implementation BNRItemsViewController

- (instancetype)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Homepwner";

        // Create a new bar button item that will send
        // addNewItem: to BNRItemsViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:self
                                                                             action:@selector(addNewItem:)];

        // Set this bar button item as the right item in the navigationItem
        navItem.rightBarButtonItem = bbi;

        navItem.leftBarButtonItem = self.editButtonItem;
    }
    
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    UINib *nib = [UINib nibWithNibName:@"BNRCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:@"BNRCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AutoSizingCell" bundle:nil] forCellReuseIdentifier:@"AutoSizingCell"];
    
    [self populateDataSource];
    self.offscreenCells = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

- (AutoSizingCell *)prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AutoSizingCell class])];
    }
    
    return _prototypeCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];//[[[BNRItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get a new or recycled cell
    //BNRCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNRCell" forIndexPath:indexPath];
    AutoSizingCell *cell = [tableView dequeueReusableCellWithIdentifier:
                            NSStringFromClass([AutoSizingCell class])];

    // Set the text on the cell with the description of the item
    // that is at the nth index of items, where n = row this cell
    // will appear in on the tableview
    
    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(AutoSizingCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray *items = [[BNRItemStore sharedStore] allItems];
//    BNRItem *item = items[indexPath.row];
    NSDictionary *dataSourceItem = [self.dataSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = [dataSourceItem valueForKey:@"title"];//item.itemName;
    cell.quoteLabel.text = [dataSourceItem valueForKey:@"body"];//item.serialNumber;
    //cell.valueLabel.text = @"$11";//[NSString stringWithFormat:@"$%d", item.valueInDollars];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRDetailViewController *detailViewController = [[BNRDetailViewController alloc] initForNewItem:NO];

    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *selectedItem = items[indexPath.row];

    // Give detail view controller a pointer to the item object in row
    detailViewController.item = selectedItem;

    // Push it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:detailViewController
                                         animated:YES];
}

- (void)   tableView:(UITableView *)tableView
  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
   forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *items = [[BNRItemStore sharedStore] allItems];
        BNRItem *item = items[indexPath.row];
        [[BNRItemStore sharedStore] removeItem:item];

        // Also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)   tableView:(UITableView *)tableView
  moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
         toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:sourceIndexPath.row
                                        toIndex:destinationIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IOS8_OR_ABOVE) {
        return UITableViewAutomaticDimension;
    }
    
    //self.prototypeCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
    
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];

    [self.prototypeCell updateConstraintsIfNeeded];
    [self.prototypeCell layoutIfNeeded];
   
    // Get the actual height required for the cell
    CGFloat height = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    NSLog(@"Height: %f", height);
    return height;
}

- (IBAction)addNewItem:(id)sender
{
    // Create a new BNRItem and add it to the store
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];

    BNRDetailViewController *detailViewController = [[BNRDetailViewController alloc] initForNewItem:YES];

    detailViewController.item = newItem;

    detailViewController.dismissBlock = ^{
        [self.tableView reloadData];
    };

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];

    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:NULL];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (void)populateDataSource {
    
    NSArray *fontFamilies = [NSArray arrayWithArray:[UIFont familyNames]];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[fontFamilies count]];
    
    for ( NSString *familyName in fontFamilies ) {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:familyName, @"title",
                                    [self randomLorumIpsum], @"body",
                                    @"", @"element2",
                                    @"", @"element3",
                                    @"", @"element4",
                                    nil];
        [result addObject:dictionary];
    }
    
    self.dataSource = result;
    
}

- (void)addSingleItemToDataSource {
    
    NSArray *fontFamilies = [NSArray arrayWithArray:[UIFont familyNames]];
    
    int r = arc4random() % [fontFamilies count];
    NSString *familyName = [fontFamilies objectAtIndex:r];
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:familyName, @"title",
                                [self randomLorumIpsum], @"body",
                                @"", @"element2",
                                @"", @"element3",
                                @"", @"element4",
                                nil];
    
    [self.dataSource addObject:dictionary];
    
}

- (NSString *)randomLorumIpsum {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales. Vestibulum ut est id mauris ultrices gravida. Nulla malesuada metus ut erat malesuada, vitae ornare neque semper. Aenean a commodo justo, vel placerat odio. Curabitur vitae consequat tortor. Aenean eu magna ante. Integer tristique elit ac augue laoreet, eget pulvinar lacus dictum. Cras eleifend lacus eget pharetra elementum. Etiam fermentum eu felis eu tristique. Integer eu purus vitae turpis blandit consectetur. Nulla facilisi. Praesent bibendum massa eu metus pulvinar, quis tristique nunc commodo. Ut varius aliquam elit, a tincidunt elit aliquam non. Nunc ac leo purus. Proin condimentum placerat ligula, at tristique neque scelerisque ut. Suspendisse ut congue enim. Integer id sem nisl. Nam dignissim, lectus et dictum sollicitudin, libero augue ullamcorper justo, nec consectetur dolor arcu sed justo. Proin rutrum pharetra lectus, vel gravida ante venenatis sed. Mauris lacinia urna vehicula felis aliquet venenatis. Suspendisse non pretium sapien. Proin id dolor ultricies, dictum augue non, euismod ante. Vivamus et luctus augue, a luctus mi. Maecenas sit amet felis in magna vestibulum viverra vel ut est. Suspendisse potenti. Morbi nec odio pretium lacus laoreet volutpat sit amet at ipsum. Etiam pretium purus vitae tortor auctor, quis cursus metus vehicula. Integer ultricies facilisis arcu, non congue orci pharetra quis. Vivamus pulvinar ligula neque, et vehicula ipsum euismod quis.";
    
    // Split lorum ipsum words into an array
    //
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    // Randomly choose words for variable length
    //
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(3, r); // no less than 3 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    // Array to string. Adding '!!!' to end of string to ensure all text is visible.
    //
    return [NSString stringWithFormat:@"%@!!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
    
}

@end
