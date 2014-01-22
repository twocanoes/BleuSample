//
//  TCSAppDelegate.m
//  BeaconBump
//
//  Created by Tim Perfitt on 10/4/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSAppDelegate.h"
#import "TCSBleuBeaconManager.h"

@interface TCSAppDelegate (){
}

@end


@implementation TCSAppDelegate 

+ (void)initialize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:@{@"bleuConfigURL": @"https://dl.dropboxusercontent.com/u/5770480/default.plist"}];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}


@end
