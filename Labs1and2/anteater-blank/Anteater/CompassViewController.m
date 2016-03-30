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
    double _angle, _distance;
    CGFloat _offset;
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


- (void)calcAngleToTarget {
    // (lat1,lon1) is the starting point, i.e. the user.
    // (lat2,lon2) is the ending point, i.e. the anthill.
    // Each of the values is converted to radians.
    double lat1 = degToRad(_userLoc.latitude);
    double lon1 = degToRad(_userLoc.longitude);
    double lat2 = degToRad(_targetLoc.latitude);
    double lon2 = degToRad(_targetLoc.longitude);
    
    _angle =
        atan2(
            sin(lon2-lon1)*cos(lat2),
            cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(lon2-lon1)
        );
}


- (void)calcDistanceToTarget {
    // (lat1,lon1) is the starting point, i.e. the user.
    // (lat2,lon2) is the ending point, i.e. the anthill.
    // Each of the values is converted to radians.
    double lat1 = degToRad(_userLoc.latitude);
    double lon1 = degToRad(_userLoc.longitude);
    double lat2 = degToRad(_targetLoc.latitude);
    double lon2 = degToRad(_targetLoc.longitude);
    
    // Get the distance using the haversine formula.
    _distance =
        2*RADIUS*asin(
            sqrt(
                pow(sin((lat2-lat1)/2), 2) +
                cos(lat1)*cos(lat2)*pow(sin((lon2-lon1)/2),2)
            )
        );
}

- (void)updateCompass {
    // Rotate the needle. The provided offset is in radians.
    _offset = _angle - _curHeading;
    _needle.transform = CGAffineTransformMakeRotation(_offset);

    [self calcDistanceToTarget];

    // Update the labels.
    self.distanceLabel.text = [NSString stringWithFormat:@"%.01f km", _distance];

    // Ensure that the displayed heading is in the range [0, 360).
    double heading = radToDeg(_offset);
    if (heading < 0) {
        heading += 360;
    }
    self.headingLabel.text = [NSString stringWithFormat:@"%.f %@", heading, @"\u00B0"];
}

//TODO: Implement me
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    _lastHeading = _curHeading;
    _curHeading = degToRad(newHeading.trueHeading);
    [self updateCompass];
}


//TODO: Implement me
-(void)locationManager:(CLLocationManager*)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    // Assume that the last location is the user's current location.
    _lastLoc = _userLoc;
    _userLoc = [locations lastObject].coordinate;
    [self calcAngleToTarget];
    [self updateCompass];
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
    _targetLoc = [self curSelectedLocation];
    [self calcAngleToTarget];
    [self updateCompass];
}


@end
