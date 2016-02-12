//
//  Weather.m
//  Lab0
//
//  Created by Brendan S Chang on 2/8/16.
//  Copyright © 2016 Brendan S Chang. All rights reserved.
//

#import "Weather.h"

#define APP_ID @"0b719bec26ab96ac"
#define TIMEOUT_SECS 5.0

@implementation Weather

- (void) fetchWeatherForZip:(NSString *)zip completionHandler:(void (^)(BOOL))handler {
    NSLog(@"Fetching conditions in %@...", zip);
    NSString *urlString = [
      NSString stringWithFormat:
        @"https://api.wunderground.com/api/%@/conditions/q/%@.json",
        APP_ID,
        zip
    ];

    NSURL *weatherURL = [NSURL URLWithString:urlString];

    // Non-blocking implementation.
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:weatherURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT_SECS];

    NSURLSessionDataTask *dataTask = [
      session dataTaskWithRequest:request
      completionHandler:
        ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            BOOL success = [self parseData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                // Pass the success message up to the caller on the main queue.
                handler(success);
            });
        }
    ];
    
    [dataTask resume];
}

- (BOOL) parseData:(NSData *)data {
    if (!data) {
        return NO;
    }

    // Check that the data is a proper JSON object.
    NSError *error;
    id jsonObject = [
      NSJSONSerialization JSONObjectWithData:data
      options:kNilOptions
      error:&error
    ];

    if (!jsonObject ||
          ![jsonObject isKindOfClass:[NSDictionary class]] ||
          !jsonObject[@"current_observation"]) {
        return NO;
    }

    NSDictionary *currentObservation = jsonObject[@"current_observation"];
    self.currentTemp = currentObservation[@"temperature_string"];
    self.weatherDescription = currentObservation[@"weather"];
    self.relativeHumidity = currentObservation[@"relative_humidity"];
    self.windString = currentObservation[@"wind_string"];
    self.visibilityMi = currentObservation[@"visibility_mi"];

    return YES;
}

@end
