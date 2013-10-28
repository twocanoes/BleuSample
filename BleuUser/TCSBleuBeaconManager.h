//
//  TCSBleuURLMapper.h
//  Bleu
//
//  Created by Steve Brokaw on 10/15/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TCSProximityIndex){
    kImmediate = 0,
    kNear,
    kFar
};

extern NSString * const TCSDidEnterBleuRegionNotification;
extern NSString * const TCSDidExitBleuRegionNotification;
extern NSString * const TCSBleuRangingNotification;

@protocol CLLocationManagerDelegate;

@interface TCSBleuBeaconManager : NSObject <CLLocationManagerDelegate>

+ (instancetype) sharedManager;

/*!
 @returns An NSArray containing three URLs. Use one of the constants of type
 TCSProximityIndex to extract the correct url.
 */
- (NSArray *)URLsForUUID:(NSString *)UUID major:(NSString *)major minor:(NSString *)minor;

/*!
 Adds a set of URLs to a station. Currently a station is uniquely defined by
 a combination of proximity UUID, major identifier, and minor identifier. You
 can set up multple beacons with the same info, but they will display the same
 set of URLS.
 
 @param mappingDict See the default.plist file for an example of how the
 mappingDict should be defined.
 */
- (void)addMappingWithDictionary:(NSDictionary *)mappingDict;

- (void)beginRegionMonitoring;
@end
