//
//  IIForceUpdater.m
//  ipiit
//
//  Created by Balazs on 25/01/15.
//  Copyright (c) 2015 ipiit AB. All rights reserved.
//

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import "NSString+CompareToVersion.h"
#import "NSBundle+Versions.h"

#import "SCForceUpdater.h"
#import "SCNetworkManager.h"

@interface SCForceUpdater ()

@property (nonatomic, strong) NSString *iTunesAppId;
@property (nonatomic, strong) SCNetworkManager *networkManager;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *softMessage;
@property (nonatomic, strong) NSString *hardMessage;

@property (nonatomic, strong) UIAlertView *softUpdateAlertView;
@property (nonatomic, strong) UIAlertView *hardUpdateAlertView;

@end

@implementation SCForceUpdater

+ (id)initWithITunesAppId:(NSString *)ITunesAppId
                  baseURL:(NSString *)baseURL
       versionAPIEndpoint:(NSString *)versionAPIEndpoint
{
    SCForceUpdater *sharedUpdater = [self sharedUpdater];

    if (!sharedUpdater)
    {
        return nil;
    }

    sharedUpdater.iTunesAppId = ITunesAppId;
    sharedUpdater.networkManager = [[SCNetworkManager alloc] initWithBaseURL:baseURL
                                                          versionAPIEndpoint:versionAPIEndpoint];

    return sharedUpdater;
}

+ (void)setTitle:(NSString *)title softMessage:(NSString *)softMessage hardMessage:(NSString *)hardMessage
{
    SCForceUpdater *sharedUpdater = [self sharedUpdater];

    sharedUpdater.title = title;
    sharedUpdater.softMessage = softMessage;
    sharedUpdater.hardMessage = hardMessage;
}

+ (id)sharedUpdater
{
    static SCForceUpdater *sharedUpdater = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUpdater = [self new];
    });

    return sharedUpdater;
}

- (void)checkForUpdate
{
    [_networkManager fetchCurrentVersionWithCompletion:^(NSDictionary *jsonObject) {
        [self handleResponse:jsonObject];
    }];
}

#pragma mark - Utility methods

- (void)handleResponse:(NSDictionary *)jsonObject
{
    // not a valid JSON object
    if (!jsonObject)
    {
        return;
    }

    NSString *version = jsonObject[@"last_version"];
    NSString *type    = jsonObject[@"update_type"];

    // check for available update
    if (version == nil || type == nil)
    {
        return;
    }

    // check for version
    if ([version isEqualOrOlderThanVersion:[self currentVersion]])
    {
        return;
    }

    // on soft update
    if ([type isEqualToString:@"soft"])
    {
        // if "do not display again"
        if ([[NSUserDefaults standardUserDefaults] objectForKey:[self defaultsKeyForVersion:version]])
        {
            return;
        }

        [self displaySoftUpdateAlertForVersion:version];
        return;
    }

    // on hard upcate
    if ([type isEqualToString:@"hard"])
    {
        [self displayHardUpdateAlertForVersion:version];
        return;
    }
}

- (void)displaySoftUpdateAlertForVersion:(NSString *)version
{
    // dismiss hard update alert
    if (_hardUpdateAlertView)
    {
        [_hardUpdateAlertView dismissWithClickedButtonIndex:0 animated:YES];
        _hardUpdateAlertView = nil;
    }

    // do not display if already displayed
    if (_softUpdateAlertView)
    {
        return;
    }

    // display alert
    self.softUpdateAlertView = [[UIAlertView alloc] initWithTitle:_title
                                                         message:[NSString stringWithFormat:_softMessage, version]
                                                         delegate:nil
                                                cancelButtonTitle:@"Update"
                                                otherButtonTitles:@"No thanks!", @"Later", nil];

    __weak typeof(self) welf = self;
    _softUpdateAlertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex)
    {
        // update branch
        if (buttonIndex == [alertView cancelButtonIndex])
        {
            [[UIApplication sharedApplication] openURL:[welf iTunesAppURL]];

            welf.softUpdateAlertView = nil;
            return;
        }

        // no, thanks branch
        if (buttonIndex == 1)
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"true" forKey:[welf defaultsKeyForVersion:version]];
            [defaults synchronize];

            welf.softUpdateAlertView = nil;
            return;
        }

        // later branch
        if (buttonIndex == 2)
        {
            welf.softUpdateAlertView = nil;
            return;
        }
    };

    [_softUpdateAlertView show];
}

- (void)displayHardUpdateAlertForVersion:(NSString *)version
{
    // dismiss soft if any
    if (_softUpdateAlertView)
    {
        [_softUpdateAlertView dismissWithClickedButtonIndex:0 animated:YES];
        _softUpdateAlertView = nil;
    }

    // do not display if already displayed
    if (_hardUpdateAlertView)
    {
        return;
    }

    // display alert
    self.hardUpdateAlertView = [[UIAlertView alloc] initWithTitle:_title
                                                          message:[NSString stringWithFormat:_hardMessage, version]
                                                         delegate:nil
                                                cancelButtonTitle:@"Update"
                                                otherButtonTitles:nil];

    __weak typeof(self) welf = self;
    _hardUpdateAlertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex)
    {
        // open iTunes store
        [[UIApplication sharedApplication] openURL:[welf iTunesAppURL]];

        welf.hardUpdateAlertView = nil;
        [welf displayHardUpdateAlertForVersion:version];
    };

    [_hardUpdateAlertView show];
}

- (NSString *)currentVersion
{
    return [[NSBundle mainBundle] versionNumber];
}

- (NSString *)defaultsKeyForVersion:(NSString *)version
{
    return [NSString stringWithFormat:@"dismiss-update-%@", version];
}

- (NSURL *)iTunesAppURL
{
    NSString *url = [NSString stringWithFormat:@"itms://itunes.apple.com/us/app/id%@?mt=8", _iTunesAppId];
    return [NSURL URLWithString:url];
}

@end
