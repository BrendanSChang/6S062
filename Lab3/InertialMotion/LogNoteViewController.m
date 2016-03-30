//
//  LogNoteViewController.m
//  InertialMotion
//
//  Created by Peter Iannucci on 3/22/16.
//  Copyright © 2016 MIT. All rights reserved.
//

#import "LogNoteViewController.h"
#import "AppDelegate.h"

@interface LogNoteViewController ()

@end

@implementation LogNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _textView.text = nil;
    [_textView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (IBAction)done:(id)sender
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate appendTrainingLog:[NSString stringWithFormat:@"\n\n\n%@\n\n\n", _textView.text]];
    [self performSegueWithIdentifier:@"exit" sender:sender];
}

@end
