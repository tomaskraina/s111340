//
//  StationsViewController.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/7/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "StationsViewController.h"
#import "ReminderViewController.h"
#import "StationFetcher.h"
#import "Recents.h"

@interface StationsViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *stations;
@end

@implementation StationsViewController

#pragma mark - Properties



#pragma mark - UIViewController lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    self.searchBar.placeholder = NSLocalizedStringFromTable(@"SearchBar - Placeholder", @"StationsViewController", @"");
    
    self.stations = [[Recents defaultRecents] allRecents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
//    [self.stations insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - IBActions

- (IBAction)eraseHistory:(id)sender
{
    [[Recents defaultRecents] eraseRecents];
    self.stations = nil;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"StationCell";
    // must be called on self.tableView
    // more info: http://stackoverflow.com/questions/8066668/ios-5-uisearchdisplaycontroller-crash
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier];

    NSDictionary *object = self.stations[indexPath.row];
    cell.textLabel.text = object[kStationName];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



#pragma mark - UISearchBarDelegate & UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // TODO: activity indicator
    StationFetcher *fetcher = [StationFetcher defaultFetcher];
    [fetcher findByName:searchString completed:^(NSArray *stations) {
        self.stations = stations;
        
        // Refresh result's table view
        [controller.searchResultsTableView reloadData];
        
        // TODO: insert data animated
    }];
    
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.stations = [[Recents defaultRecents] allRecents];
    [self.tableView reloadData];
}

#pragma mark - UIStoryboarSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath == nil) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        }
        
        NSDictionary *object = self.stations[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
        
        // add to recents
        [[Recents defaultRecents] addObject:object];
    }
}

@end
