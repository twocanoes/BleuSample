//
//  TCSDetailViewController.m
//  Admin
//
//  Created by Steve Brokaw on 1/17/14.
//  Copyright (c) 2014 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSDetailViewController.h"

typedef NS_ENUM(NSInteger, TCSAlertType) {
    kAlertTypeAuthenticate = 0,
    kAlertTypeChangePassword
};

@interface TCSDetailViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) UITextField *activeTextField;

- (void)keyboardDidShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;

@end

@implementation TCSDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = self.station.hardwareName;
    [self.station connect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self isMovingFromParentViewController]) {
        [self.station disconnect];
        self.station = nil;
    }
}

- (void)enableEditing
{
    self.nameField.userInteractionEnabled = YES;
    self.uuidField.userInteractionEnabled = YES;
    self.majorField.userInteractionEnabled = YES;
    self.minorField.userInteractionEnabled = YES;
    self.powerField.userInteractionEnabled = YES;
    self.calibrationField.userInteractionEnabled = YES;
    self.latitudeField.userInteractionEnabled = YES;
    self.longitudeField.userInteractionEnabled = YES;
    self.changePasswordButton.userInteractionEnabled = YES;
    [self.authenticateButton setTitle:@"Save" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBActions

- (IBAction)authenticate:(id)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Authenticate"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authenticate" message:@"Enter your password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = kAlertTypeAuthenticate;
        [alert show];
    } else {
        NSDictionary *settings = @{TCSBleuStationName: self.nameField.text,
                                   TCSBleuStationProximityUUID: self.uuidField.text,
                                   TCSBleuStationMajor: [NSNumber numberWithInteger:[self.majorField.text integerValue]],
                                   TCSBleuStationMinor: [NSNumber numberWithInteger:[self.minorField.text integerValue]],
                                   TCSBleuStationPower: [NSNumber numberWithInteger:[self.powerField.text integerValue]],
                                   TCSBleuStationCalibration: [NSNumber numberWithInteger:[self.calibrationField.text integerValue]],
                                   TCSBleuStationLatitude: [NSNumber numberWithDouble:[self.latitudeField.text doubleValue]],
                                   TCSBleuStationLongitude: [NSNumber numberWithDouble:[self.longitudeField.text doubleValue]]};
        [self.station writeValues:settings];
    }
}

- (IBAction)changePassword:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Enter your new password and tap Save to update your password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = kAlertTypeChangePassword;
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTypeAuthenticate:
            if (buttonIndex) {
                UITextField *field = [alertView textFieldAtIndex:0];
                [self.station authenticateWithPassword:field.text];
            }
            break;
        case kAlertTypeChangePassword:
            if (buttonIndex) {
                UITextField *field = [alertView textFieldAtIndex:0];
                [self.station writeValues:@{TCSBleuStationPassword: field.text}];
            }
        default:
            break;
    }
}

#pragma mark TCSBleuStationDelegate

- (void)station:(TCSBleuStation *)station didReadProperty:(NSString *)property value:(id)value error:(NSError *)error
{
    if ([property isEqualToString:TCSBleuStationName]) {
        self.nameField.text = value;
    } else if ([property isEqualToString:TCSBleuStationProximityUUID]) {
        self.uuidField.text = value;
    } else if ([property isEqualToString:TCSBleuStationMajor]) {
        self.majorField.text = [value stringValue];
    } else if ([property isEqualToString:TCSBleuStationMinor]) {
        self.minorField.text = [value stringValue];
    } else if ([property isEqualToString:TCSBleuStationPower]) {
        self.powerField.text = [value stringValue];
    } else if ([property isEqualToString:TCSBleuStationCalibration]) {
        self.calibrationField.text = [NSString stringWithFormat:@"%u", [value unsignedCharValue]];
    } else if ([property isEqualToString:TCSBleuStationLatitude]) {
        self.latitudeField.text = [value stringValue];
    } else if ([property isEqualToString:TCSBleuStationLongitude]) {
        self.longitudeField.text = [value stringValue];
    }
}

- (void)station:(TCSBleuStation *)station didWriteProperty:(NSString *)property value:(id)value error:(NSError *)error
{
    NSLog(@"Wrote %@, with value: %@ error: %@", property, value, error);
}

- (void)station:(TCSBleuStation *)station didAuthenticateError:(NSError *)error
{
    if (!error ) {
        [self enableEditing];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failure"
                                                        message:error.userInfo[NSLocalizedDescriptionKey]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)stationIsReady:(TCSBleuStation *)station
{
    self.nameField.text = station.name;
    self.uuidField.text = station.proximityUUID;
    self.majorField.text = [station.major stringValue];
    self.minorField.text = [station.minor stringValue];
    self.powerField.text = [station.power stringValue];
    self.calibrationField.text = [station.calibration stringValue];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    if (tag == 0 || tag > 7) {
        [textField resignFirstResponder];
        return NO;
    }
    tag++;
    UIView *nextView = [self.scrollView viewWithTag:tag];
    [nextView becomeFirstResponder];
    return NO;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    [self.scrollView scrollRectToVisible:textField.frame animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

# pragma mark Notification callbacks

- (void)keyboardDidShow:(NSNotification *)note
{
    CGSize kbSize = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect textFrame = self.activeTextField.frame;
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = kbSize.height + textFrame.size.height;
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
    
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGSize kbSize = [note.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize textSize = [[self activeTextField] frame].size;
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom -= (kbSize.height + textSize.height);
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
    [self.scrollView scrollRectToVisible:CGRectZero animated:YES];
}

@end
