//
//  Gesture2DViewController.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/14/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScribbleView.h"
#import "GestureProcessor.h"

@interface Gesture2DViewController : UIViewController <GestureProcessorDelegate>

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet ScribbleView *scribbleView;
@property (nonatomic, strong) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

- (IBAction)longPress:(id)sender;

@end
