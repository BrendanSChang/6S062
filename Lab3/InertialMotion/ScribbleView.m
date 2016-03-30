//
//  ScribbleView.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/15/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "ScribbleView.h"

@interface ScribbleView () {
    CGPoint _pt[2];
    int _ptCount;
    UIColor *_color;
}

@end

@implementation ScribbleView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder])
    {
        _path = [UIBezierPath bezierPath];
        _path.lineWidth = 10;
        _path.lineCapStyle = kCGLineCapRound;
        _path.lineJoinStyle = kCGLineJoinRound;
        _color = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [_color setStroke];
    [_path stroke];
}

- (void)addPoint:(CGPoint)point
{
    if (_ptCount == 0)
        [_path moveToPoint:point];
    else if (_ptCount == 1)
        [_path addLineToPoint:point];
    else
    {
        CGPoint velocity = CGPointMake((point.x-_pt[0].x) * .5, (point.y-_pt[0].y) * .5);
        CGPoint control = CGPointMake(_pt[1].x + .5 * velocity.x, _pt[1].y + .5 * velocity.y);
        [_path addQuadCurveToPoint:point controlPoint:control];
    }
    
    _pt[0] = _pt[1];
    _pt[1] = point;
    _ptCount++;
    
    [self setNeedsDisplay];
}

- (void)clear
{
    [_path removeAllPoints];
    _ptCount = 0;
    [self setNeedsDisplay];
}

@end
