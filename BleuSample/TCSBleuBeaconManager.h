//
//  TCSBleuURLMapper.h
//  Bleu
//
//  Created by Steve Brokaw on 10/15/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 This class is a singleton that serves as a delegate to CoreLocation and sends
 out notificatios as location events arrive. CoreLocation callbacks have to occurr
 on the main thread. This class has some guards to make that happen, but it is
 not completely debugged. If you have problems with receiving notifications,
 check whether you are causing a delegate to fire on a background thread.
 */
typedef NS_ENUM(NSUInteger, TCSProximityIndex){
    kImmediate = 0,
    kNear,
    kFar,
	kDefault
};

/*!
 Notification constants. The TCSBleuBeaconManager registeres as the delegate
 to CoreLocation, and turns delegate callbacks into notifications.
 
TCSBleuRangingNotification is called while the device is in the beacon region
 and changes proximity.
 */
extern NSString * const TCSDidEnterBleuRegionNotification;
extern NSString * const TCSDidExitBleuRegionNotification;
extern NSString * const TCSBleuRangingNotification;

@protocol CLLocationManagerDelegate;

@interface TCSBleuBeaconManager : NSObject <CLLocationManagerDelegate>
@property (strong, readonly) NSString *defaultURL;
+ (instancetype) sharedManager;

/*!
 @returns An NSArray containing three URLs. The URLs map to the three different
 proximity ranges. Generally, the view will extract the URLs and then register
 for the TCSBleuRangingNotification notification. When it receives the notification,
 it act on the proximity information by displaying the URL appropriate for the
 given proximity.
 
 Use one of the constants of type TCSProximityIndex to extract the correct url.
 @param UUID String representation of the proximityUUID for the beacon. All UUIDs
 are normalized into upper case versions.
 @param major String representation of the major identifier for the beacon
 @param minor String representation of the minor identifier for the beacon
 */
- (NSArray *)URLsForUUID:(NSString *)UUID major:(NSString *)major minor:(NSString *)minor;

/*!
 Adds a set of URLs to a station. Currently a station is uniquely defined by
 a combination of proximity UUID, major identifier, and minor identifier. You
 can set up multple beacons with the same info, but they will display the same
 set of URLS.
 
 @param mappingDict See the default.plist file for an example of how the
 mappingDict should be defined. The demo creates a dictionary from a plist
 dowloaded via URL.
 */
- (void)addMappingWithDictionary:(NSDictionary *)mappingDict;

/*
 Begins monitoring all the regions added with the addMappingsWithDictionary:
 There is currently no way to stop monitoring regions. Without going directly
 to CoreLocation.
 */
- (void)beginRegionMonitoring;

@end
