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

@interface TCSBleuContentViewController ()
@property (strong, nonatomic) NSOperationQueue *opQueue;
@property (weak, nonatomic) UILabel *accuracyLabel;
- (void)loadURLs:(NSArray *)URLs;

@end

@implementation TCSBleuContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.opQueue = [[NSOperationQueue alloc] init];
	self.opQueue.name = @"com.twocanoes.bleu.contentviewcontroller";

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *configURL = [defaults stringForKey:@"bleuConfigURL"];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:configURL]];
	UILabel *accuracyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 20., 100., 20.)];
	accuracyLabel.backgroundColor = [UIColor whiteColor];
	accuracyLabel.text = @"Accuracy";
	[self.view addSubview:accuracyLabel];
	self.accuracyLabel = accuracyLabel;
	
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

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	[self.accuracyLabel removeFromSuperview];
	
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
		CLBeacon *beacon = note.userInfo[@"beacon"];
		DLog(@"%f", beacon.accuracy);
		NSUInteger index = [note.userInfo[@"index"] unsignedIntegerValue];
		if (index == 3) return; //ignore "unknown" proximity
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			self.selectedIndex = index;
			self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
		}];
	}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
