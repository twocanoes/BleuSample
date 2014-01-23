//
//  TCSBleuContentViewController.h
//  BleuUser
//
//  Created by Steve Brokaw on 10/18/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 A simple view controller to present three URLs based on the proximity to a beacon.
 This view fetches a configuration file from a plist hosted on a web server.
 Then it starts region monitoring for beacons defined in the plist.
 */
@interface TCSBleuContentViewController : UITabBarController <CLLocationManagerDelegate>

@end
