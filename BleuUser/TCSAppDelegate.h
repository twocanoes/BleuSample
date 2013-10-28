//
//  TCSAppDelegate.h
//  BeaconBump
//
//  Created by Tim Perfitt on 10/4/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TCSAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@end
