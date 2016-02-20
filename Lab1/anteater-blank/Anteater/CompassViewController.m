//
//  CompassViewController.m
//  Anteater
//
//  Created by Sam Madden on 1/29/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

#import "CompassViewController.h"
#import "AnteaterREST.h"

@interface CompassViewController ()

@end

@implementation CompassViewController {
    NSArray *_anthills;
    CLLocationManager *_mgr;
    UIImage *_image;
    BOOL gotLoc;
    CLLocationCoordinate2D _lastLoc, _userLoc, _targetLoc;
    CGFloat _curHeading, _lastHeading, _scale, _lastMagHeading;
    double angleOffset;
}

- (void)viewDidLoad {
    _mgr = [[CLLocationManager alloc] init];
    _mgr.delegate = self;
    _mgr.desiredAccuracy = kCLLocationAccuracyBest;
    _mgr.distanceFilter = 0;
    _mgr.headingOrientation = CLDeviceOrientationPortrait;
    [_mgr startUpdatingHeading];
    [_mgr startUpdatingLocation];
    _anthills = @[];
    _picker.dataSource = self;
    _picker.delegate = self;
    [AnteaterREST getListOfAnthills:^(NSDictionary *hills) {
        if (hills)
            _anthills = [hills objectForKey:@"anthills"];
        [_picker reloadAllComponents];
    }];
    
    self.distanceLabel.text = @"";
    self.headingLabel.text = @"";

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateCompass {
    // Rotate the needle.
    CGFloat offset = angleOffset - _curHeading;
    _needle.transform = CGAffineTransformMakeRotation(offset);

    // TODO: Update the distance using the haversine formula.
}

- (void)calcAngleOffset {
    CLLocationCoordinate2D anthillLoc = [self curSelectedLocation];
    angleOffset = atan2(
      sin(anthillLoc.longitude-_userLoc.longitude) *
        cos(anthillLoc.latitude),
      cos(_userLoc.latitude)*sin(anthillLoc.latitude) -
        sin(_userLoc.latitude)*
          cos(anthillLoc.latitude)*
          cos(anthillLoc.longitude-_userLoc.longitude)
    );
}

//TODO: Implement me
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    _lastHeading = _curHeading;
    _curHeading = [newHeading trueHeading];
}


//TODO: Implement me
-(void)locationManager:(CLLocationManager*)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    // Assume that the last location is the user's current location.
    _lastLoc = _userLoc;
    _userLoc = [locations[[locations count] - 1] coordinate];
    [self calcAngleOffset];
}


#pragma  mark - Picker View -

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_anthills count];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED {
    return [[_anthills objectAtIndex:row] objectForKey:@"id"];
}

-(CLLocationCoordinate2D) curSelectedLocation {
    
    NSDictionary *d = [_anthills objectAtIndex:[_picker selectedRowInComponent:0]];
    CLLocationCoordinate2D hill = CLLocationCoordinate2DMake([[d objectForKey:@"lat"] floatValue] , [[d objectForKey:@"lon"] floatValue]);
    return hill;

}

//TODO: Implement me
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED
{
    [self calcAngleOffset];
}


@end
