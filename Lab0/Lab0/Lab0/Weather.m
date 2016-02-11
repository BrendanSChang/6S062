//
//  Weather.m
//  Lab0
//
//  Created by Brendan S Chang on 2/8/16.
//  Copyright © 2016 Brendan S Chang. All rights reserved.
//

#import "Weather.h"

#define APP_ID @"0b719bec26ab96ac"

@implementation Weather

- (void) fetchWeatherForZip:(NSString *)zip {
    NSLog(@"Fetching conditions in %@...", zip);
    NSString *urlString = [
      NSString stringWithFormat:
        @"https://api.wunderground.com/api/%@/conditions/q/%@.json",
        APP_ID,
        zip
    ];

    NSURL *weatherURL = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:weatherURL];

    [self parseData:data];
    
}

- (BOOL) parseData:(NSData *)data {
    if (!data) {
        return NO;
    }

    // Check that the data is a proper JSON object.
    NSError *error;
    id jsonObject = [
      NSJSONSerialization JSONObjectWithData:data
      options:kNilOptions error:&error
    ];

    NSDictionary *currentObservation = jsonObject[@"current_observation"];
    self.currentTemp = currentObservation[@"temperature_string"];
    self.weatherDescription = currentObservation[@"weather"];
    self.relativeHumidity = currentObservation[@"relative_humidity"];
    self.windString = currentObservation[@"wind_string"];
    self.visibilityMi = currentObservation[@"visibility_mi"];

    return YES;
}

@end
