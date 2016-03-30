//
//  ScribbleView.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/15/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScribbleView : UIView

@property (nonatomic, strong) UIBezierPath *path;

- (void)addPoint:(CGPoint)point;
- (void)clear;

@end
