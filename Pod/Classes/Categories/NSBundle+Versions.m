//
//  NSBundle+Versions.m
//  ipiit
//
//  Created by Balazs on 31/01/15.
//  Copyright (c) 2015 ipiit AB. All rights reserved.
//

#import "NSBundle+Versions.h"

@implementation NSBundle (Versions)

- (NSString *)versionNumber
{
    return [self objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSString *)buildNumber
{
    return [self objectForInfoDictionaryKey:@"CFBundleVersion"];
}

@end
