//
//  ViewController.h
//  Lab0
//
//  Created by Brendan S Chang on 2/8/16.
//  Copyright © 2016 Brendan S Chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;

- (IBAction)weatherButton:(id)sender;
- (IBAction)tapView:(id)sender;

@end

