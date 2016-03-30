//
//  Gesture3DViewController.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "RibbonViewController.h"
#import "GestureProcessor.h"

@interface Gesture3DViewController : RibbonViewController <GestureProcessorDelegate>

@property (nonatomic, retain) IBOutlet UILabel *label;

@end
