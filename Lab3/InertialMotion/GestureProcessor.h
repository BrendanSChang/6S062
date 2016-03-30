//
//  GestureProcessor.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/15/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>

typedef struct {
    double x, y, t;
} Sample2D;

typedef struct {
    GLKVector3 location;
    GLKQuaternion attitude;
    double t;
} Sample3D;

@class GestureProcessor;

@protocol GestureProcessorDelegate <NSObject>

- (void)gestureProcessor:(GestureProcessor *)gestureProcessor didRecognizeGesture:(NSString *)label;

@end

@interface GestureProcessor : NSObject

- (void)processGesture2DWithSamples:(const Sample2D *)samples
                              count:(NSUInteger)count
                            minSize:(double)minSize;

- (void)processGesture3DWithSamples:(const Sample3D *)samples
                              count:(NSUInteger)count
                            minSize:(double)minSize;

@property (nonatomic, weak) id<GestureProcessorDelegate> delegate;

@end
