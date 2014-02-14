//
//  TCSMasterViewController.m
//  Admin
//
//  Created by Steve Brokaw on 1/17/14.
//  Copyright (c) 2014 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSBleuStationManager.h"
#import "TCSMasterViewController.h"
#import "TCSDetailViewController.h"

@interface TCSMasterViewController () {
    NSMutableArray *_objects;
}

@property TCSBleuStationManager *stationManager;
@end

@implementation TCSMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stationManager = [[TCSBleuStationManager alloc] init];
    self.stationManager.delegate = self;
    [self.stationManager scanForStations];
    NSLog(@"Build %i, v%s", TCSLibbleuBuildNumber, TCSLibbleuVersionNumber);
    _objects = [NSMutableArray array];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    TCSBleuStation *station = _objects[indexPath.row];
    if (station.name) {
        cell.textLabel.text = station.name;
    } else {
        cell.textLabel.text = station.hardwareName;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TCSBleuStation *station = _objects[indexPath.row];
        TCSDetailViewController *controller = [segue destinationViewController];
        [controller setStation:station];
        station.delegate = controller;
    }
}

#pragma mark TCSBleuStationManagerDelegate

- (void)stationManager:(TCSBleuStationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}
- (void)stationManager:(TCSBleuStationManager *)manager didDiscoverStation:(TCSBleuStation *)station
{
    [_objects addObject:station];
    NSInteger index = [_objects count] - 1;
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)stationManager:(TCSBleuStationManager *)manager didDisconnectStationWithIdentifier:(NSString *)hardwareName
{
    NSUInteger index = [_objects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TCSBleuStation *station = obj;
        if ([hardwareName isEqualToString:station.hardwareName]) {
            *stop = YES;
            return YES;
        } else {
            return NO;
        }
    }];
    if (index != NSNotFound) {
        [_objects removeObjectAtIndex:index];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}
@end
