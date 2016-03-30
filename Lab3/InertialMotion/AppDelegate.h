//
//  AppDelegate.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureProcessor.h"

#define TRAINING 1

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GestureProcessor *gestureProcessor;

- (void)appendTrainingLog:(NSString *)entry;

@end

