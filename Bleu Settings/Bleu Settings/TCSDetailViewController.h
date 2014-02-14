//
//  TCSDetailViewController.h
//  Admin
//
//  Created by Steve Brokaw on 1/17/14.
//  Copyright (c) 2014 Twocanoes Software, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSBleuStation.h"
@interface TCSDetailViewController : UIViewController <TCSBleuStationDelegate>

@property (strong, nonatomic) TCSBleuStation *station;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *uuidField;
@property (weak, nonatomic) IBOutlet UITextField *majorField;
@property (weak, nonatomic) IBOutlet UITextField *minorField;
@property (weak, nonatomic) IBOutlet UITextField *powerField;
@property (weak, nonatomic) IBOutlet UITextField *calibrationField;
@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;
@property (weak, nonatomic) IBOutlet UITextField *firmwareField;

@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

- (IBAction)authenticate:(id)sender;
- (IBAction)changePassword:(id)sender;

@end
