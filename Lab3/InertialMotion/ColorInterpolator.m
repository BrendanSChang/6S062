//
//  ColorInterpolator.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "ColorInterpolator.h"

@implementation ColorInterpolator

- (void)pushColor:(GLKVector3)color
{
    colors[1] = colors[0];
    colors[0] = color;
    next_t++;
}

- (GLKVector3)colorForTime:(double)t
{
    assert(next_t >= 2);
    assert(t >= next_t-2);
    assert(t <= next_t-1);
    GLfloat u = t - (next_t-2);
    return GLKVector3Add(GLKVector3MultiplyScalar(colors[0], u), GLKVector3MultiplyScalar(colors[1], 1-u));
}

@end

@implementation ColorRandomizer

- (GLKVector3)randomColor
{
    float r = ldexp(random(), -32);
    float g = ldexp(random(), -32);
    float b = ldexp(random(), -32);
    return (GLKVector3){ .v={r,g,b}};
}

- (GLKVector3)colorForTime:(double)t
{
    if (next_t == 0)
        next_t = (int)t;
    while (t > next_t-1)
        [self pushColor:[self randomColor]];
    return [super colorForTime:t];
}

@end
