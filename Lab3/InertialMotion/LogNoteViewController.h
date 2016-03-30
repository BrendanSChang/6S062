//
//  LogNoteViewController.h
//  InertialMotion
//
//  Created by Peter Iannucci on 3/22/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogNoteViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *textView;

- (IBAction)done:(id)sender;

@end
