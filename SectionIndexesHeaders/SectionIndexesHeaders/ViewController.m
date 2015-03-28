//
//  ViewController.m
//  SectionIndexesHeaders
//
//  Created by Hanguang on 3/10/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *contentArray;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *sectionTitles;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self debut];
}

- (void)debut {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Integrate search bar in table view
    NSMutableArray *mutableArray = [[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles] mutableCopy];
    [mutableArray insertObject:UITableViewIndexSearch atIndex:0];
    self.sectionTitles = [mutableArray copy];
    
    // Setup source array
    self.contentArray = @[@"As", @"longtime@", @"readers", @"of", @"NSHipster", @"doubtless", @"have",  @"already", @"guessed",
                          @"the", @"process", @"of",
                          @"generating", @"that", @"alphabetical", @"list", @"is", @"not", @"something", @"you", @"would", @"want",
                          @"to", @"have", @"means", @"something", @"alphabetically", @"sorted", @"what", @"alphabet", @"generate",
                          @"be", @"even", @"meant", @"varies", @"wildly", @"across", @"different", @"locales"];
    [self setObjects:self.contentArray];
}

#pragma mark - Table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.sections[indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Indexed section delegates
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return [self.sectionTitles indexOfObject:title];
//    if (title == UITableViewIndexSearch) {
//        return 0;
//    } else {
//        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//    }
}

- (void)setObjects:(NSArray *)objects {
    // Selector for the model object, for instance [object name]
    SEL selector = @selector(description);
    
    // Return localized section titles count
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    
    // Add array for every section
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    // Using selector to determine which section should object to be added
    for (id object in objects) {
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:selector];
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    // Since we have all objects setup, it makes sense to use the selector to sort the rows in each section as well
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        [mutableSections replaceObjectAtIndex:idx withObject:
         [[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }
    
    self.sections = [mutableSections copy];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
