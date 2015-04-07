//
//  SCAppDelegate.m
//  SCForceUpdater
//
//  Created by CocoaPods on 04/07/2015.
//  Copyright (c) 2014 Richard Szabo. All rights reserved.
//

#import <SCForceUpdater/SCForceUpdater.h>

#import "SCAppDelegate.h"

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SCForceUpdater initWithITunesAppId:@"iTunesAppId"
                                baseURL:@"http://localhost:4567"
                     versionAPIEndpoint:@"versions/ios"];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SCForceUpdater sharedUpdater] checkForUpdate];
}

@end
