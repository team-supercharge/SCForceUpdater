//
//  NetworkManager.m
//  Pods
//
//  Created by Richard Szabo on 03/04/15.
//
//

#import "SCNetworkManager.h"

#import "NSBundle+Versions.h"

@interface SCNetworkManager ()

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *versionAPIEndpoint;

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) SCForceUpdaterCompletionCallback completionCallback;

@end

@implementation SCNetworkManager

- (id)initWithBaseURL:(NSString *)baseURL versionAPIEndpoint:(NSString *)versionAPIEndpoint
{
    self = [super init];

    if (!self)
    {
        return nil;
    }

    self.baseURL = baseURL;
    self.versionAPIEndpoint = versionAPIEndpoint;

    return self;
}

- (void)fetchCurrentVersionWithCompletion:(SCForceUpdaterCompletionCallback)completionCallback
{
    self.completionCallback = completionCallback;

    NSString *urlString = [NSString stringWithFormat:@"%@/%@?%@", _baseURL,
                                                                  _versionAPIEndpoint,
                                                                  [self params]];
    NSURL *requestURL = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];

    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    [conn start];
}

- (NSString *)params
{
    NSDictionary *params = @{
                             @"platform"     : @"ios",
                             @"version"      : [[NSBundle mainBundle] versionNumber],
                             @"build_number" : [[NSBundle mainBundle] buildNumber]
                             };

    NSMutableArray *parts = [NSMutableArray new];
    for (NSString *key in params)
    {
        NSString *value = [params objectForKey:key];

        NSString *queryKey   = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *queryValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSString *part = [NSString stringWithFormat:@"%@=%@", queryKey, queryValue];
        [parts addObject:part];
    }

    return [parts componentsJoinedByString:@"&"];
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];

    if (error || !_completionCallback)
    {
        NSLog(@"[SCForceUpdater] error parsing JSON: %@", error);
        return;
    }

    _completionCallback(jsonObject);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"[SCForceUpdater] request failed: %@", error);
}

@end
