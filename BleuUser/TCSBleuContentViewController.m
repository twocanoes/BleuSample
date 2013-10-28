//
//  TCSBleuContentViewController.m
//  BleuUser
//
//  Created by Steve Brokaw on 10/18/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TCSBleuContentViewController.h"
#import "TCSBleuBeaconManager.h"

NSString * const ConfigurationURL = @"https://dl.dropboxusercontent.com/u/5770480/default.plist";

@interface TCSBleuContentViewController ()
@property (strong, nonatomic) NSOperationQueue *opQueue;

- (void)loadURLs:(NSArray *)URLs;

@end

@implementation TCSBleuContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.opQueue = [[NSOperationQueue alloc] init];
	self.opQueue.name = @"com.twocanoes.bleu.contentviewcontroller";

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:ConfigurationURL]];
	
	NSURLResponse *response;
	//NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
	
	[NSURLConnection sendAsynchronousRequest:request queue:self.opQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if (!connectionError) {
				NSDictionary *config = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
				DLog(@"Config: %@", config);
				TCSBleuBeaconManager *manager = [TCSBleuBeaconManager sharedManager];
				[manager addMappingWithDictionary:config];
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				// This is hard-coded to match the beacons contained in the plist file above.
				NSArray *URLs = [manager URLsForUUID:@"e2c56db5-dffb-48d2-b060-d0f5a71096e0" major:@"1" minor:@"2"];
				[self loadURLs:URLs];
				[self registerNotifications];
				[manager beginRegionMonitoring];
			}];
		}
	}];

}

- (void)loadURLs:(NSArray *)URLs
{
	for (int i = 0; i < 3; i++) {
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:URLs[i]]];
			UIWebView *webView = (UIWebView *)((UIViewController *)self.viewControllers[i]).view;
			[webView loadRequest:request];
		}];
	}
}

- (void)registerNotifications
{
	[[NSNotificationCenter defaultCenter] addObserverForName:TCSDidEnterBleuRegionNotification object:nil queue:self.opQueue usingBlock:^(NSNotification *note) {
		NSDictionary *info = [note userInfo];
		CLBeaconRegion *beaconRegion = info[@"region"];
		DLog(@"Received Enter Notificationf for beacon %@", beaconRegion.identifier);
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered Region" message:@"You have entered the region for an iBeacon" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}];
	}];
	[[NSNotificationCenter defaultCenter] addObserverForName:TCSDidExitBleuRegionNotification object:nil queue:self.opQueue usingBlock:^(NSNotification *note) {
		NSDictionary *info = [note userInfo];
		CLBeaconRegion *beaconRegion = info[@"region"];
		DLog(@"Received Exit Notificationf for beacon %@", beaconRegion.identifier);
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exited Region" message:@"You have exited the region for an iBeacon" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}];
	}];
	[[NSNotificationCenter defaultCenter] addObserverForName:TCSBleuRangingNotification object:nil queue:self.opQueue usingBlock:^(NSNotification *note) {
		NSUInteger index = [note.userInfo[@"index"] unsignedIntegerValue];
		if (index == 3) return; //ignore "unknown" proximity
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			self.selectedIndex = index;
		}];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
