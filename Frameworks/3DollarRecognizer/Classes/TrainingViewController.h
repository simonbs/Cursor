//
//  TrainingViewController.h
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GestureRecorder.h"
#import "GestureDB.h"
#import "GestureRecognizerDelegate.h"
#import "GestureRecorderDelegate.h"

@interface TrainingViewController : UIViewController<GestureRecorderDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate> {
	UIButton * trainButton;
	UITextField * newGestureNametextField;
	UIButton * pickerButton;
	UIImageView * imageView;
	UILabel * label;
	UILabel * infoLabel;
	UIPickerView * picker;
	bool isRecordingTraining;
	bool isProcessingGesture;
	UIActivityIndicatorView * activityIndicator;
	GestureDB * gestureDB;
	GestureRecorder * gestureRecorder;
	NSObject<GestureRecognizerDelegate> * gestureRecognizer;
	
	bool forcedStop;
	
}
@property (nonatomic, retain) IBOutlet UITextField * gestureNametextField;
@property (nonatomic, retain) IBOutlet UIButton * pickerButton;
@property (nonatomic, retain) IBOutlet UIButton * trainButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel * label;
@property (nonatomic, retain) IBOutlet UILabel * infoLabel;
@property (nonatomic, retain) IBOutlet UIPickerView * picker;
@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) GestureRecorder * gestureRecorder;
@property (nonatomic, retain) GestureDB * gestureDB;
@property (nonatomic, retain) NSObject<GestureRecognizerDelegate> * gestureRecognizer;

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (IBAction)touchUpInside:(id) button;
- (IBAction)touchDown:(id) button;
- (IBAction)togglePicker:(id) button;

// @protocol GestureRecorderDelegate
- (void)recorderForcedStop: (id) sender;


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
@end
