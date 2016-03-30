//
//  ColorInterpolator.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ColorInterpolator : NSObject {
    GLKVector3 colors[2];
    GLint next_t;
}

- (void)pushColor:(GLKVector3)color;

- (GLKVector3)colorForTime:(double)t;

@end

@interface ColorRandomizer : ColorInterpolator
@end