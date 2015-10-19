//
//  TrainingViewController.m
//  3DollerRecognizer
//
//  Created by Ivo Brodien on 22.01.10.
//  Copyright 2010 Steuernummer 46 773 108 525. All rights reserved.
//

#import "TrainingViewController.h"
#import "ThreeDollarGestureRecognizer.h"
#import "_DollerRecognizerAppDelegate.h"
#import "CustomView.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation TrainingViewController

@synthesize trainButton;
@synthesize pickerButton;

@synthesize activityIndicator;
@synthesize label;
@synthesize picker;
@synthesize infoLabel;
@synthesize gestureRecorder;
@synthesize gestureDB;
@synthesize gestureNametextField;
@synthesize gestureRecognizer;
@synthesize imageView;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
       
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	gestureDB = [GestureDB sharedInstance];
	_DollerRecognizerAppDelegate * appDelegate = (_DollerRecognizerAppDelegate*) [[UIApplication sharedApplication] delegate];
	self.gestureRecognizer = appDelegate.recognizer;
	forcedStop = NO;
    [super viewDidLoad];
	
}


- (IBAction)togglePicker:(id) button {
	
	if(picker.hidden){
		
		[pickerButton setTitle:@"Confirm selection" forState:UIControlStateNormal];
		newGestureNametextField.hidden= NO;
		newGestureNametextField.text = @"";
		picker.hidden = NO;
		[self.view addSubview:picker];
		[picker reloadAllComponents];
		return;
	}
	//[UIView beginAnimations:@"suck" context:NULL];
	//[UIView setAnimationTransition:103 forView:self.view cache:YES];
	//[UIView setAnimationPosition:CGPointMake(210, 450)];
	//[UIView setAnimationDuration:1.0];
	[picker removeFromSuperview];
	//[UIView commitAnimations];
	
	picker.hidden = YES;
	newGestureNametextField.hidden= YES;
	[newGestureNametextField resignFirstResponder];
	NSString * textInField = [newGestureNametextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (![textInField isEqualToString:@""]) {
		[pickerButton setTitle:textInField forState:UIControlStateNormal];
	}
	else {
		int selectedRow = [picker selectedRowInComponent:0];
		if (selectedRow >= 0) {
			
			NSString * name = [[gestureDB.gestureDict allKeys] objectAtIndex:selectedRow];
			[pickerButton setTitle:name forState:UIControlStateNormal];
		}
	}
	
	UIImage *aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@64",pickerButton.titleLabel.text] ofType:@"png"]];
	
	if (aIconImage == nil) {
		aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unknown64"ofType:@"png"]];
	}
	
	imageView.image = aIconImage;
		
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)touchUpInside:(id) button {
	if (forcedStop) {
		[self didStopJobWithStatus:nil];
		return;
	}
		
	NSLog(@"touchUpInside");
	[gestureRecorder stopRecording];
	isRecordingTraining = NO;
	infoLabel.text = @"Processing Gesture";
	[activityIndicator startAnimating];

	
	trainButton.enabled = NO;
	[trainButton setTitle:@"Please wait..." forState:UIControlStateNormal];
	
	[self performSelectorInBackground:
	 @selector(inThreadStartDoJob:)
						   withObject:nil
	 ];
	
	// save Gesture into DB
	//@TODO
	
	NSLog(@"touchUpInside-End");
	
}

- (void)inThreadStartDoJob:(id)theJobToDo
{
    NSAutoreleasePool * pool;
	
    pool = [[NSAutoreleasePool alloc] init];
    assert(pool != nil);
	
    //status = [... do long running job specified by theJobToDo ...]
	
	if (gestureDB != nil) {
		
		Matrix * normalized = [gestureRecognizer prepareMatrixForLibrary:gestureRecorder.gesture.gestureTrace]; 
		
		gestureRecorder.gesture.gestureTrace = normalized;
		
		[gestureDB addGesture: gestureRecorder.gesture];
		NSLog(@"%@ Recorded Gesture length: %d",[self class],gestureRecorder.gesture.gestureTrace.rows);
		
		NSLog(@"%@ Gesture count in DB: %d",[self class],[gestureDB.gestures count]);
		
	}
	else {
		NSLog(@"ERROR gestureDB = nil");
	}
	
	[NSThread sleepForTimeInterval:0.01];
    [self performSelectorOnMainThread:
	 @selector(didStopJobWithStatus:)
						   withObject:nil
						waitUntilDone:NO
	 ];
	
    [pool drain];
}

- (void) didStopJobWithStatus: (id) status {
	isRecordingTraining = NO;
	[activityIndicator stopAnimating];
	trainButton.enabled = YES;
	
	self.trainButton.titleLabel.textColor = [UIColor blackColor];
	
	[trainButton setTitle:@"Press to Train" forState:UIControlStateNormal];
	
	if (forcedStop) {
		forcedStop = NO;
		infoLabel.text = @"Gesture dismissed!";
	}else {
		infoLabel.text = @"OK: gesture saved";
	}
	
}


- (IBAction)touchDown:(id) button {
	NSLog(@"touchDown");
	if (isRecordingTraining) return;
	isRecordingTraining = YES;
	
	
	[trainButton setTitle:@"Recording gesture.." forState:UIControlStateNormal];
	infoLabel.text = @"start making gesture";
	self.gestureRecorder = [[GestureRecorder alloc] initWithNameForGesture:pickerButton.titleLabel.text andDelegate: self];
	[gestureRecorder startRecording];
	
	NSLog(@"touchDown-End");
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;

}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [gestureDB.gestureDict count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	
	NSString * name = [[gestureDB.gestureDict allKeys] objectAtIndex:row];
	
	
	return name;

}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
	
	
	
	NSString * name = [[gestureDB.gestureDict allKeys] objectAtIndex:row];

	UIImage *aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@32",name] ofType:@"png"]];
	
	if (aIconImage == nil) {
		aIconImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unknown32"ofType:@"png"]];
	}
	
	
	CustomView *aView = [[CustomView alloc] initWithFrame:CGRectZero];
	
	aView.title = name;
	aView.image = aIconImage;
	//[aView release];
	
	return aView;

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
	return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

- (void)dealloc {
    [super dealloc];
}

- (void)recorderForcedStop: (id) sender{
	if (forcedStop) {
		return;
	}
	
	
	
	[gestureRecorder stopRecording];
	
	NSString *path = [NSString stringWithFormat:@"%@%@",
					  [[NSBundle mainBundle] resourcePath],
					  @"/ready.wav"];
	
	//declare a system sound id
	SystemSoundID soundID;
	
	//Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
	
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
	
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundID);

	forcedStop = YES;
	NSLog(@"FORCING STOP");
	
	if (sender == self.gestureRecorder) {
		infoLabel.text = @"Timeout - Gesture dismissed!";
	}else {
		infoLabel.text = @"Gesture dismissed!";
	}
	self.trainButton.titleLabel.textColor = [UIColor redColor];
	[self.trainButton setTitle:@"press once" forState:UIControlStateNormal];
	
	
}


@end
