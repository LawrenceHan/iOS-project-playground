//
//  ViewController.m
//  Contacts
//
//  Created by Hanguang on 3/15/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

#import "ContactsViewController.h"
#import "Contacts-Swift.h"

@interface ContactsViewController ()

@property (nonatomic, readonly, strong) NSMutableArray *contacts;

@end

@implementation ContactsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        Contact *c1 = [[Contact alloc] initWithContactName:@"Johnny Appleseed"];
        Contact *c2 = [[Contact alloc] initWithContactName:@"Paul Bunyan"];
        Contact *c3 = [[Contact alloc] initWithContactName:@"Calamity Jane"];
        _contacts = [NSMutableArray arrayWithArray:@[c1, c2, c3]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Contact *contact = self.contacts[indexPath.row];
    
    cell.textLabel.text = contact.name;
    
    return cell;
}



@end
