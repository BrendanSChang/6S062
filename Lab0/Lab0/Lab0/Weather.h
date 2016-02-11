//
//  Weather.h
//  Lab0
//
//  Created by Brendan S Chang on 2/8/16.
//  Copyright © 2016 Brendan S Chang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property NSString *currentTemp;
@property NSString *weatherDescription;
@property NSString *relativeHumidity;
@property NSString *windString;
@property NSString *visibilityMi;

- (void) fetchWeatherForZip:(NSString *) zip;
- (BOOL) parseData:(NSData *) data;

@end
