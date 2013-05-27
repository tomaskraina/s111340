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
@property (strong, nonatomic) NSArray *recents;
@property (strong, nonatomic) NSArray *reminders;
@property (strong, nonatomic) NSArray *foundStations;
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
    
    self.recents = [[Recents defaultRecents] allRecents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.searchDisplayController.isActive) {
        [self reloadReminders];
    }
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
    self.recents = nil;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [self.reminders count] ? StationsViewControllerNumberOfSection : 1;
    }
    else {
        return 1;
    }
        
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return [self.foundStations count];
    }
    
    if ([self.reminders count] && section == StationsViewControllerSectionReminders) {
        return [self.reminders count];
    }
    else {
        return [self.recents count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"StationCell";
    // must be called on self.tableView
    // more info: http://stackoverflow.com/questions/8066668/ios-5-uisearchdisplaycontroller-crash
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (tableView != self.tableView) {
        NSDictionary *object = self.foundStations[indexPath.row];
        cell.textLabel.text = object[kStationName];
    }
    else if ([self.reminders count] && indexPath.section == StationsViewControllerSectionReminders) {
        Reminder *reminder = self.reminders[indexPath.row];
        cell.textLabel.text = [[[reminder.reminder.alarms lastObject] structuredLocation] title];
    }
    else {
        NSDictionary *object = self.recents[indexPath.row];
        cell.textLabel.text = object[kStationName];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return nil;
    }
    else if ([self.reminders count] && section == StationsViewControllerSectionReminders) {
        return NSLocalizedStringFromTable(@"Table - Reminders section - Header", @"StationsViewController", @"");
    }
    else {
        return NSLocalizedStringFromTable(@"Table - Recents section - Header", @"StationsViewController", @"");
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
        NSString *messsage = [NSString stringWithFormat:@"%@. %@", [error localizedDescription], [error localizedRecoverySuggestion]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Alert - Title - Can't load reminders", @"StationsViewController", @"") message:messsage delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Alert - Cancel Button", @"StationsViewController", @"") otherButtonTitles:nil];
        alert.tag = error.code;
        [alert show];
    }];
}

#pragma mark - UISearchBarDelegate & UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    StationFetcher *fetcher = [RejseplanenStationFetcher defaultFetcher];
    [fetcher findByName:searchString completed:^(NSArray *stations) {
        self.foundStations = stations;
        
        // Refresh result's table view
        [controller.searchResultsTableView reloadData];
        
    } error:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Alert - Title", @"StationsViewController", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Alert - Cancel Button", @"StationsViewController", @"") otherButtonTitles:nil];
        [alert show];
    }];
    
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.recents = [[Recents defaultRecents] allRecents];
    [self.tableView reloadData];
    
    [self reloadReminders];
}

#pragma mark - UIStoryboarSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath == nil) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            
            NSDictionary *object = self.foundStations[indexPath.row];
            [[segue destinationViewController] setDetailItem:object];
            [[Recents defaultRecents] addObject:object];
        }
        else if ([self.reminders count] && indexPath.section == StationsViewControllerSectionReminders) {
            Reminder *reminder = self.reminders[indexPath.row];
            [[segue destinationViewController] setReminder:reminder];
        }
        else {
            NSDictionary *object = self.recents[indexPath.row];
            [[segue destinationViewController] setDetailItem:object];
            [[Recents defaultRecents] addObject:object];
        }
    }
}

@end
