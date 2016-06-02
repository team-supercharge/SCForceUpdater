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

@property (nonatomic, strong) UIAlertView *softUpdateAlertView;
@property (nonatomic, strong) UIAlertView *hardUpdateAlertView;

@end

static bool alwaysUseMainBundle;
static NSString *displayName;
static NSString *lastVersionResponseKey;
static NSString *updateTypeResponseKey;

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

    displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    lastVersionResponseKey = @"last_version";
    updateTypeResponseKey  = @"update_type";
    sharedUpdater.iTunesAppId = ITunesAppId;
    sharedUpdater.networkManager = [[SCNetworkManager alloc] initWithBaseURL:baseURL
                                                          versionAPIEndpoint:versionAPIEndpoint];

    return sharedUpdater;
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

- (void)checkForUpdateWithCompletionBlock:(void (^)(NSDictionary *jsonObject))completionBlock
{
    [_networkManager fetchCurrentVersionWithCompletion:^(NSDictionary *jsonObject) {
        [self handleResponse:jsonObject];

        if (completionBlock)
        {
            completionBlock(jsonObject);
        }
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

    NSString *version = jsonObject[lastVersionResponseKey];
    NSString *type    = jsonObject[updateTypeResponseKey];

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

    NSString *softMessage
    = [NSString stringWithFormat:[self localize:@"sc.force-updater.soft.message"
                                    withComment:@"Soft message text"], displayName, version];

    // display alert
    self.softUpdateAlertView = [[UIAlertView alloc] initWithTitle:[self localize:@"sc.force-updater.soft.title"
                                                                     withComment:@"Soft title text"]
                                                          message:softMessage
                                                         delegate:nil
                                                cancelButtonTitle:[self localize:@"sc.force-updater.soft.update"
                                                                     withComment:@"Update button text"]
                                                otherButtonTitles:[self localize:@"sc.force-updater.soft.no-thanks"
                                                                     withComment:@"No thanks! button text"],
                                                                  [self localize:@"sc.force-updater.soft.later"
                                                                     withComment:@"Later button text"], nil];

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

    NSString *hardMessage
    = [NSString stringWithFormat:[self localize:@"sc.force-updater.hard.message"
                                    withComment:@"Hard message text"], displayName, version];

    // display alert
    self.hardUpdateAlertView = [[UIAlertView alloc] initWithTitle:[self localize:@"sc.force-updater.hard.title"
                                                                     withComment:@"Hard message title"]
                                                          message:hardMessage
                                                         delegate:nil
                                                cancelButtonTitle:[self localize:@"sc.force-updater.hard.update"
                                                                     withComment:@"Update button text"]
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
    NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?mt=8", _iTunesAppId];
    return [NSURL URLWithString:url];
}

#pragma mark - Configuration methods

+ (void)setAlwaysUseMainBundle:(bool)_alwaysUseMainBundle
{
    alwaysUseMainBundle = _alwaysUseMainBundle;
}

+ (void)setDisplayName:(NSString *)_displayName
{
    displayName = _displayName;
}

+ (void)setLastVersionResponseKey:(NSString *)_lastVersionResponseKey
{
    lastVersionResponseKey = _lastVersionResponseKey;
}

+ (void)setUpdateTypeResponseKey:(NSString *)_updateTypeResponseKey
{
    updateTypeResponseKey = _updateTypeResponseKey;
}

#pragma mark - Utility methods

- (NSString *)localize:(NSString *)key withComment:(NSString *)comment
{
    return NSLocalizedStringFromTableInBundle(key, @"SCForceUpdaterLocalizable", [SCForceUpdater bundle], comment);
}

+ (NSBundle *)bundle
{
    if (alwaysUseMainBundle)
    {
        return [NSBundle mainBundle];
    }

    NSURL *forceUpdaterBundleURL = [[NSBundle mainBundle] URLForResource:@"SCForceUpdater" withExtension:@"bundle"];

    return [NSBundle bundleWithURL:forceUpdaterBundleURL];
}

@end
