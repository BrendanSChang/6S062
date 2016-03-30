//
//  RibbonViewController.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/1/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface RibbonViewController : GLKViewController

// Add a position and orientation to the log of positions and orientations, keeping track
// of whether the new segment of ribbon should be visible (finger touching screen) or invisible
- (void)appendPoint:(GLKVector3)point attitude:(GLKQuaternion)attitude draw:(BOOL)draw;

@end
