//
//  NetworkManager.h
//  Pods
//
//  Created by Richard Szabo on 03/04/15.
//
//

#import <Foundation/Foundation.h>

typedef void(^SCForceUpdaterCompletionCallback)(NSDictionary *jsonObject);

@interface SCNetworkManager : NSObject <NSURLConnectionDelegate>

- (id)initWithBaseURL:(NSString *)baseURL versionAPIEndpoint:(NSString *)versionAPIEndpoint;
- (void)fetchCurrentVersionWithCompletion:(SCForceUpdaterCompletionCallback)completionCallback;

@end
