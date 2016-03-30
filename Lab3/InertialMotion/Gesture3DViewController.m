//
//  Gesture3DViewController.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "Gesture3DViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "AppDelegate.h"

static inline GLKQuaternion GLKQuaternionFromCMQuaternion(CMQuaternion quat)
{
    return GLKQuaternionMake(quat.x, quat.y, quat.z, quat.w);
}

static inline GLKVector3 GLKVector3FromCMAcceleration(CMAcceleration acceleration)
{
    return GLKVector3Make(acceleration.x, acceleration.y, acceleration.z);
}

@interface Gesture3DViewController () {
    NSUInteger _touches;
    CMMotionManager *_motionManager;
    NSMutableData *_samples;
    GLKVector3 _position;
    GLKVector3 _velocity;
}

@end

@implementation Gesture3DViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _samples = [NSMutableData data];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1e-2;
    
    CMDeviceMotionHandler handler = ^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        [self accumulateMotion:motion];
    };
    
    CMAttitudeReferenceFrame referenceFrame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;
    
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:referenceFrame
                                                        toQueue:[NSOperationQueue mainQueue]
                                                    withHandler:handler];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [_samples setLength:0];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.gestureProcessor.delegate = self;
    
    [super viewDidAppear:animated];
}

- (void)updateTouches:(UIEvent *)event
{
    NSSet<UITouch *> *activeTouches = [event.allTouches objectsPassingTest:^BOOL(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        return obj.phase == UITouchPhaseBegan || obj.phase == UITouchPhaseMoved || obj.phase == UITouchPhaseStationary;
    }];
    
    _touches = [activeTouches count];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event     { [self updateTouches:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateTouches:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event     { [self updateTouches:event]; }

- (void)accumulateMotion:(CMDeviceMotion *)motion
{
    double dt = _motionManager.deviceMotionUpdateInterval;
    GLKQuaternion attitude = GLKQuaternionFromCMQuaternion(motion.attitude.quaternion);
    GLKVector3 userAcceleration = GLKVector3FromCMAcceleration(motion.userAcceleration);
    
    // -- TASK 2A --
    GLKVector3 acceleration = userAcceleration;
    // rotate acceleration from instantaneous coordinates into persistent coordinates
    
    // -- TASK 2B --
    // integrate acceleration into _velocity and _velocity into _position
    
    // -- TASK 2C --
    // apply your choice of braking to _velocity and _position to stabilize the integration loop
    
    // add the new data to the log
    [self appendPoint:_position attitude:attitude];
}

- (void)appendPoint:(GLKVector3)point attitude:(GLKQuaternion)attitude
{
    BOOL draw = (_touches > 0);
    if (draw)
    {
        // Why is the z axis flipped?
        GLKVector3 position = GLKVector3Make(point.x, point.y, -point.z);
        Sample3D s = {position, attitude, [NSDate timeIntervalSinceReferenceDate]};
        [_samples appendBytes:&s length:sizeof(Sample3D)];
    }
    else if ([_samples length])
    {
        const Sample3D *samples = _samples.bytes;
        NSUInteger count = _samples.length / sizeof(Sample3D);
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.gestureProcessor processGesture3DWithSamples:samples
                                                         count:count
                                                       minSize:0.01];
        [_samples setLength:0];
    }
    [super appendPoint:point attitude:attitude draw:draw];
}

- (void)gestureProcessor:(GestureProcessor *)gestureProcessor didRecognizeGesture:(NSString *)label
{
    self.label.text = [self.label.text stringByAppendingString:label];
}

@end
