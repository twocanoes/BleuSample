//
//  TCSDetailViewController.m
//  Admin
//
//  Created by Steve Brokaw on 1/17/14.
//  Copyright (c) 2014 Twocanoes Software, Inc. All rights reserved.
//

#import "TCSDetailViewController.h"

@interface TCSDetailViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) UITextField *activeTextField;

- (void)configureView;
- (void)keyboardDidShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;

@end

@implementation TCSDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.station readValues:@[TCSBleuStationAllProperties]];
    self.navigationItem.title = self.station.hardwareName;
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

- (void)station:(TCSBleuStation *)station didReadValues:(NSDictionary *)values error:(NSError *)error
{
    NSArray *keys = [values allKeys];
    for (NSString *key in keys) {
        if ([key isEqualToString:TCSBleuStationName]) {
            self.nameField.text = values[key];
        } else if ([key isEqualToString:TCSBleuStationProximityUUID]) {
            self.uuidField.text = values[key];
        } else if ([key isEqualToString:TCSBleuStationMajor]) {
            self.majorField.text = [values[key] stringValue];
        } else if ([key isEqualToString:TCSBleuStationMinor]) {
            self.minorField.text = [values[key] stringValue];
        } else if ([key isEqualToString:TCSBleuStationPower]) {
            self.powerField.text = [values[key] stringValue];
        } else if ([key isEqualToString:TCSBleuStationCalibration]) {
            self.calibrationField.text = [values[key] stringValue];
        } else if ([key isEqualToString:TCSBleuStationLatitude]) {
            self.latitudeField.text = [values[key] stringValue];
        } else if ([key isEqualToString:TCSBleuStationLongitude]) {
            self.longitudeField.text = [values[key] stringValue];
        }
    }
}

- (void)station:(TCSBleuStation *)station didAuthenticateError:(NSError *)error
{
    NSInteger code = error.code;
    if (!error || code == 1) {
        [self enableEditing];
    }
}

- (IBAction)authenticate:(id)sender
{
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"Authenticate"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authenticate" message:@"Enter your password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.delegate = self;
        [alert show];
    } else {
        NSDictionary *settings = @{TCSBleuStationName: self.nameField.text,
                                   TCSBleuStationProximityUUID: self.uuidField.text,
                                   TCSBleuStationMajor: [NSNumber numberWithInteger:[self.majorField.text integerValue]],
                                   TCSBleuStationMinor: [NSNumber numberWithInteger:[self.minorField.text integerValue]],
                                   TCSBleuStationPower: [NSNumber numberWithInteger:[self.minorField.text integerValue]],
                                   TCSBleuStationCalibration: [NSNumber numberWithInteger:[self.calibrationField.text integerValue]],
                                   TCSBleuStationLatitude: [NSNumber numberWithFloat:[self.latitudeField.text floatValue]],
                                   TCSBleuStationLongitude: [NSNumber numberWithFloat:[self.longitudeField.text floatValue]]};
        [self.station writeValues:settings];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        UITextField *field = [alertView textFieldAtIndex:0];
        [self.station authenticateWithPassword:field.text];
    }
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
