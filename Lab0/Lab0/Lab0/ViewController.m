//
//  ViewController.m
//  Lab0
//
//  Created by Brendan S Chang on 2/8/16.
//  Copyright © 2016 Brendan S Chang. All rights reserved.
//

#import "ViewController.h"
#import "Weather.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)weatherButton:(id)sender {
    NSLog(@"Weather Button pressed");

    UIButton *button = sender;
    button.enabled = NO;

    // Hide the keyboard.
    [self.zipcodeField resignFirstResponder];

    NSString *zip = self.zipcodeField.text;
    Weather *weather = [[Weather alloc] init];
    [weather fetchWeatherForZip:zip completionHandler:^(BOOL succeeded) {
        if (succeeded) {
            NSLog(@"Update succeeded for %@.", zip);
        } else {
            NSLog(@"Update failed for %@.", zip);
        }
        button.enabled = YES;
    }];

    [self updateLabels:weather];
}

// Hide keyboard when background is tapped.
- (IBAction)tapView:(id)sender {
    [self.zipcodeField resignFirstResponder];
}

- (void) updateLabels:(Weather *)weather {
    self.temperatureLabel.text = [
      NSString stringWithFormat:@"Temperature: %@", weather.currentTemp
    ];

    self.descriptionLabel.text = [
      NSString stringWithFormat:@"Description: %@", weather.weatherDescription
    ];

    self.humidityLabel.text = [
      NSString stringWithFormat:@"Humidity: %@", weather.relativeHumidity
    ];

    self.windLabel.text = [
      NSString stringWithFormat:@"Wind: %@", weather.windString
    ];

    self.visibilityLabel.text = [
      NSString stringWithFormat:@"Visibility: %@ mi", weather.visibilityMi
    ];
}

@end
