//
//  SCViewController.m
//  SCForceUpdater
//
//  Created by Richard Szabo on 04/07/2015.
//  Copyright (c) 2014 Richard Szabo. All rights reserved.
//

#import <SCForceUpdater/SCForceUpdater.h>

#import "SCViewController.h"

@interface SCViewController ()

@end

@implementation SCViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Button actions

- (IBAction)checkForUpdateButtonClicked:(id)sender
{
    [[SCForceUpdater sharedUpdater] checkForUpdate];
}

@end
