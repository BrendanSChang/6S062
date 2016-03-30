//
//  Ribbon.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ColorInterpolator.h"

// Subclassable; tracks an interval of time, subtracting off the starting time coordinate.
// The subtraction is important because the usual system timestamp is a double-precision
// float counting seconds since 2001, which requires too many significant figures for the
// single-precision floats used by OpenGLES.
@interface HistoryManager : NSObject

@property (nonatomic, assign) double oldestTime, newestTime, startTime, lifetime;

- (instancetype)initWithLifetime:(double)lifetime;
- (void)advanceToTime:(double)time;

@end

// Subclassable; manages geometry storage for a strip of triangles which age out after some time.
// Also configures shaders and projection information for drawing.
@interface TriangleStrip : HistoryManager

- (void)appendPoint:(GLKVector3)point withColor:(GLKVector3)color forTime:(double)time;
- (void)draw;
- (void)setupGL;
- (void)tearDownGL;

@property (nonatomic, assign) GLKMatrix4 modelViewProjectionMatrix;
@property (nonatomic, assign) GLKMatrix3 normalMatrix;

@end

// Converts points and orientations into pairs of closely-separated points aligned along the x-axis
// of the device
@interface Ribbon : TriangleStrip

- (void)appendPoint:(GLKVector3)point attitude:(GLKQuaternion)attitude forTime:(double)t skip:(BOOL)skip;

@end