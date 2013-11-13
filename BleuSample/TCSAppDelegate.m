//
//  TCSAppDelegate.m
//  BeaconBump
//
//  Created by Tim Perfitt on 10/4/13.
//  Copyright (c) 2013 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSAppDelegate.h"
#import "TCSBleuBeaconManager.h"
#import "TestFlight.h"

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
	[TestFlight takeOff:@"8523b27e-0201-42c6-8ace-5f7c1e06cd77"];

    return YES;
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
}
- (void)applicationWillResignActive:(UIApplication *)application{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    

    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   }

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
