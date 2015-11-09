//
//  Created by Colin Eberhardt on 23/04/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

#import "RWTSearchResultsViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CETableViewBindingHelper.h"
#import "RWTSearchResultsTableViewCell.h"

@interface RWTSearchResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (nonatomic, strong) RWTSearchResultsViewModel *viewModel;
@property (nonatomic, strong) CETableViewBindingHelper *bindingHelper;

@end

@implementation RWTSearchResultsViewController

- (instancetype)initWithViewModel:(RWTSearchResultsViewModel *)viewModel {
    if (self = [super init]) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
}

- (void)bindViewModel {
    self.title = self.viewModel.title;
    UINib *nib = [UINib nibWithNibName:@"RWTSearchResultsTableViewCell" bundle:nil];
    self.bindingHelper = [CETableViewBindingHelper
                          bindingHelperForTableView:self.searchResultsTable
                          sourceSignal:RACObserve(self.viewModel, searchResults)
                          selectionCommand:nil
                          templateCell:nib];
    self.bindingHelper.delegate = self;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSArray *cells = [self.searchResultsTable visibleCells];
    for (RWTSearchResultsTableViewCell *cell in cells) {
        CGFloat originY = cell.frame.origin.y;
        CGFloat offsetY = self.searchResultsTable.contentOffset.y;
        CGFloat value = -40 + (originY - offsetY) / 5;
        NSLog(@"-40 + (cell origin y:%g - tableview offset y: %g) / 5 = %g", originY, offsetY, value);
        [cell setParallax:value];
    }
}

@end
