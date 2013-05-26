//
//  StationsViewController.m
//  MindTheCheckOut
//
//  Created by Tom K on 5/7/13.
//  Copyright (c) 2013 Tom Kraina. All rights reserved.
//

#import "StationsViewController.h"
#import "ReminderViewController.h"
#import "RejseplanenStationFetcher.h"
#import "Recents.h"
#import "Reminder.h"

typedef NS_ENUM(NSInteger, StationsViewControllerSections) {
    StationsViewControllerSectionReminders,
    StationsViewControllerSectionRecents,
    StationsViewControllerNumberOfSection
};

@interface StationsViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *stations;
@property (strong, nonatomic) NSArray *reminders;
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
    
    self.searchBar.placeholder = NSLocalizedStringFromTable(@"SearchBar - Placeholder", @"StationsViewController", @"");
    
    self.stations = [[Recents defaultRecents] allRecents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadReminders];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tableView != self.tableView ? 1 : StationsViewControllerNumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return [self.stations count];
    }
    
    switch (section) {
        case StationsViewControllerSectionRecents:
            return [self.stations count];
        
        case StationsViewControllerSectionReminders:
            return [self.reminders count];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"StationCell";
    // must be called on self.tableView
    // more info: http://stackoverflow.com/questions/8066668/ios-5-uisearchdisplaycontroller-crash
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (tableView != self.tableView || (tableView == self.tableView && indexPath.section == StationsViewControllerSectionRecents)) {
        NSDictionary *object = self.stations[indexPath.row];
        cell.textLabel.text = object[kStationName];
    }
    else {
        Reminder *reminder = self.reminders[indexPath.row];
        cell.textLabel.text = [[[reminder.reminder.alarms lastObject] structuredLocation] title];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        switch (section) {
            case StationsViewControllerSectionRecents:
                return NSLocalizedStringFromTable(@"Table - Recents section - Header", @"StationsViewController", @"");
            
            case StationsViewControllerSectionReminders:
                return NSLocalizedStringFromTable(@"Table - Reminders section - Header", @"StationsViewController", @"");
                
            default:
                return nil;
        }
    }
    else {
        return nil;
    }
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}

#pragma mark - Reminders methods

- (void)reloadReminders
{
    [Reminder allReminders:^(NSArray *reminders) {
        self.reminders = reminders;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Alert - Title - Can't load reminders", @"StationsViewController", @"") message:[error localizedFailureReason] delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Alert - Cancel", @"StationsViewController", @"") otherButtonTitles:nil];
        [alert show];
    }];
}

#pragma mark - UISearchBarDelegate & UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    // TODO: activity indicator
    StationFetcher *fetcher = [RejseplanenStationFetcher defaultFetcher];
    [fetcher findByName:searchString completed:^(NSArray *stations) {
        self.stations = stations;
        
        // Refresh result's table view
        [controller.searchResultsTableView reloadData];
        
        // TODO: insert data animated ?
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Alert - Title", @"StationsViewController", @"") message:[error localizedFailureReason] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Alert - Cancel Button", @"StationsViewController", @"") otherButtonTitles:nil];
        [alert show];
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
            
            NSDictionary *object = self.stations[indexPath.row];
            [[segue destinationViewController] setDetailItem:object];
            [[Recents defaultRecents] addObject:object];
        }
        else if (indexPath.section == StationsViewControllerSectionRecents) {
            NSDictionary *object = self.stations[indexPath.row];
            [[segue destinationViewController] setDetailItem:object];
            [[Recents defaultRecents] addObject:object];
        }
        else {
            Reminder *reminder = self.reminders[indexPath.row];
            [[segue destinationViewController] setReminder:reminder];
        }
    }
}

@end
