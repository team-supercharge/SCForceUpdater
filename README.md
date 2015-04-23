# SCForceUpdater

[![Version](https://img.shields.io/cocoapods/v/SCForceUpdater.svg?style=flat)](http://cocoapods.org/pods/SCForceUpdater)
[![License](https://img.shields.io/cocoapods/l/SCForceUpdater.svg?style=flat)](http://cocoapods.org/pods/SCForceUpdater)
[![Platform](https://img.shields.io/cocoapods/p/SCForceUpdater.svg?style=flat)](http://cocoapods.org/pods/SCForceUpdater)

## Introduction

SCForceUpdater is a simple pod which implements force update functionality for your iOS projects.

## Usage

To run the example project:

1. clone this repository,
2. run `pod install` from the Example directory,
3. start the sinatra project from the TestServer directory to try it.

### Starting the TestServer

You can start the example server by:

1. change to the TestServer directory with `cd TestServer/`,
2. run `bundle install` to install dependencies,
3. run the test server with `ruby app.rb`.

This will bring up the test server listening on http://localhost:4567.

## Installation

SCForceUpdater is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

`
pod "SCForceUpdater"
`

## Configuration

SCForceUpdater provides class methods to configure it.

### Initialization

First you should call SCForceUpdater's initialization method: `initWithITunesAppId:baseURL:versionAPIEndpoint:`.
A good place to do this at the beginning of your application delegate's `application:didFinishLaunchingWithOptions:` method.

Also you should call the `checkForUpdate` method on the `[SCForceUpdater sharedUpdater]` singleton instance. We recommand to do this in the `applicationDidBecomeActive:` method of your application delegate class.

### Localizations

You can also customize the localization of the application: first you should set `setAlwaysUseMainBundle:` to YES, after this you should be able to redefine the following locales:

| Key                            | Meaning                                |
|-------------------------------:|---------------------------------------:|
|sc.force-updater.soft.title     | Title for soft update                  |
|sc.force-updater.soft.message   | Message for soft update                |
|sc.force-updater.soft.update    | Update button text for soft update     |
|sc.force-updater.soft.later     | Later button text for soft update      |
|sc.force-updater.soft.no-thanks | No thanks! button text for soft update |
|sc.force-updater.hard.title     | Title for hard update                  |
|sc.force-updater.hard.message   | Message for hard update                |
|sc.force-updater.hard.update    | Update button text for hard update     |

Messages (sc.force-updater.[soft|hard].message) are formattable. There is two parameter that they can handle: display name of the application and the upcoming version.

Like in the default localization: "Great news! There’s an updated version of {displayName} ({versionNumber}), we recommend you install it."

### Display name of the application

You can set the displayName of your application if you want. You can achive this by calling the `setDisplayName:` class method with the required name.

### Response keys

We are parsing JSON objects inside the pod. The default keys are: `last_version` for the version key and `update_type` for the update type key.

The defaults can be changed through two setter methods: `setLastVersionResponseKey:` and `setUpdateTypeResponseKey:`.

## Contributing

Contributions are always welcome! :)

1. Fork it ( http://github.com/team-supercharge/SCForceUpdater/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

SCForceUpdater is available under the MIT license. See the LICENSE file for more info.
