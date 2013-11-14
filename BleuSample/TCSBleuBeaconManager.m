//
//  TCSBleuURLMapper.m
//  Bleu
//
//  Created by Steve Brokaw on 10/15/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TCSBleuBeaconManager.h"

NSString * const TCSDidEnterBleuRegionNotification = @"TCSDidEnterBleuRegionNotification";
NSString * const TCSDidExitBleuRegionNotification = @"TCSDidExitBleuRegionNotification";
NSString * const TCSBleuRangingNotification = @"TCSBleuRangingNotification";

@interface TCSBleuBeaconManager()
@property (nonatomic, strong) NSMutableDictionary *URLStore;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, readwrite) NSString *defaultURL;
@property (strong, readwrite) NSString *entryText;
@property (strong, readwrite) NSString *exitText;

@end

@implementation TCSBleuBeaconManager
@synthesize URLStore = _URLStore;

+ (instancetype)sharedManager {
	static TCSBleuBeaconManager *_sharedManager;
	
	if (!_sharedManager) {
		_sharedManager = [[[self class] alloc] init];
		_sharedManager->_URLStore = [NSMutableDictionary dictionary];
		NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
			CLLocationManager *locationManager = [[CLLocationManager alloc] init];
			locationManager.delegate = _sharedManager;
			//These two settings sacrifice battery life for a smoother demo experience.
			[locationManager disallowDeferredLocationUpdates];
			locationManager.pausesLocationUpdatesAutomatically = NO;
			
			_sharedManager->_locationManager = locationManager;
		}];
		[[NSOperationQueue mainQueue] addOperation:op];
		[op waitUntilFinished];
		
	}
	return _sharedManager;
}


- (NSArray *)URLsForUUID:(NSString *)UUID major:(NSString *)major minor:(NSString *)minor
{

	NSString *key = [[NSString stringWithFormat:@"%@:%@:%@", UUID, major, minor] uppercaseString];
	@synchronized(self) {
		return self.URLStore[key];
	}
}

- (void)addMappingWithDictionary:(NSDictionary *)mappingDict
{
	NSString *UUID = [mappingDict[@"proximityUUID"] uppercaseString];
	NSDictionary *URLs = mappingDict[@"URLs"];
	self.defaultURL = mappingDict[@"defaultURL"];
	self.entryText = mappingDict[@"entryText"];
	self.exitText = mappingDict[@"exitText"];
	NSArray *majorKeys = [URLs allKeys];
	for (NSString *majorKey in majorKeys) {
		NSDictionary *minorStations = URLs[majorKey];
		NSArray *minorKeys = [minorStations allKeys];
		for (NSString *minorKey in minorKeys) {
			NSArray *stationURLs = minorStations[minorKey];
			NSString *mappingKey = [NSString stringWithFormat:@"%@:%@:%@", UUID, majorKey, minorKey];
			@synchronized(self) {
				self.URLStore[mappingKey] = stationURLs;
			}
		}
	}
}

- (void)beginRegionMonitoring
{
	NSArray *regionKeys;
	@synchronized(self) {
		regionKeys = [self.URLStore allKeys];
	}
	for (NSString *key in regionKeys) {
		NSArray *regionTriplet = [key componentsSeparatedByString:@":"];
		NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:regionTriplet[0]];
		CLBeaconMajorValue major = [(NSString *)regionTriplet[1] integerValue];
		CLBeaconMinorValue minor = [(NSString *)regionTriplet[2] integerValue];
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:major minor:minor identifier:key];
			[self.locationManager startMonitoringForRegion:region];
		}];
	}
	
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	DLog(@"Entered Region");
	UIApplicationState state = [[UIApplication sharedApplication] applicationState];
	switch (state) {
		case UIApplicationStateInactive:
		case UIApplicationStateActive:
			[[NSNotificationCenter defaultCenter] postNotificationName:TCSDidEnterBleuRegionNotification
																object:self
															  userInfo:@{@"region": region}];

			break;
		case UIApplicationStateBackground: {
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertBody = self.entryText;
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
		default:
			break;
	}

}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
	DLog(@"Exited Region");
	UIApplicationState state = [[UIApplication sharedApplication] applicationState];
	switch (state) {
		case UIApplicationStateInactive:
		case UIApplicationStateActive:
			[[NSNotificationCenter defaultCenter] postNotificationName:TCSDidExitBleuRegionNotification
																object:self
															  userInfo:@{@"region": region}];

			break;
		case UIApplicationStateBackground:{
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.alertBody = self.exitText;
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
		default:
			break;
	}
	[manager startMonitoringForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
	DLog(@"Ranged %lu Beacons", (unsigned long)[beacons count]);
	if ([beacons count] > 0) {
		//Doesn't deal gracefully with multiple beacons in range
		CLBeacon *closestBeacon = beacons[0];
		NSNumber *index;
		switch (closestBeacon.proximity) {
			case CLProximityFar:
				index = @0;
				break;
			case CLProximityNear:
				DLog(@"Near");
				index = @1;
				break;
			case CLProximityImmediate:
				DLog(@"Immediate");
				index = @2;
				break;
			case CLProximityUnknown:
				DLog(@"Unknown");
				index = @3;
				break;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:TCSBleuRangingNotification object:self userInfo:@{@"index": index, @"beacon": closestBeacon}];
	}
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
	CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
	switch (state) {
		case CLRegionStateInside:
			DLog(@"Determined Inside State for Beacon %@", beaconRegion.identifier);
			if ([CLLocationManager isRangingAvailable]) {
				[self.locationManager startRangingBeaconsInRegion:beaconRegion];
			}
			break;
		case CLRegionStateOutside:
			DLog(@"Determined Outside State for Beacon %@", beaconRegion.identifier);
			if ([CLLocationManager isRangingAvailable]) {
				[self.locationManager stopRangingBeaconsInRegion:beaconRegion];
			}
			break;
		case CLRegionStateUnknown:
			DLog(@"Determined Unknown State for Beacon %@", beaconRegion.identifier);
			break;
	}
}


@end
