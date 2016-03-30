//
//  Gesture2DViewController.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "Gesture2DViewController.h"
#import "AppDelegate.h"

#define SCREENSHOT 0

@interface Gesture2DViewController () {
    NSMutableData *_samples;
}

@end

@implementation Gesture2DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _samples = [NSMutableData data];
    
    _longPressGestureRecognizer.enabled = TRAINING;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [_samples setLength:0];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.gestureProcessor.delegate = self;
    
    [super viewDidAppear:animated];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

- (void)updateTouches:(UIEvent *)event
{
    NSMutableSet *activeTouches = [NSMutableSet set];
    BOOL cancelled = NO;
    for (UITouch *touch in event.allTouches) {
        switch (touch.phase)
        {
            case UITouchPhaseBegan:
            case UITouchPhaseMoved:
            case UITouchPhaseStationary:
                [activeTouches addObject:touch];
                break;
            case UITouchPhaseCancelled:
                cancelled = YES;
                break;
            default:
                break;
        }
    }
    
    if ([activeTouches count] > 0)
    {
        CGPoint point = [[activeTouches anyObject] locationInView:self.view];
        Sample2D s = {point.x, point.y, [NSDate timeIntervalSinceReferenceDate]};
        
        [_samples appendBytes:&s length:sizeof(s)];
        
        [self.scribbleView addPoint:point];
    }
    else if ([_samples length])
    {
        if (!cancelled)
        {
            const Sample2D *samples = _samples.bytes;
            NSUInteger count = _samples.length / sizeof(Sample2D);
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            [delegate.gestureProcessor processGesture2DWithSamples:samples
                                                             count:count
                                                           minSize:100.];
        }
        
        [_samples setLength:0];
        
#if SCREENSHOT
        UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, NO, [UIScreen mainScreen].scale);
        [self.view drawViewHierarchyInRect:[UIScreen mainScreen].bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageWriteToSavedPhotosAlbum(image, nil, NULL, NULL);
        UIGraphicsEndImageContext();
#endif
        
        [self.scribbleView clear];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event     { [self updateTouches:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateTouches:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event     { [self updateTouches:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event     { [self updateTouches:event]; }

- (void)gestureProcessor:(GestureProcessor *)gestureProcessor didRecognizeGesture:(NSString *)label
{
#if !SCREENSHOT
    self.label.text = [self.label.text stringByAppendingString:label];
#endif
}

- (void)longPress:(id)sender
{
    if (![self presentedViewController])
        [self performSegueWithIdentifier:@"logNote" sender:sender];
}

@end
